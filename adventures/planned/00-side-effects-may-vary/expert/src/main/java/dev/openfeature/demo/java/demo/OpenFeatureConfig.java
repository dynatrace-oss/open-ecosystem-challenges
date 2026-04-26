package dev.openfeature.demo.java.demo;

import dev.openfeature.contrib.hooks.otel.TracesHook;
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

/**
 * Wires the OpenFeature client to a remote flagd container ({@code Resolver.RPC},
 * default host {@code localhost:8013}) and registers the cross-cutting hooks.
 *
 * <p>Half-wired on purpose: the {@link TracesHook} reads the current span from
 * the global tracer provider, so flag evaluations show up in Tempo as soon as
 * the OpenTelemetry SDK is initialized. The matching {@code MetricsHook} is NOT
 * registered here — the meter provider is not exporting yet and the
 * "Fun With Flags" dashboard panels in Grafana stay dark. Finishing the wiring
 * is the participant's first task in this level.</p>
 */
@Configuration
public class OpenFeatureConfig implements WebMvcConfigurer {

    @PostConstruct
    public void initProvider() {
        OpenFeatureAPI api = OpenFeatureAPI.getInstance();
        FlagdOptions flagdOptions = FlagdOptions.builder()
                .resolverType(Config.Resolver.RPC)
                .build();

        api.setProviderAndWait(new FlagdProvider(flagdOptions));

        String country = Optional.ofNullable(System.getenv("COUNTRY")).orElse("");
        HashMap<String, Value> attributes = new HashMap<>();
        attributes.put("country", new Value(country));
        ImmutableContext evaluationContext = new ImmutableContext(attributes);
        api.setEvaluationContext(evaluationContext);

        api.addHooks(new CustomHook());
        api.addHooks(new TracesHook());
        // TODO Phase 3 task #1: register the matching MetricsHook here once
        // the meter provider has been wired up in OpenTelemetryConfig. Without
        // it the Grafana feature-flag dashboard cannot draw its panels.
        //
        // TODO Phase 3 task #2: write a small ContextSpanHook that copies the
        // merged evaluation context attributes (race, country, dose) onto the
        // active OpenTelemetry span — for example as
        // `feature_flag.context.<key>` — and register it here. Lets you search
        // Tempo for `feature_flag.context.dose=underdose` and see, on the same
        // span, which `feature_flag.variant` the lab handed out. Closes the
        // loop between why an outcome happened and what the dispenser knew at
        // the time.
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new RaceInterceptor());
    }
}
