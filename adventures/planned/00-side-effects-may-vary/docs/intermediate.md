# 🟡 Intermediate: Outcome by cohort

The trial is widening. Subjects from outside the lab's local population are getting the wrong reading on their chart, and the lab director has just walked into the lab holding a stack of complaint forms. She wants the audit log to tell her, after the fact, exactly which `vision_state` the lab recorded for which subject — and she wants the lab to read the chart properly before it records any more bad readings.

The protocol is the same for every subject; the lab is not varying the trial. What differs is the **observed outcome**, because subjects don't all start from the same place — some have a biology that responds enhancedly to the same serum, some absorb less or more than the protocol's standard dose, and the trial is registered in different jurisdictions with different baselines.

Right now the lab reads `flags.json` and reports the same reading for every subject walking in. The OpenFeature client never sees what **species** is on the table (each subject brings their own — humans, zyklops, you name it), never sees which **country** this trial is registered in (set once when the lab boots), never sees what **dose** the subject actually absorbed (the protocol calls for `"standard"`, but real-world adherence and metabolism vary), and there is no audit hook recording who got what reading. The flag definition in `flags.json` already has all three targeting branches loaded — `species == zyklop`, improper-`dose` for non-zyklops, and `country == de` — but none of those attributes are in the evaluation context yet, so the targeting has nothing to fire on.

Your shift: teach the lab to read each subject's species off the request, attach the trial's **country of registration** (set on the JVM via the `COUNTRY` environment variable) to the global context, pass the **dose** as invocation context at the moment of the flag evaluation, and register an audit hook that records every dose with its variant and reason.

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│  Spring Boot lab  (this challenge)                                   │
│                                                                      │
│  HTTP ──► SpeciesInterceptor ──► Trial ──► OpenFeature client        │
│           (transaction ctx:     (invocation ctx:   (global ctx:      │
│            species ← ?species=)  dose ← computed   country ←         │
│                                       at call site, $COUNTRY env)    │
│                                       overridable                    │
│                                       with ?dose=)                   │
│                                                            │         │
│                                                            ▼         │
│                                                       AuditHook      │
│                                                       (audit log)    │
│                                                            │         │
│                                                            ▼         │
│                                                       FlagdProvider  │
│                                                       (Resolver.RPC) │
└────────────────────────────────────────────────────────────┬─────────┘
                                                             │  gRPC :8013
                                                             ▼
                                          ┌─────────────────────────────┐
                                          │   flagd  (sibling container) │
                                          │   reads + watches flags.json │
                                          └─────────────────────────────┘
```

The lab and a flagd sidecar run as siblings in the devcontainer's compose stack. The OpenFeature client uses `Resolver.RPC` to reach `flagd:8013`; flagd is the one watching `flags.json` and serving evaluations from it. The targeting rules live entirely inside `flags.json`; your job is to make sure the attributes the rules reference (`species`, `country`, `dose`) are populated on every evaluation.

## 🎯 Objective

By the end of this level, you should have:

- A Spring `HandlerInterceptor` that reads `?species=` from each incoming request, sets it on the OpenFeature **transaction context** for the duration of the request, and clears it on completion
- A **global evaluation context** that carries `country` from the `COUNTRY` environment variable (`System.getenv("COUNTRY")`) the lab was started with
- A `Trial` controller that, on each evaluation, passes the **`dose`** as **invocation context** — `"standard"` most of the time, `"underdose"` or `"overdose"` when the lab tech mis-measures (overridable with `?dose=`)
- A custom `Hook` registered on the OpenFeature API that logs every flag evaluation with the flag key, variant, and reason
- `curl /?species=zyklop` → `"enhanced"` — zyklop biology dominates regardless of dose or country
- `curl /?dose=standard` → `"sharp"` (with `COUNTRY=de`) — proper dose, country branch fires
- `curl /?dose=underdose` → `"clouded"` — improper dosing causes side effects in non-zyklop subjects
- `curl /?species=zyklop&dose=underdose` → `"enhanced"` — zyklop biology survives bad dosing
- The response is never the literal fallback `"untreated"`
- The application log shows at least one line emitted by your `AuditHook` per request

> 📋 **Run with `tee app.log`.** The verifier (and your own debugging) reads the `[AUDIT]` lines from a file `app.log` next to `pom.xml`, so the lab needs to be started in a way that writes its stdout to that file. The two convenience scripts below (`./run-germany.sh` / `./run-austria.sh`) do this for you; if you run `./mvnw spring-boot:run` directly, pipe through `| tee app.log` or the verifier will fail with no audit log to grep.

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

The subject's `species` is the canonical request-scoped attribute: it changes from one subject to the next.

### OpenFeature **global evaluation context**

A second slot of evaluation context, set once at startup, that **every** request sees. Use this for attributes that don't change per-request: the trial's country of registration, the deployment region, the build number. The targeting in `flags.json` already has a `country == de` branch waiting on it — your job is to read `System.getenv("COUNTRY")` at startup and put it on the global context.

### OpenFeature **invocation context** (the call-site one)

A third slot of evaluation context, passed **at the moment** of `client.getXxxDetails(...)` as an `EvaluationContext` argument. Use this for attributes that are known only at the call site — not on the request, not at startup. The classic example is something the controller computes seconds before the call: a real-time reading, a per-evaluation choice the application code is making.

In this lab, the canonical example is the **dose** the subject actually absorbed. The protocol calls for a `"standard"` dose every time, but real-world adherence and metabolism vary — roughly 30% of subjects come back underdosed, 10% overdosed (missed appointments, fast metabolisers, the usual reasons). The dose isn't on the request and isn't a property of the lab; it's a per-subject reading the controller computes (or accepts via `?dose=`) and feeds straight into the call. The flag's targeting catches `dose ∈ {underdose, overdose}` for non-zyklop subjects and returns `clouded`.

The three context layers merge before evaluation, with **invocation context taking precedence** over transaction, which takes precedence over global, on conflict.

### OpenFeature `Hook`

An interceptor for **flag evaluations** (not HTTP requests). Implements four lifecycle phases — `before`, `after`, `error`, `finallyAfter` — fired around every `client.getXxxDetails(...)` call. Register once with `api.addHooks(...)` and it applies to every evaluation. Same shape as a Spring HandlerInterceptor but at the OpenFeature layer instead of the HTTP layer.

What makes a hook *valuable* (rather than just a "got here" log line) is that `HookContext.getCtx()` exposes the **merged** evaluation context the SDK was about to evaluate against — global + transaction + invocation, all three layers. So a hook can write a real audit trail: which flag resolved to which variant, for a subject of which `species`, in which trial `country`, with which `dose`. In this level your hook does exactly that; in the Expert level the same shape pushes the same attributes onto OpenTelemetry spans instead of log lines.

### `flagd` targeting

The targeting rule in `flags.json` is a small expression tree, evaluated top-to-bottom:

```jsonc
"if": [
  { "===": [{"var":"species"},    "zyklop"] },                  "enhanced",
  { "in":  [{"var":"dose"},    ["underdose", "overdose"]] }, "clouded",
  { "===": [{"var":"country"}, "de"] },                       "sharp"
]
// fall-through to defaultVariant: "blurry"
```

The first arm checks `species == zyklop`; zyklops are robust enough that improper dosing doesn't faze them, so this is checked first and wins outright. The second arm catches `dose ∈ {underdose, overdose}` for everyone else — improper dosing causes `clouded` readings. Then `country == de` for proper-dose non-zyklop subjects in the German trial. If none match, `defaultVariant: "blurry"` wins. Your job is to make sure the attributes the rules reference are *on* the evaluation context — not to write the rule.

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

The flagd sibling that the Beginner level introduced is still running here — the broken-state `OpenFeatureConfig` already targets it via `Resolver.RPC` (`flagd:8013` from the workspace, `localhost:8013` from your host). Once the level is solved, an optional sidebar: switch the resolver mode without changing the call sites — same flag definitions, different wire path.

- `Resolver.RPC` (the default in this level) — every evaluation makes one gRPC round-trip to flagd. Easiest to reason about; this is what you start with.
- `Resolver.IN_PROCESS` + `host("flagd")` + `port(8015)` — flag *definitions* stream into the JVM via flagd's sync API on port 8015, and evaluations happen locally. No per-call hop, and the flag definitions still come from a single source of truth. This is the most common shape in real production deployments.
- `Resolver.FILE` + `offlineFlagSourcePath("./flags.json")` — bypass flagd entirely; the SDK parses `flags.json` itself. Useful for unit tests where you don't want a sidecar.

All three are good bridges to the Expert level.

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
- Select "Adventure 00 | 🟡 Intermediate (Outcome by cohort)"
- Wait ~2-3 minutes for the Java toolchain to install (`Cmd/Ctrl + Shift + P` → `View Creation Log` to view progress)

When the post-create finishes you'll have Java 21, the Maven wrapper, and the broken-state lab ready in `adventures/planned/00-side-effects-may-vary/intermediate/`.

### 2. Inspect the Starting Point

The lab already has the OpenFeature SDK and the flagd contrib provider on the classpath, and the `FlagdProvider` is wired in `Resolver.RPC` mode against the flagd sibling. The `flags.json` shipping with this level is the targeting-rich version — all three branches (open `intermediate/flags.json` and you'll see this verbatim):

```json
"targeting": {
  "if": [
    { "===": [{"var": "species"}, "zyklop"] },                  "enhanced",
    { "in":  [{"var": "dose"},    ["underdose", "overdose"]] }, "clouded",
    { "===": [{"var": "country"}, "de"] },                      "sharp"
  ]
}
```

The catch: nothing in the application populates `species`, `country`, or `dose` yet. Every request lands with an empty evaluation context, so none of the branches fire and every subject walks out with `"blurry"` (the default variant) — even when they show up as a zyklop.

Boot the lab as-is to confirm the symptom — either click **Run** on `Laboratory` in the Spring Boot Dashboard panel (or press **F5** with `Laboratory.java` open), or, from the terminal:

```bash
cd adventures/planned/00-side-effects-may-vary/intermediate
./mvnw spring-boot:run
```

In another terminal:

```bash
curl 'http://localhost:8080/?species=zyklop'
# => {"value":"blurry", ...}    ← wrong cohort, no targeting fired
```

Stop the app (`Ctrl+C`) and start fixing.

### 3. Implement the Objective

You need three pieces.

#### 3a. A `SpeciesInterceptor`

Create `src/main/java/dev/openfeature/demo/java/demo/SpeciesInterceptor.java`. It implements Spring's `HandlerInterceptor` and does three things:

- In `preHandle`, read the `species` query parameter. If it's non-null, build an `ImmutableContext` with one attribute (`species` → `Value`) and set it on the OpenFeature **transaction context** via `OpenFeatureAPI.getInstance().setTransactionContext(...)`.
- In `afterCompletion`, clear the transaction context with an empty `ImmutableContext()` so the request's species doesn't leak into the next request that reuses this thread.
- In a static initialiser, register a `ThreadLocalTransactionContextPropagator` on the OpenFeature API. This is what makes the transaction context survive across the SDK call inside the controller.

#### 3b. Wire the interceptor + global context + hook in `OpenFeatureConfig`

Update `OpenFeatureConfig` to:

- Implement `WebMvcConfigurer` and override `addInterceptors(InterceptorRegistry registry)` to register your new `SpeciesInterceptor`.
- After `setProviderAndWait`, read `System.getenv("COUNTRY")` (with a sensible fallback like `""` when unset), build an `ImmutableContext` containing `country` → `Value`, and call `api.setEvaluationContext(...)`. This is the **global** evaluation context — it's merged into every flag evaluation regardless of request.
- Call `api.addHooks(new AuditHook())` to register your audit hook globally.

#### 3c. A `AuditHook`

Create `src/main/java/dev/openfeature/demo/java/demo/AuditHook.java`. It implements `dev.openfeature.sdk.Hook`. The lab director wants an **audit trail**, not a "got here" trace, so do something useful with the data the hook can see:

- In `after(...)`, read `HookContext.getCtx()` (the **merged** evaluation context) for the attributes the lab cares about — `species`, `country`, `dose` — and write an `[AUDIT]` log line that names the flag, the resolved variant, the reason, and those attributes. When `details.getVariant()` is `clouded`, log at **`WARN`** so the safety officer can grep for it; otherwise `INFO`.
- In `error(...)`, log at `WARN` so failed evaluations don't disappear silently.

> ⚠️ **Audit-log PII note.** Use a **fixed allowlist** (`List.of("species", "country", "dose")`) — never iterate the whole eval context.
>
> The merged context typically also carries `targetingKey` (often a user id) and, in real apps, things like email or account identifiers. Audit logs are retained longer than app logs and shipped off-host to SIEMs, so leaking PII here is hard to redact after the fact. Same discipline the Expert OTel hook will need; see [OpenTelemetry's security guidance](https://opentelemetry.io/docs/security/).

The order matters less than you'd think — Spring will pick up `OpenFeatureConfig` as a `@Configuration` class on boot, the `@PostConstruct` will run once, and from then on every evaluation the `Trial` performs will see both contexts and trigger your hook.

### 4. Run the Lab

`verify.sh` greps the lab's stdout for the `AuditHook` log lines, so the run needs to write to a file `app.log` next to `pom.xml`. **The trial's country of registration is set via the `COUNTRY` environment variable.** The level ships two convenience scripts in the project root that handle the env var and the `tee app.log` for you:

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

In another terminal — exercise all three context layers and the precedence between them:

```bash
# Transaction context — species wins, regardless of country / dose
curl -s 'http://localhost:8080/?species=zyklop' | jq .value
# => "enhanced"

# Global context — country=de from the env. Pin ?dose=standard so the
# random dose pick can't trip the improper-dose branch.
curl -s 'http://localhost:8080/?dose=standard' | jq .value
# => "sharp"     (when running ./run-germany.sh — COUNTRY=de)
# => "blurry"    (when running ./run-austria.sh — COUNTRY=at: no targeting branch fires, default applies)

# Invocation context — improper dose for a non-zyklop subject
curl -s 'http://localhost:8080/?dose=underdose' | jq .value
# => "clouded"

# Precedence — species-zyklop is evaluated before improper-dose in flags.json
curl -s 'http://localhost:8080/?species=zyklop&dose=underdose' | jq .value
# => "enhanced"
```

Tail the log to see the audit trail:

```bash
grep '\[AUDIT\]' app.log | head
```

You should see one `[AUDIT] flag=vision_state variant=… reason=… species=… country=… dose=…` line per `curl` call. `clouded` outcomes log at `WARN` with the "improper dosing or off-protocol cohort, follow-up required" suffix.

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
