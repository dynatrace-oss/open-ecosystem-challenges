# 🟡 Intermediate Solution Walkthrough: Dose by cohort

This walkthrough shows the target shape of the lab after the level is solved. We'll build it the way a clinical engineer would — read the objective, then drop in each piece in the order the OpenFeature SDK expects it.

> ⚠️ **Spoiler Alert:** The full solution is below. Try the level on your own first.

## 📋 Step 1: Recap the Objective

You need three pieces of code wired together:

1. A `LanguageInterceptor` that captures the `?language=` query parameter into the OpenFeature **transaction context** for the duration of the request.
2. An updated `OpenFeatureConfig` that registers the interceptor, sets `springVersion` on the **global** evaluation context, and registers the audit hook.
3. A `CustomHook` that logs every flag evaluation.

The flag definition in `flags.json` is already targeting-rich — both the `language == de` branch and the `springVersion >= 3.0.0` branch are in place.

## 🧩 Step 2: The `LanguageInterceptor`

Create `src/main/java/dev/openfeature/demo/java/demo/LanguageInterceptor.java`:

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

public class LanguageInterceptor implements HandlerInterceptor {
    public LanguageInterceptor() {
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String language = request.getParameter("language");
        if (language != null) {
            HashMap<String, Value> attributes = new HashMap<>();
            attributes.put("language", new Value(language));
            ImmutableContext evaluationContext = new ImmutableContext(attributes);
            OpenFeatureAPI.getInstance().setTransactionContext(evaluationContext);
        }
        return HandlerInterceptor.super.preHandle(request, response, handler);
    }

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
- `afterCompletion` clears the context. Servlet container threads are pooled, so leaving the previous request's `language` on the thread would leak it into the *next* request unlucky enough to land on the same thread.
- `preHandle` only sets the context if `language` is present. A `null` `language` query parameter must not poison the context — the framework-version targeting branch needs a clean slate.

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
import org.springframework.core.SpringVersion;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.HashMap;

@Configuration
public class OpenFeatureConfig implements WebMvcConfigurer {

    @PostConstruct
    public void initProvider() {
        OpenFeatureAPI api = OpenFeatureAPI.getInstance();
        FlagdOptions flagdOptions = FlagdOptions.builder()
                .resolverType(Config.Resolver.RPC)
                .offlineFlagSourcePath("./flags.json")
                .build();

        api.setProviderAndWait(new FlagdProvider(flagdOptions));

        HashMap<String, Value> attributes = new HashMap<>();
        attributes.put("springVersion", new Value(SpringVersion.getVersion()));
        ImmutableContext evaluationContext = new ImmutableContext(attributes);
        api.setEvaluationContext(evaluationContext);

        api.addHooks(new CustomHook());
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new LanguageInterceptor());
    }
}
```

What changed compared to the broken-state file:

- The class now `implements WebMvcConfigurer` and overrides `addInterceptors` to register `LanguageInterceptor`. Spring picks this up automatically because the class is a `@Configuration`.
- After `setProviderAndWait`, we build a one-attribute `ImmutableContext` with `springVersion` from `SpringVersion.getVersion()` and set it as the **global** evaluation context with `api.setEvaluationContext(...)`. This context merges into every evaluation regardless of request.
- We call `api.addHooks(new CustomHook())` to register the audit hook on every evaluation.

## ✅ Step 5: Verify

Boot the lab and pipe its log to a file:

```bash
./mvnw spring-boot:run | tee app.log
```

Hit it from another terminal:

```bash
curl -s 'http://localhost:8080/?language=de' | jq .value
# => "sharp"

curl -s 'http://localhost:8080/' | jq .value
# => "enhanced"   (or "blurry" on Spring 2.x)
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

- **Transaction context** is the right home for the language because it's per-request and must not survive into the next request. The `ThreadLocalTransactionContextPropagator` is what makes the SDK pick up that per-thread state on every evaluation.
- **Global evaluation context** is the right home for the framework version because it's a property of the lab itself, not the subject. Setting it once at boot is correct.
- **Hooks** are registered globally on the API, so every flag evaluation everywhere in the app picks them up — no need to thread the audit logger through every controller.

That separation is the whole reason OpenFeature ships a vendor-neutral context model. The same code reads cleanly whether the provider is flagd in FILE mode (this level), flagd in RPC mode against a remote container (the Expert level), or anything else that implements the SDK's provider interface.
