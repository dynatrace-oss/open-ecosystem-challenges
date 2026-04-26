# 🟡 Intermediate: Dose by cohort

The trial is widening. Subjects arriving from the German-speaking clinics are getting the wrong reading, and the lab director has just walked into the lab holding a stack of complaint forms. She wants the audit log to tell her, after the fact, exactly which formulation went to which cohort — and she wants the lab to read the chart properly before it doses anyone.

Right now the lab reads `flags.json` and hands out the same variant to every subject walking in. The OpenFeature client never sees the subject's preferred language, never sees the framework version of the lab itself, and there is no audit hook recording who got what. The flag definition in `flags.json` already has a `language == de` targeting branch and a `springVersion >= 3.0.0` branch — the prescriptions are written, the rules are loaded — but neither attribute is in the evaluation context yet, so the targeting has nothing to fire on.

Your shift: teach the lab to read the subject's cohort from the request, attach the lab's framework version to the global context so older builds of the lab can be steered to a different formulation, and register an audit hook that records every dose with its variant and reason.

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│  Spring Boot lab  (this challenge)                             │
│                                                                      │
│  HTTP ──► LanguageInterceptor ──► IndexController ──► OpenFeature    │
│           (transaction ctx:                          (global ctx:    │
│            language=?language=)                       springVersion) │
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

The lab is a single Spring Boot service. flagd is **not** running as a container yet — the provider reads `flags.json` directly from disk in `Resolver.FILE` mode. The targeting rules live entirely inside `flags.json`; your job is to make sure the attributes the rules reference (`language`, `springVersion`) are populated on every evaluation.

## 🎯 Objective

By the end of this level, you should have:

- A Spring `HandlerInterceptor` that reads `?language=` from each incoming request, sets it on the OpenFeature **transaction context** for the duration of the request, and clears it on completion
- A **global evaluation context** that carries `springVersion` from `org.springframework.core.SpringVersion.getVersion()`
- A custom `Hook` registered on the OpenFeature API that logs every flag evaluation with the flag key, variant, and reason
- `curl http://localhost:8080/?language=de` returns the German variant (`"sharp"`)
- `curl http://localhost:8080/` (no `language`) returns the framework-version-targeted variant (`"enhanced"`) when running on Spring 3.x or newer, or the default `"blurry"` on older builds — but **never** the literal fallback `"untreated"`
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

### OpenFeature **global evaluation context**

A second slot of evaluation context, set once at startup, that **every** request sees. Use this for attributes that don't change per-request: framework version, region, deployment stage, build number. The targeting in `flags.json` already has a `springVersion >= 3.0.0` branch waiting on it.

### OpenFeature `Hook`

An interceptor for **flag evaluations** (not HTTP requests). Implements four lifecycle phases — `before`, `after`, `error`, `finallyAfter` — fired around every `client.getXxxDetails(...)` call. Register once with `api.addHooks(...)` and it applies to every evaluation. Same shape as a Spring HandlerInterceptor but at the OpenFeature layer instead of the HTTP layer; in this level you'll write a hook that emits an audit log line per evaluation.

### `flagd` `sem_ver` targeting

Read the targeting rule in `flags.json` carefully. The `sem_ver` operator does a version-range match on a context attribute. The rule there says "if `springVersion >= 3.0.0`, return `enhanced`". Your job is to make sure the `springVersion` attribute is *on* the evaluation context — not to write the rule.

## 🧠 What You'll Learn

- How OpenFeature's **transaction-context propagation** works in a thread-per-request server, and why a `ThreadLocalTransactionContextPropagator` is the right primitive for Servlet-based apps
- The difference between **request-scoped context** (the subject's language) and **global evaluation context** (the lab's framework version) — and when each is the right tool
- How **hooks** let you attach cross-cutting behaviour — audit logging today, OpenTelemetry tracing tomorrow — without modifying every flag evaluation call site
- How `flagd`'s targeting expressions read context attributes, including the `sem_ver` operator for version-range rules

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
    { "sem_ver": [{"var": "springVersion"}, ">=", "3.0.0"] }, "enhanced",
    { "===":     [{"var": "language"},      "de"] },          "sharp"
  ]
}
```

The catch: nothing in the application populates `language` or `springVersion`. Every request lands with an empty evaluation context, so neither targeting branch fires and every subject walks out with `"blurry"` (the default variant) — including the German-speaking ones.

Boot the lab as-is to confirm the symptom — either click **Run** on `DemoApplication` in the Spring Boot Dashboard panel (or press **F5** with `DemoApplication.java` open), or, from the terminal:

```bash
cd adventures/planned/00-side-effects-may-vary/intermediate
./mvnw spring-boot:run
```

In another terminal:

```bash
curl 'http://localhost:8080/?language=de'
# => {"value":"blurry", ...}    ← wrong cohort, no targeting fired
```

Stop the app (`Ctrl+C`) and start fixing.

### 3. Implement the Objective

You need three pieces.

#### 3a. A `LanguageInterceptor`

Create `src/main/java/dev/openfeature/demo/java/demo/LanguageInterceptor.java`. It implements Spring's `HandlerInterceptor` and does three things:

- In `preHandle`, read the `language` query parameter. If it's non-null, build an `ImmutableContext` with one attribute (`language` → `Value`) and set it on the OpenFeature **transaction context** via `OpenFeatureAPI.getInstance().setTransactionContext(...)`.
- In `afterCompletion`, clear the transaction context with an empty `ImmutableContext()` so the request's cohort doesn't leak into the next request that reuses this thread.
- In a static initialiser, register a `ThreadLocalTransactionContextPropagator` on the OpenFeature API. This is what makes the transaction context survive across the SDK call inside the controller.

#### 3b. Wire the interceptor + global context + hook in `OpenFeatureConfig`

Update `OpenFeatureConfig` to:

- Implement `WebMvcConfigurer` and override `addInterceptors(InterceptorRegistry registry)` to register your new `LanguageInterceptor`.
- After `setProviderAndWait`, build an `ImmutableContext` containing `springVersion` → `SpringVersion.getVersion()`, and call `api.setEvaluationContext(...)`. This is the **global** evaluation context — it's merged into every flag evaluation regardless of request.
- Call `api.addHooks(new CustomHook())` to register your audit hook globally.

#### 3c. A `CustomHook`

Create `src/main/java/dev/openfeature/demo/java/demo/CustomHook.java`. It implements `dev.openfeature.sdk.Hook`. At minimum, override `before(...)` and `after(...)` to log a line each — `LOG.info("Before hook")` and `LOG.info("After hook - {}", details.getReason())` is enough for the audit trail. You can also override `error(...)` and `finallyAfter(...)` for completeness.

The order matters less than you'd think — Spring will pick up `OpenFeatureConfig` as a `@Configuration` class on boot, the `@PostConstruct` will run once, and from then on every evaluation the `IndexController` performs will see both contexts and trigger your hook.

### 4. Run the Lab

`verify.sh` greps the lab's stdout for the `CustomHook` log lines, so the run needs to write to a file `app.log` next to `pom.xml`. The terminal command is:

```bash
cd adventures/planned/00-side-effects-may-vary/intermediate
./mvnw spring-boot:run | tee app.log
```

If you'd rather click **Run** in the Spring Boot Dashboard panel, the run starts the same `DemoApplication` but does not write to `app.log` automatically — for the verify step you still need the terminal command above.

### 5. Verify Each Cohort by Hand

In another terminal:

```bash
# German cohort — language targeting should fire
curl -s 'http://localhost:8080/?language=de' | jq .value
# => "sharp"

# Default cohort — springVersion targeting should fire on Spring 3.x+
curl -s 'http://localhost:8080/' | jq .value
# => "enhanced"   (or "blurry" on Spring 2.x — both acceptable)
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

The script checks that the app is reachable, the German and default cohorts return the right values, and the log file contains audit-hook lines.

## ✅ Verification

Once the verify script passes:

1. Commit and push your changes to your fork
2. Manually trigger the verification workflow on GitHub Actions (when the adventure goes live)
3. Share your success in the community thread

> 🧪 **Spoiler ahead?** A full walkthrough lives in [solutions/intermediate.md](./solutions/intermediate.md). Try it on your own first — the cohorts will thank you.
