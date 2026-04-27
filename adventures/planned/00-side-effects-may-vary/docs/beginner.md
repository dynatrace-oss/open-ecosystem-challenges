# 🟢 Beginner: Stand up the lab

The lab is on its first shift and it isn't reading the chart. Every subject who walks through the door gets the same hard-coded reading on their record — no matter what the lab director just signed off on. The label coming out of the lab is a literal string baked into the controller, not a reading pulled from the chart.

Your mission: replace that hard-coded label with an OpenFeature client, point that client at the **flagd sidecar** that already runs next to your Codespace, and let `flags.json` drive what gets recorded as the subject's `vision_state`. While you're at it, prove the lab can change what it records **without restarting anything** — edit `flags.json`, save, and the next subject through the door has the new reading on their chart.

The Spring Boot lab is already running on `:8080`. A flagd container is already running on `:8013` next to it. The OpenFeature SDK is **not** wired in yet, and `flags.json` is an empty skeleton (`{"flags": {}}`) — flagd has nothing to evaluate. Wiring the lab to flagd, and authoring the first flag, is your job.

## 🏗️ Architecture

This level runs as two containers side-by-side in your Codespace — the Spring Boot lab and a flagd sidecar.

- **The lab** — a Spring Boot 4 service on `http://localhost:8080/` with one endpoint, `GET /`. Today it returns a hard-coded `"untreated"` literal from `Trial`.
- **The chart** — a `flags.json` file in the level folder, mounted **read-only** into the flagd sidecar. The participant edits it through the IDE; flagd's file watcher picks up the change.
- **The flagd sidecar** — `ghcr.io/open-feature/flagd:latest`, started by the devcontainer compose stack. It serves flag evaluations over **gRPC on `:8013`**, watches `flags.json` on disk, and reloads when it changes.
- **The chart system** — the OpenFeature Java SDK plus the **flagd contrib provider** in `Resolver.RPC` mode. The provider reads `FLAGD_HOST=flagd` / `FLAGD_PORT=8013` from the environment (the compose file pre-sets them), so there is no host or port to hard-code.

```
                ┌──────────────────────────────┐
   GET /        │   Laboratory (Spring Boot)   │
 ────────►      │     Trial                    │
                │       └─ OF Client           │
                │           └─ FlagdProvider (RPC)
                └────────────────┬─────────────┘
                                 │  gRPC :8013
                                 ▼
                ┌──────────────────────────────┐
                │   flagd  (sidecar)           │
                └────────────────┬─────────────┘
                                 │  reads + watches
                                 ▼
                            flags.json
```

> 💡 **Why a sidecar instead of file mode in-process?** The flagd provider can also read `flags.json` directly inside the JVM (`Resolver.FILE`), and that is fine for tests. In real deployments, however, flagd typically runs as a separate process: it's language-agnostic (one flag service serves Java, Go, Python, Node services in the same cluster) and it concentrates the watch / reload / authentication concerns in one place. Starting the adventure with the sidecar shape means everything you learn in Beginner carries straight into Intermediate and Expert without re-plumbing.

## 🎯 Objective

By the end of this level, you should:

- Have `curl http://localhost:8080/` return a `vision_state` reading **resolved from `flags.json`** (not the hard-coded `"untreated"` fallback)
- Confirm the response payload includes the **OpenFeature evaluation details** — flag key, variant, reason, value
- Edit `flags.json` to change the `defaultVariant`, save, and have the **next** request return the new variant **without restarting the app**

## 🧠 What You'll Learn

- How an OpenFeature client and provider work together — the SDK is provider-agnostic and the flagd provider plugs in via dependency only
- What "remote provider" means in practice — the SDK calls a separate flag service (flagd) over gRPC; the SDK does not parse `flags.json` itself
- What `flags.json` looks like for flagd (`state`, `variants`, `defaultVariant`)
- Why hot-reload of the flag file matters operationally — configuration without redeploy

## 🧰 Toolbox

Your Codespace comes pre-configured with the following tools to help you solve the challenge:

- [`./mvnw`](https://maven.apache.org/wrapper/): The Maven wrapper checked in next to `pom.xml`. Builds and runs the Spring Boot lab.
- [`curl`](https://curl.se/): Hits `http://localhost:8080/` and shows you what reading the lab is recording.
- [`jq`](https://jqlang.org/): Pretty-prints and filters the JSON evaluation details that come back from the SDK.
- A **flagd sidecar** — already running in the devcontainer's compose stack. It listens on `:8013` (gRPC eval), `:8014` (management — Prometheus metrics + health), `:8015` (gRPC sync stream — used by IN_PROCESS mode), `:8016` (OFREP HTTP eval API). For this level you only talk to `:8013`.

## ⏰ Deadline

_TBD — to be announced at challenge launch._
> ℹ️ You can still complete the challenge after this date, but points will only be awarded for submissions before the
> deadline.

## 💬 Join the discussion

Share your solutions and questions in the challenge thread on the Open Ecosystem Community.
_Discussion link will be added when this adventure goes live._

## 📝 Solution Walkthrough

> ⚠️ **Spoiler Alert:** The following walkthrough contains the full solution to the challenge. We encourage you to try
> solving it on your own first. Consider coming back here only if you get stuck or want to check your approach.

Need the answer key? Follow the [step-by-step beginner solution walkthrough](./solutions/beginner.md) for the final
`pom.xml` dependencies, `OpenFeatureConfig`, `flags.json`, and `Trial`.

## ✅ How to Play

### 1. Start Your Challenge

- Click the "Fork" button in the top-right corner of the GitHub repo or use
  [this link](https://github.com/dynatrace-oss/open-ecosystem-challenges/fork).
- From your fork, click the green **Code** button → **Codespaces hamburger menu** → **New with options**.
- Select the **Adventure 00 | 🟢 Beginner (Stand up the lab)** configuration.

> ⚠️ **Important:** The challenge will not work if you choose another configuration (or the default).

The Codespace will install a Java 21 toolchain and resolve the Maven dependencies. Once it is ready you'll have a
terminal in
`adventures/planned/00-side-effects-may-vary/beginner/`.

### 2. Access the UIs

Open the **Ports** tab in the bottom panel. You should see:

- **8080 — Lab (Spring Boot).** Click the forwarded address. You should see the current hard-coded response: `untreated`.
- **8013 — flagd gRPC.** This is the flagd sidecar. Nothing to click yet, but knowing it's there is the point: the lab
  is going to talk to this in step 3.
- **8014 — management/metrics, 8015 — sync stream, 8016 — OFREP HTTP.** Auxiliary endpoints; you don't need them for
  the Beginner level.

### 3. Implement the Objective

You are turning a hard-coded label into a real protocol-driven reading. Work through the steps in this order — each
step makes the next one possible.

#### a. Add the OpenFeature SDK and the flagd provider to `pom.xml`

The lab needs two new ingredients in the cabinet:

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

Drop them inside the existing `<dependencies>` block, next to the Spring starters. See the
[OpenFeature Java SDK docs](https://openfeature.dev/docs/reference/technologies/server/java/) and the
[flagd Java provider readme](https://github.com/open-feature/java-sdk-contrib/tree/main/providers/flagd) if you want
the full reference.

#### b. Configure the OpenFeature provider

Create a new Spring `@Configuration` class — `OpenFeatureConfig.java` — that runs at startup, builds a `FlagdProvider`
in **RPC mode**, and registers it on the global `OpenFeatureAPI` instance.

The lab's protocol is: build `FlagdOptions` with `Resolver.RPC` (no host or port — the provider reads `FLAGD_HOST`
and `FLAGD_PORT` from the environment, and the devcontainer pre-sets them to `flagd:8013`), then call
`api.setProviderAndWait(new FlagdProvider(options))` from a `@PostConstruct` method.

> ℹ️ The flagd provider supports three resolver modes: **`RPC`** (gRPC round-trip per evaluation; the simplest wire
> shape), **`IN_PROCESS`** (a gRPC sync stream pushes the flag set into the SDK so evaluations stay local — this is
> the most common shape in real production deployments, and Intermediate has a sidebar on flipping to it against
> the same flagd sibling), and **`FILE`** (read flags.json directly from disk, no flagd container at all). We use
> RPC here because the wire model is the easiest to reason about for a first contact with OpenFeature.

#### c. Author the `vision_state` flag in `flags.json`

The level ships an empty `flags.json` next to `pom.xml` (`{"flags": {}}`) so the flagd sidecar has a valid file to
mount at boot. Open it and add the first flag definition:

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

Two variants give you something to flip in the verification step. Save — flagd's file watcher picks the change up
within about a second; no restart needed.

#### d. Read the chart from `Trial`

Replace the hard-coded `return "untreated";` with a call through the OpenFeature client. The handler should grab the
default client from `OpenFeatureAPI`, call
`client.getStringDetails("vision_state", "untreated")`, and **return the
`FlagEvaluationDetails<String>` directly** so the response carries the flag key, variant, value, and reason.

> 💡 **Tip:** Returning `FlagEvaluationDetails` (instead of just the value) is what makes the verification visible —
> the JSON body shows `flagKey`, `variant`, `reason`, and `value`, which is exactly what the smoke test checks.

#### e. Restart the lab, then prove hot-reload

You have two ways to start the lab:

- **Click ▶ in VS Code.** The Spring Boot Dashboard panel (one of the recommended extensions in this devcontainer) lists `Laboratory` with a **Run** button. Or press **F5** with `Laboratory.java` open and pick **Java** as the debugger — Spring's main class is detected automatically; no launch.json needed.
- **From the terminal** in the level folder:

  ```bash
  ./mvnw spring-boot:run
  ```

In another terminal:

```bash
curl -s http://localhost:8080/ | jq
```

You should see `"value": "blurry"` and `"flagKey": "vision_state"`. Now, **without stopping the app or the flagd
sidecar**, edit `flags.json` and change `"defaultVariant": "blurry"` to `"defaultVariant": "clouded"`. Save, then
re-run the `curl`. The value should flip to `"clouded"` — that's flagd's file watcher noticing the change on disk
and serving the new variant on the next gRPC evaluation. Nothing redeployed; nothing restarted.

### 4. Verify Your Solution

Once you think you've solved the challenge, it's time to verify!

#### Run the Smoke Test

Run the provided smoke test script (the lab must still be running on `:8080`):

```bash
adventures/planned/00-side-effects-may-vary/beginner/verify.sh
```

The script will:

1. Confirm `http://localhost:8080/` is reachable.
2. Confirm the response is OpenFeature evaluation details for the `vision_state` flag.
3. Confirm the value is **not** the hard-coded `"untreated"` fallback.
4. Swap `defaultVariant` in `flags.json`, wait for the file watcher, confirm the response changes, then restore the
   original file.

If the test passes, your solution is very likely correct! 🎉

#### Complete Full Verification

For comprehensive validation and to officially claim completion:

1. **Commit and push your changes** to your fork
2. **Manually trigger the verification workflow** on GitHub Actions
3. **Share your success** with the community

> 📖 **Need detailed verification instructions?** Check out the [Verification Guide](../../verification) for
> step-by-step instructions on both smoke tests and GitHub Actions workflows.

## ✅ Verification

A passing run looks roughly like this:

```text
✅ PASSED: All 4 checks passed

It looks like you successfully completed this level! 🌟
```

A clean response from the lab, after the swap test has restored the original `flags.json`:

```json
{
  "flagKey": "vision_state",
  "value": "blurry",
  "variant": "blurry",
  "reason": "STATIC",
  "errorCode": null,
  "errorMessage": null,
  "flagMetadata": {}
}
```

If you see `"value": "blurry"` (or `"clouded"`) and `"flagKey": "vision_state"`, the lab is reading the chart and
you're ready for the 🟡 Intermediate level — **Outcome by cohort**.
