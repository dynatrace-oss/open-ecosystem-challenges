package dev.openfeature.demo.java.demo;

import dev.openfeature.sdk.Client;
import dev.openfeature.sdk.OpenFeatureAPI;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.concurrent.ThreadLocalRandom;

/**
 * Phase 3 lab. Reads the {@code vision_amplifier_v2} flag and, when the
 * fractional rollout puts the caller into the {@code on} bucket, executes the
 * deliberately bad new formulation: 200ms slower, 10% chance of a 5xx. The
 * baseline {@code vision_state} flag still drives the response body.
 */
@RestController
public class IndexController {

    @GetMapping("/")
    public ResponseEntity<?> helloWorld() {
        Client client = OpenFeatureAPI.getInstance().getClient();
        boolean newAlgo = client.getBooleanValue("vision_amplifier_v2", false);
        if (newAlgo) {
            try {
                Thread.sleep(200);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            if (ThreadLocalRandom.current().nextDouble() < 0.1) {
                return ResponseEntity.status(500).body("simulated failure in vision_amplifier_v2");
            }
        }
        return ResponseEntity.ok(client.getStringDetails("vision_state", "untreated"));
    }
}
