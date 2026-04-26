# 🟢 Beginner — Solution Walkthrough: Stand up the lab

> ⚠️ **Spoiler Alert:** This page walks through the full solution. If you want to figure it out yourself, head back to
> the [Beginner challenge](../beginner.md) and only return when you're stuck.

You are taking a Spring Boot service that returns a hard-coded label and turning it into a lab that reads its
prescription from `flags.json` through OpenFeature. There are four moving parts to get right: the dependencies, the
provider configuration, the flag file, and the controller. Below is the answer key for each.

## 1. Add the OpenFeature SDK and the flagd provider

The `pom.xml` you start with has only the Spring starters. Add the OpenFeature SDK and the flagd contrib provider —
these are the two libraries the lab needs to evaluate flags.

Open `pom.xml` and add the following inside `<dependencies>`:

```xml
<dependency>
    <groupId>dev.openfeature</groupId>
    <artifactId>sdk</artifactId>
    <version>1.14.2</version>
</dependency>
<dependency>
    <groupId>dev.openfeature.contrib.providers</groupId>
    <artifactId>flagd</artifactId>
    <version>0.11.8</version>
</dependency>
```

The first one is the vendor-neutral OpenFeature client — the API you call from your code. The second one is the
**provider**: the piece that knows how to talk to flagd. The SDK is provider-agnostic on purpose; you swap the
provider, your call sites stay the same.

## 2. Configure the FlagdProvider in file mode

The provider has to be registered with OpenFeature before any evaluation can happen. Create a new file
`src/main/java/dev/openfeature/demo/java/demo/OpenFeatureConfig.java`:

```java
package dev.openfeature.demo.java.demo;

import dev.openfeature.contrib.providers.flagd.Config;
import dev.openfeature.contrib.providers.flagd.FlagdOptions;
import dev.openfeature.contrib.providers.flagd.FlagdProvider;
import dev.openfeature.sdk.OpenFeatureAPI;
import jakarta.annotation.PostConstruct;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenFeatureConfig {

    @PostConstruct
    public void initProvider() {
        OpenFeatureAPI api = OpenFeatureAPI.getInstance();
        FlagdOptions flagdOptions = FlagdOptions.builder()
                .resolverType(Config.Resolver.FILE)
                .offlineFlagSourcePath("./flags.json")
                .build();

        api.setProviderAndWait(new FlagdProvider(flagdOptions));
    }
}
```

A few things worth noting:

- `Resolver.FILE` is what avoids needing a flagd container at this level. The provider reads the JSON directly and
  watches the file for changes.
- `offlineFlagSourcePath("./flags.json")` is resolved relative to the working directory when the JVM starts — that's
  the project root when you run `./mvnw spring-boot:run`.
- `setProviderAndWait` blocks until the provider has finished initializing, which means the first request the
  controller serves is already wired up.

## 3. Author the flag file

Create `flags.json` at the project root (next to `pom.xml`):

```json
{
  "flags": {
    "vision_state": {
      "state": "ENABLED",
      "variants": {
        "blurry": "blurry",
        "clouded": "clouded"
      },
      "defaultVariant": "blurry"
    }
  }
}
```

Three required fields per flag in flagd file mode:

- **`state`** — `"ENABLED"` (or `"DISABLED"` to force the SDK fallback).
- **`variants`** — a map from variant name to value. Two variants here give you something to flip in the verification
  step.
- **`defaultVariant`** — which variant gets returned when no targeting rules match. There are no rules at this level,
  so this is the variant every request gets.

## 4. Read the chart from the controller

Update `src/main/java/dev/openfeature/demo/java/demo/Trial.java` so it asks OpenFeature for the reading
instead of returning a literal:

```java
package dev.openfeature.demo.java.demo;

import dev.openfeature.sdk.Client;
import dev.openfeature.sdk.FlagEvaluationDetails;
import dev.openfeature.sdk.OpenFeatureAPI;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Trial {

    @GetMapping("/")
    public FlagEvaluationDetails<String> helloWorld() {
        Client client = OpenFeatureAPI.getInstance().getClient();
        return client.getStringDetails("vision_state", "untreated");
    }
}
```

Two intentional choices here:

- `"untreated"` is the **fallback** value passed to `getStringDetails`. The SDK only returns it if no provider is
  registered, the flag is missing, or the flag is disabled. Once your `OpenFeatureConfig` and `flags.json` are in
  place, you should never see this value again — and the smoke test asserts exactly that.
- The handler returns `FlagEvaluationDetails<String>` directly, not just the value. Spring will serialize it to JSON
  and the response will carry `flagKey`, `value`, `variant`, `reason`, and any error fields — useful for debugging,
  required by the smoke test.

## 5. Run it and verify

Restart the lab:

```bash
./mvnw spring-boot:run
```

In another terminal:

```bash
curl -s http://localhost:8080/ | jq
```

You should see `"value": "blurry"` and `"flagKey": "vision_state"`. Edit `flags.json`, change
`"defaultVariant": "blurry"` to `"defaultVariant": "clouded"`, save, and `curl` again — the value flips to
`"clouded"` without restarting the app. That's the file watcher inside the flagd provider doing its job.

Run the smoke test from the repo root:

```bash
adventures/planned/00-side-effects-may-vary/beginner/verify.sh
```

When all four checks pass, the lab is reading the chart and you're done with the 🟢 Beginner level.
