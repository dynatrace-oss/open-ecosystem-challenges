package dev.openfeature.demo.java.demo;

import dev.openfeature.sdk.ImmutableContext;
import dev.openfeature.sdk.OpenFeatureAPI;
import dev.openfeature.sdk.ThreadLocalTransactionContextPropagator;
import dev.openfeature.sdk.Value;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.HashMap;

/**
 * Per-request OpenFeature transaction context. Reads {@code language} (drives
 * the German targeting branch on {@code vision_state}) and {@code userId} (used
 * as the OpenFeature targetingKey, so the fractional rollout on
 * {@code vision_amplifier_v2} is sticky per caller).
 */
public class LanguageInterceptor implements HandlerInterceptor {
    public LanguageInterceptor() {
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String language = request.getParameter("language");
        String userId = request.getParameter("userId");
        HashMap<String, Value> attributes = new HashMap<>();
        if (language != null) {
            attributes.put("language", new Value(language));
        }
        ImmutableContext evaluationContext = userId != null
                ? new ImmutableContext(userId, attributes)
                : new ImmutableContext(attributes);
        OpenFeatureAPI.getInstance().setTransactionContext(evaluationContext);
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
