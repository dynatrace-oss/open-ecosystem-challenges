# 🟡 Intermediate: Dose by cohort

The trial is widening. Subjects from outside the lab's local population are getting the wrong reading, and the lab director has just walked into the lab holding a stack of complaint forms. She wants the audit log to tell her, after the fact, exactly which formulation went to which subject — and she wants the lab to read the chart properly before it doses anyone.

Right now the lab reads `flags.json` and hands out the same variant to every subject walking in. The OpenFeature client never sees what **species** is on the table (each subject brings their own — humans, zyklops, you name it), never sees which **country** this trial is registered in (set once when the lab boots), never sees the **dose** the clinical staff just measured out (varies per evaluation — and let's be honest, some staff do not follow protocol), and there is no audit hook recording who got what. The flag definition in `flags.json` already has all three targeting branches loaded — `race == zyklop`, improper-`dose` for non-zyklops, and `country == de` — but none of those attributes are in the evaluation context yet, so the targeting has nothing to fire on.

Your shift: teach the lab to read each subject's species off the request, attach the trial's **country of registration** (set on the JVM via the `COUNTRY` environment variable) to the global context, pass the **dose** as invocation context at the moment of the flag evaluation, and register an audit hook that records every dose with its variant and reason.

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│  Spring Boot lab  (this challenge)                                   │
│                                                                      │
│  HTTP ──► RaceInterceptor ──► Trial ──► OpenFeature                  │
│           (transaction ctx:    (invocation ctx:   (global ctx:       │
│            race=?race=)         dose=random/?dose=) country=$COUNTRY)│
│                                                            │         │
│                                                            ▼         │
│                                                       CustomHook     │
│                                                       (audit log)    │
│                                                            │         │
│                                                            ▼         │
│                                                       FlagdProvider  │
│                                                       (FILE mode)    │
│                                                            │         │
│                                                            ▼         │
│                                                        flags.json    │
└──────────────────────────────────────────────────────────────────────┘
```

The lab is a single Spring Boot service. flagd is **not** running as a container yet — the provider reads `flags.json` directly from disk in `Resolver.FILE` mode. The targeting rules live entirely inside `flags.json`; your job is to make sure the attributes the rules reference (`race`, `country`) are populated on every evaluation.

## 🎯 Objective

By the end of this level, you should have:

- A Spring `HandlerInterceptor` that reads `?race=` from each incoming request, sets it on the OpenFeature **transaction context** for the duration of the request, and clears it on completion
- A **global evaluation context** that carries `country` from the `COUNTRY` environment variable (`System.getenv("COUNTRY")`) the lab was started with
- A `Trial` controller that, on each evaluation, passes the **`dose`** as **invocation context** — `"standard"` most of the time, `"underdose"` or `"overdose"` when the lab tech mis-measures (overridable with `?dose=`)
- A custom `Hook` registered on the OpenFeature API that logs every flag evaluation with the flag key, variant, and reason
- `curl /?race=zyklop` → `"enhanced"` — zyklop biology dominates regardless of dose or country
- `curl /?dose=standard` → `"sharp"` (with `COUNTRY=de`) — proper dose, country branch fires
- `curl /?dose=underdose` → `"clouded"` — improper dosing causes side effects in non-zyklop subjects
- `curl /?race=zyklop&dose=underdose` → `"enhanced"` — zyklop biology survives bad dosing
- The response is never the literal fallback `"untreated"`
- The application log shows at least one line emitted by your `CustomHook` per request

## 📚 Concepts you'll touch

If any of these are unfamiliar, read this section before opening the code — the puzzle will make a lot more sense afterwards.

### Spring `HandlerInterceptor`

A Spring MVC component that sits between the servlet container and your `@RestController`. The framework calls four hooks per request, in order:

1. `preHandle(...)` — runs **before** the controller. Return `true` to let the request through. This is where you read query parameters and stash anything per-request.
2. The controller method runs.
3. `postHandle(...)` — runs after the controller, before the response is written.
4. `afterCompletion(...)` — runs after the response, even on exceptions. **Use this to clear thread-local state.**

You register an interceptor by adding it to a `WebMvcConfigurer`'s `addInterceptors(InterceptorRegistry)` method.

### OpenFeature **transaction context**

A request-scoped slot of evaluation context. You set it once at the start of the request; every flag evaluation in that request sees it; you clear it at the end. The OpenFeature SDK does not know what "a request" is — that knowledge is wrapped in a **transaction context propagator**. For a thread-per-request servlet app, `ThreadLocalTransactionContextPropagator` is the right one — register it once on `OpenFeatureAPI` at startup, and `api.setTransactionContext(...)` then stores into a `ThreadLocal` so the controller (running on the same thread) can read it back without a parameter.

The subject's `race` is the canonical request-scoped attribute: it changes from one subject to the next.

### OpenFeature **global evaluation context**

A second slot of evaluation context, set once at startup, that **every** request sees. Use this for attributes that don't change per-request: the trial's country of registration, the deployment region, the build number. The targeting in `flags.json` already has a `country == de` branch waiting on it — your job is to read `System.getenv("COUNTRY")` at startup and put it on the global context.

### OpenFeature **invocation context** (the call-site one)

A third slot of evaluation context, passed **at the moment** of `client.getXxxDetails(...)` as an `EvaluationContext` argument. Use this for attributes that are known only at the call site — not on the request, not at startup. The classic example is something the controller computes seconds before the call: a real-time reading, a per-evaluation choice the application code is making.

In this lab, the canonical example is the **dose** that's about to be administered. Most of the lab's clinical staff follow protocol and dispense `"standard"` doses, but a fraction underdose or overdose subjects — let's call it 30% underdose, 10% overdose. The dose isn't on the request and isn't a property of the lab; it's a piece of state the controller computes (or accepts via `?dose=`) and feeds straight into the call. The flag's targeting catches `dose ∈ {underdose, overdose}` for non-zyklop subjects and returns `clouded`.

The three context layers merge before evaluation, with **invocation context taking precedence** over transaction, which takes precedence over global, on conflict.

### OpenFeature `Hook`

An interceptor for **flag evaluations** (not HTTP requests). Implements four lifecycle phases — `before`, `after`, `error`, `finallyAfter` — fired around every `client.getXxxDetails(...)` call. Register once with `api.addHooks(...)` and it applies to every evaluation. Same shape as a Spring HandlerInterceptor but at the OpenFeature layer instead of the HTTP layer.

What makes a hook *valuable* (rather than just a "got here" log line) is that `HookContext.getCtx()` exposes the **merged** evaluation context the SDK was about to evaluate against — global + transaction + invocation, all three layers. So a hook can write a real audit trail: which flag resolved to which variant, for a subject of which `race`, in which trial `country`, with which `dose`. In this level your hook does exactly that; in the Expert level the same shape pushes the same attributes onto OpenTelemetry spans instead of log lines.

### `flagd` targeting

The targeting rule in `flags.json` is a small expression tree, evaluated top-to-bottom:

```jsonc
"if": [
  { "===": [{"var":"race"},    "zyklop"] },                  "enhanced",
  { "in":  [{"var":"dose"},    ["underdose", "overdose"]] }, "clouded",
  { "===": [{"var":"country"}, "de"] },                       "sharp"
]
// fall-through to defaultVariant: "blurry"
```

The first arm checks `race == zyklop`; zyklops are robust enough that improper dosing doesn't faze them, so this is checked first and wins outright. The second arm catches `dose ∈ {underdose, overdose}` for everyone else — improper dosing causes `clouded` readings. Then `country == de` for proper-dose non-zyklop subjects in the German trial. If none match, `defaultVariant: "blurry"` wins. Your job is to make sure the attributes the rules reference are *on* the evaluation context — not to write the rule.

## 🧠 What You'll Learn

- How OpenFeature's **transaction-context propagation** works in a thread-per-request server, and why a `ThreadLocalTransactionContextPropagator` is the right primitive for Servlet-based apps
- The difference between **request-scoped context** (the subject's species) and **global evaluation context** (the trial's country) — and when each is the right tool
- How **hooks** let you attach cross-cutting behaviour — audit logging today, OpenTelemetry tracing tomorrow — without modifying every flag evaluation call site

## 🧰 Toolbox

Your Codespace comes pre-configured with the following tools:

- [Java 21](https://adoptium.net/) toolchain (Temurin)
- The Spring Boot Maven Wrapper (`./mvnw`) — no global Maven install required
- `curl` and `jq` for poking at the lab
- `tail -f` for watching the application log live

The FILE-mode provider reads `flags.json` directly inside the JVM, so the level itself does not need flagd as a container. There **is** a flagd sibling running in the devcontainer (reachable at `flagd:8013` from the workspace, `localhost:8013` from your host) so once FILE mode works you can switch the FlagdProvider to either of two remote modes against the same flag definitions:

- `Resolver.RPC` + `host("flagd")` + `port(8013)` — every evaluation hits flagd over gRPC.
- `Resolver.IN_PROCESS` + `host("flagd")` + `port(8015)` — flag *definitions* stream into the JVM via flagd's sync API on port 8015 and evaluation stays in-process. Best of both worlds: no per-call hop, and the flag definitions still come from a single source of truth.

Both are good bridges to the Expert level.

## ⏰ Deadline

> 🚧 **Coming Soon** — this level is in the planned bucket. Final deadline will be announced when the adventure goes live.

## 💬 Join the discussion

> 🚧 **Coming Soon** — community thread will be linked here at launch.

## ✅ How to Play

### 1. Start Your Challenge

> 📖 **First time?** Check out the [Getting Started Guide](../../start-a-challenge) for detailed instructions on forking, starting a Codespace, and waiting for infrastructure setup.

Quick start:

- Fork the repo
- Create a Codespace
- Select "Adventure 00 | 🟡 Intermediate (Dose by cohort)"
- Wait ~2-3 minutes for the Java toolchain to install (`Cmd/Ctrl + Shift + P` → `View Creation Log` to view progress)

When the post-create finishes you'll have Java 21, the Maven wrapper, and the broken-state lab ready in `adventures/planned/00-side-effects-may-vary/intermediate/`.

### 2. Inspect the Starting Point

The lab already has the OpenFeature SDK and the flagd contrib provider on the classpath, and the `FlagdProvider` is wired in `Resolver.FILE` mode. The `flags.json` shipping with this level is the targeting-rich version — the prescriptions are already there:

```json
"targeting": {
  "if": [
    { "===": [{"var": "race"},    "zyklop"] }, "enhanced",
    { "===": [{"var": "country"}, "de"] },     "sharp"
  ]
}
```

The catch: nothing in the application populates `race` or `country`. Every request lands with an empty evaluation context, so neither targeting branch fires and every subject walks out with `"blurry"` (the default variant) — even when they show up as a zyklop.

Boot the lab as-is to confirm the symptom — either click **Run** on `Laboratory` in the Spring Boot Dashboard panel (or press **F5** with `Laboratory.java` open), or, from the terminal:

```bash
cd adventures/planned/00-side-effects-may-vary/intermediate
./mvnw spring-boot:run
```

In another terminal:

```bash
curl 'http://localhost:8080/?race=zyklop'
# => {"value":"blurry", ...}    ← wrong cohort, no targeting fired
```

Stop the app (`Ctrl+C`) and start fixing.

### 3. Implement the Objective

You need three pieces.

#### 3a. A `RaceInterceptor`

Create `src/main/java/dev/openfeature/demo/java/demo/RaceInterceptor.java`. It implements Spring's `HandlerInterceptor` and does three things:

- In `preHandle`, read the `race` query parameter. If it's non-null, build an `ImmutableContext` with one attribute (`race` → `Value`) and set it on the OpenFeature **transaction context** via `OpenFeatureAPI.getInstance().setTransactionContext(...)`.
- In `afterCompletion`, clear the transaction context with an empty `ImmutableContext()` so the request's species doesn't leak into the next request that reuses this thread.
- In a static initialiser, register a `ThreadLocalTransactionContextPropagator` on the OpenFeature API. This is what makes the transaction context survive across the SDK call inside the controller.

#### 3b. Wire the interceptor + global context + hook in `OpenFeatureConfig`

Update `OpenFeatureConfig` to:

- Implement `WebMvcConfigurer` and override `addInterceptors(InterceptorRegistry registry)` to register your new `RaceInterceptor`.
- After `setProviderAndWait`, read `System.getenv("COUNTRY")` (with a sensible fallback like `""` when unset), build an `ImmutableContext` containing `country` → `Value`, and call `api.setEvaluationContext(...)`. This is the **global** evaluation context — it's merged into every flag evaluation regardless of request.
- Call `api.addHooks(new CustomHook())` to register your audit hook globally.

#### 3c. A `CustomHook`

Create `src/main/java/dev/openfeature/demo/java/demo/CustomHook.java`. It implements `dev.openfeature.sdk.Hook`. The lab director wants an **audit trail**, not a "got here" trace, so do something useful with the data the hook can see:

- In `after(...)`, read `HookContext.getCtx()` (the **merged** evaluation context) for the attributes the lab cares about — `race`, `country`, `dose` — and write an `[AUDIT]` log line that names the flag, the resolved variant, the reason, and those attributes. When `details.getVariant()` is `clouded`, log at **`WARN`** so the safety officer can grep for it; otherwise `INFO`.
- In `error(...)`, log at `WARN` so failed evaluations don't disappear silently.

> ⚠️ **Audit-log PII discipline.** Audit logs are typically retained longer than application logs, often shipped to a SIEM or long-term archive, and are hard to redact after the fact. Use a **fixed allowlist** (e.g. `List.of("race", "country", "dose")`) instead of iterating over the whole context — `targetingKey` and any other PII the host app stuffs into the OpenFeature context shouldn't end up here. Same allowlist discipline that the Expert level's OTel hook will need (see [OpenTelemetry security & privacy guidance](https://opentelemetry.io/docs/security/) for the broader rule), just with shorter retention.

The order matters less than you'd think — Spring will pick up `OpenFeatureConfig` as a `@Configuration` class on boot, the `@PostConstruct` will run once, and from then on every evaluation the `Trial` performs will see both contexts and trigger your hook.

### 4. Run the Lab

`verify.sh` greps the lab's stdout for the `CustomHook` log lines, so the run needs to write to a file `app.log` next to `pom.xml`. **The trial's country of registration is set via the `COUNTRY` environment variable.** The level ships two convenience scripts in the project root that handle the env var and the `tee app.log` for you:

```bash
cd adventures/planned/00-side-effects-may-vary/intermediate
./run-germany.sh   # COUNTRY=de — exercises the country-targeting branch
./run-austria.sh   # COUNTRY=at — country branch does NOT fire; default applies
```

Roll your own country at any time with `COUNTRY=<code> ./mvnw spring-boot:run | tee app.log`.

The devcontainer also exports `COUNTRY=de` by default in the workspace environment, so a plain `./mvnw spring-boot:run` (or **F5** / **Run** in the Spring Boot Dashboard) already runs the German trial.

For one-click switching from the IDE, the level ships three named **Run and Debug** configurations in `.vscode/launch.json`:

- 🇩🇪 **Run the Lab — Germany (COUNTRY=de)**
- 🇦🇹 **Run the Lab — Austria (COUNTRY=at)**
- 🌍 **Run the Lab — No country**

Open the **Run and Debug** view (`Ctrl/Cmd + Shift + D`), pick one from the dropdown, and hit ▶. Switching country is a click; no terminal needed.

### 5. Verify Each Cohort by Hand

In another terminal:

```bash
# Per-subject targeting — race wins over country
curl -s 'http://localhost:8080/?race=zyklop' | jq .value
# => "enhanced"

# No race on the request, country=de from the env — country branch fires
curl -s 'http://localhost:8080/' | jq .value
# => "sharp"
```

Tail the log to see the audit trail:

```bash
tail app.log | grep -E "Before hook|After hook"
```

You should see one `Before hook` and one `After hook` line per `curl` call.

### 6. Run the Verification Script

```bash
adventures/planned/00-side-effects-may-vary/intermediate/verify.sh
```

The script checks that the app is reachable, the zyklop and German cohorts return the right values, and the log file contains audit-hook lines.

## ✅ Verification

Once the verify script passes:

1. Commit and push your changes to your fork
2. Manually trigger the verification workflow on GitHub Actions (when the adventure goes live)
3. Share your success in the community thread

> 🧪 **Spoiler ahead?** A full walkthrough lives in [solutions/intermediate.md](./solutions/intermediate.md). Try it on your own first — the cohorts will thank you.
