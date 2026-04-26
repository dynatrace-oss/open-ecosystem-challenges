# 🟡 Intermediate Solution Walkthrough: Dose by cohort

This walkthrough shows the target shape of the lab after the level is solved. We'll build it the way a clinical engineer would — read the objective, then drop in each piece in the order the OpenFeature SDK expects it.

> ⚠️ **Spoiler Alert:** The full solution is below. Try the level on your own first.

## 📋 Step 1: Recap the Objective

You need three pieces of code wired together:

1. A `RaceInterceptor` that captures the `?race=` query parameter into the OpenFeature **transaction context** for the duration of the request.
2. An updated `OpenFeatureConfig` that registers the interceptor, reads `COUNTRY` from the environment and sets it on the **global** evaluation context, and registers the audit hook.
3. A `CustomHook` that logs every flag evaluation.

The flag definition in `flags.json` is already targeting-rich — both the `race == zyklop` branch and the `country == de` branch are in place.

## 🧩 Step 2: The `RaceInterceptor`

Create `src/main/java/dev/openfeature/demo/java/demo/RaceInterceptor.java`:

```java
package dev.openfeature.demo.java.demo;

import dev.openfeature.sdk.ImmutableContext;
import dev.openfeature.sdk.OpenFeatureAPI;
import dev.openfeature.sdk.ThreadLocalTransactionContextPropagator;
import dev.openfeature.sdk.Value;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.HashMap;

public class RaceInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String race = request.getParameter("race");
        if (race != null) {
            HashMap<String, Value> attributes = new HashMap<>();
            attributes.put("race", new Value(race));
            ImmutableContext evaluationContext = new ImmutableContext(attributes);
            OpenFeatureAPI.getInstance().setTransactionContext(evaluationContext);
        }
        return HandlerInterceptor.super.preHandle(request, response, handler);
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        OpenFeatureAPI.getInstance().setTransactionContext(new ImmutableContext());
        HandlerInterceptor.super.afterCompletion(request, response, handler, ex);
    }

    static {
        OpenFeatureAPI.getInstance().setTransactionContextPropagator(new ThreadLocalTransactionContextPropagator());
    }
}
```

A few details worth calling out:

- The static initialiser registers a `ThreadLocalTransactionContextPropagator` on the API. Without it the SDK has no way to carry per-request context across the call into the controller — the transaction context would silently be empty.
- `afterCompletion` clears the context. Servlet container threads are pooled, so leaving the previous request's `race` on the thread would leak it into the *next* request unlucky enough to land on the same thread.
- `preHandle` only sets the context if `race` is present. A `null` `race` query parameter must not poison the context — the country-targeting branch needs a clean slate when no per-request race is given.

## 🧩 Step 3: The `CustomHook`

Create `src/main/java/dev/openfeature/demo/java/demo/CustomHook.java`:

```java
package dev.openfeature.demo.java.demo;

import dev.openfeature.sdk.EvaluationContext;
import dev.openfeature.sdk.FlagEvaluationDetails;
import dev.openfeature.sdk.Hook;
import dev.openfeature.sdk.HookContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;
import java.util.Optional;

public class CustomHook implements Hook {
    private static final Logger LOG = LoggerFactory.getLogger(CustomHook.class);

    @Override
    public Optional<EvaluationContext> before(HookContext ctx, Map hints) {
        LOG.info("Before hook");
        return Hook.super.before(ctx, hints);
    }

    @Override
    public void after(HookContext ctx, FlagEvaluationDetails details, Map hints) {
        LOG.info("After hook - {}", details.getReason());
        Hook.super.after(ctx, details, hints);
    }

    @Override
    public void error(HookContext ctx, Exception error, Map hints) {
        LOG.error("Error hook", error);
        Hook.super.error(ctx, error, hints);
    }

    @Override
    public void finallyAfter(HookContext ctx, FlagEvaluationDetails details, Map hints) {
        LOG.info("Finally After hook - {}", details.getReason());
        Hook.super.finallyAfter(ctx, details, hints);
    }
}
```

Today this hook just writes log lines — that's enough to satisfy the audit requirement. In the Expert level you'll swap this homemade hook for the OpenFeature OTel `MetricsHook` and `TracesHook`, which join flag evaluations to the rest of the application's telemetry without modifying any controller.

## 🧩 Step 4: Update `OpenFeatureConfig`

Replace `src/main/java/dev/openfeature/demo/java/demo/OpenFeatureConfig.java` with:

```java
package dev.openfeature.demo.java.demo;

import dev.openfeature.contrib.providers.flagd.Config;
import dev.openfeature.contrib.providers.flagd.FlagdOptions;
import dev.openfeature.contrib.providers.flagd.FlagdProvider;
import dev.openfeature.sdk.ImmutableContext;
import dev.openfeature.sdk.OpenFeatureAPI;
import dev.openfeature.sdk.Value;
import jakarta.annotation.PostConstruct;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.HashMap;
import java.util.Optional;

@Configuration
public class OpenFeatureConfig implements WebMvcConfigurer {

    @PostConstruct
    public void initProvider() {
        OpenFeatureAPI api = OpenFeatureAPI.getInstance();
        FlagdOptions flagdOptions = FlagdOptions.builder()
                .resolverType(Config.Resolver.FILE)
                .offlineFlagSourcePath("./flags.json")
                .build();

        api.setProviderAndWait(new FlagdProvider(flagdOptions));

        // Read the trial's country of registration from the environment.
        // Empty string when unset — flagd's `===` operator simply won't match,
        // and the default variant wins.
        String country = Optional.ofNullable(System.getenv("COUNTRY")).orElse("");
        HashMap<String, Value> attributes = new HashMap<>();
        attributes.put("country", new Value(country));
        ImmutableContext evaluationContext = new ImmutableContext(attributes);
        api.setEvaluationContext(evaluationContext);

        api.addHooks(new CustomHook());
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new RaceInterceptor());
    }
}
```

What changed compared to the broken-state file:

- The class now `implements WebMvcConfigurer` and overrides `addInterceptors` to register `RaceInterceptor`. Spring picks this up automatically because the class is a `@Configuration`.
- After `setProviderAndWait`, we read `System.getenv("COUNTRY")`, build a one-attribute `ImmutableContext` with `country` set to that value, and call `api.setEvaluationContext(...)`. This context merges into every evaluation regardless of request.
- We call `api.addHooks(new CustomHook())` to register the audit hook on every evaluation.

## ✅ Step 5: Verify

Boot the lab. The level ships two convenience scripts that pre-set `COUNTRY` and pipe to `app.log`:

```bash
./run-germany.sh   # COUNTRY=de
# or
./run-austria.sh   # COUNTRY=at
```

Hit it from another terminal:

```bash
# Per-subject targeting wins over country
curl -s 'http://localhost:8080/?race=zyklop' | jq .value
# => "enhanced"

# No race on the request, country=de from the env — country branch fires
curl -s 'http://localhost:8080/' | jq .value
# => "sharp"     (when running ./run-germany.sh)
# => "blurry"    (when running ./run-austria.sh — neither branch fires)
```

Then check the audit trail:

```bash
grep -E "Before hook|After hook" app.log
```

You should see two lines per `curl` call.

Run the verification script:

```bash
adventures/planned/00-side-effects-may-vary/intermediate/verify.sh
```

If everything passes, the cohorts are correctly dosed and the audit log is recording.

## 🧠 Why This Layout Works

- **Transaction context** is the right home for the subject's race because it's per-request and must not survive into the next request. The `ThreadLocalTransactionContextPropagator` is what makes the SDK pick up that per-thread state on every evaluation.
- **Global evaluation context** is the right home for the trial's country because it's a property of the lab instance itself, not the subject. Setting it once at boot is correct, and reading it from `COUNTRY` in the environment lets the same image serve different trials without rebuilding.
- **Hooks** are registered globally on the API, so every flag evaluation everywhere in the app picks them up — no need to thread the audit logger through every controller.

That separation is the whole reason OpenFeature ships a vendor-neutral context model. The same code reads cleanly whether the provider is flagd in FILE mode (this level), flagd in RPC mode against a remote container (the Expert level), or anything else that implements the SDK's provider interface.
