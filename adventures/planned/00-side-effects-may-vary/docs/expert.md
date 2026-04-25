# 🔴 Expert: Phase 3 — read the chart

The trial just went wide. Phase 3 of the new vision amplifier —
`vision_amplifier_v2` — was approved for the full cohort yesterday morning.
The promise was straightforward: subjects emerge with sharper eyesight than
they walked in with. By mid-afternoon the audit log was screaming. Subjects
were stabilising 200ms slower, and roughly one in ten of them was emerging
**blind** — containment failure recorded as an HTTP 500. The lab director
pulled up the **Feature Flag Metrics** dashboard expecting to triage
visually. The dashboard was dark. Someone had wired up traces but never
finished the metrics half. There is no chart to read. The lab is studying
eyesight and the lab itself cannot see.

That is the situation you walk into. The Spring Boot app is up, flagd is up,
the Grafana LGTM container is up, a k6 load generator is sitting idle waiting
to be turned on. Spans are flowing into Tempo from the OpenTelemetry
`TracesHook`, but the meter provider has no exporter and the OpenFeature
`MetricsHook` was never registered. So while every flag evaluation creates a
trace event, there is no aggregate "evaluations per second" panel, no "variant
distribution" pie, no quick read on which fraction of subjects is on which
amplifier.

Your job, in order: **turn on the lights**, find the bad arm of the trial,
and **halt enrolment** on the amplifier — all without redeploying the lab.
That last constraint is the whole point of feature flags: when a rollout
starts misbehaving in production, you need an operational lever that does
not take twenty minutes to pull. Save the file, watch the dose drop, watch
the 5xx rate fall back to baseline, watch the next batch of subjects walk
out seeing.

The director will accept your work when three things are true: the dashboard
is showing live evaluation metrics, the Phase 3 amplifier is rolled back to
0% on, and the HTTP 5xx rate has dropped back to baseline.

## ⏰ Deadline

Coming Soon
> ℹ️ You can still complete the challenge after this date, but points will only
> be awarded for submissions before the deadline.

## 📝 Solution Walkthrough

> ⚠️ **Spoiler Alert:** The following walkthrough contains the full solution
> to the challenge. We encourage you to try solving it on your own first.
> Consider coming back here only if you get stuck or want to check your
> approach.

If you get stuck, follow the
[step-by-step solution walkthrough](./solutions/expert.md).

## 💬 Join the discussion

Share your solutions and questions in the
[challenge thread](https://community.open-ecosystem.com/c/open-ecosystem-challenges/)
in the Open Ecosystem Community.

## 🏗️ Architecture

Four containers and one Spring Boot process, all on a shared Docker network.

```
┌──────────────────────┐      OTLP/gRPC :4317      ┌────────────────────────┐
│  Spring Boot         │ ────────────────────────▶ │  grafana/otel-lgtm     │
│  fun-with-flags-     │      flag eval + HTTP     │   - Grafana   :3000    │
│  java-spring         │                           │   - Prometheus :9090   │
│  :8080               │                           │   - Tempo     :3200    │
└─────┬────────────────┘                           └─────────▲──────────────┘
      │ OpenFeature SDK :8013                                │ scrape / pull
      │ (RPC mode)                                           │
┌─────▼────────────────┐                           ┌─────────┴──────────────┐
│  flagd               │ ◀──── poll loadgen flag ──│  k6 loadgen            │
│  :8013 (gRPC)        │                           │  HTTP GET /            │
│  :8014 (HTTP eval)   │                           │  with userId param     │
│  flags.json mounted  │                           │                        │
└──────────────────────┘                           └────────────────────────┘
```

## 🎯 Objective

By the end of this level, you should have:

- The OpenTelemetry **meter provider** wired and the OpenFeature **`MetricsHook`** registered
- **At least one trace** for service `fun-with-flags-java-spring` visible in Tempo
- The **`feature_flag_evaluation_requests_total`** counter non-zero in Prometheus
- The **`vision_amplifier_v2`** fractional rollout flipped back to **100% off / 0% on**
- The HTTP 5xx rate over the last minute below **1%**

## 🧠 What You'll Learn

- How the OpenFeature OpenTelemetry hooks (`TracesHook` and `MetricsHook`) join
  flag evaluations to the rest of an application's telemetry without a
  separate ingestion path
- How [`fractional`](https://flagd.dev/reference/custom-operations/fractional-operation/)
  rollout in flagd buckets users by `targetingKey` — same key, same bucket, every
  request — and how to read that bucketing off a dashboard
- How a **flag flip** is a faster operational lever than a redeploy when a
  rollout is misbehaving — the difference between a one-line config change and
  a twenty-minute deployment

## 🧰 Toolbox

Your Codespace comes pre-configured with the following tools:

- [`curl`](https://curl.se/): HTTP client for hitting the lab, flagd, and Prometheus
- [`./mvnw`](https://maven.apache.org/wrapper/): The Maven wrapper to build and run the Spring Boot lab
- A browser pointed at [`http://localhost:3000`](http://localhost:3000) for Grafana (admin / admin)
- [`jq`](https://jqlang.github.io/jq/): Pretty-print and filter JSON from `curl`

flagd, the Grafana LGTM stack, and the k6 loadgen are **sibling devcontainer services** — they come up automatically when the Codespace boots. There is no `docker compose up` step. Inside the workspace they are reachable as `flagd`, `lgtm`, and `loadgen`; on the host they are forwarded to the same `localhost:NNNN` ports that `verify.sh` and the docs assume.

## ✅ How to Play

### 1. Start Your Challenge

> 📖 **First time?** Check out the [Getting Started Guide](../../start-a-challenge)
> for detailed instructions on forking, starting a Codespace, and waiting for
> infrastructure setup.

Quick start:

- Fork the repo
- Create a Codespace
- Select **"Adventure 00 | 🔴 Expert (Phase 3 — read the chart)"**
- Wait ~2-3 minutes for the sibling containers (flagd, Grafana LGTM, k6
  loadgen) to come up. They are part of the devcontainer compose, so they
  start automatically — no `docker compose up` step.
- Once the IDE attaches to the workspace, start the Spring Boot lab yourself
  with `./mvnw spring-boot:run` in the terminal.

### 2. Access the UIs

Open the **Ports** tab in the bottom panel and click through to:

#### Spring Boot lab (Port `8080`)

The application under test. Open `http://localhost:8080/` to get a vision_state reading
back. Add a `userId` query parameter (e.g. `?userId=subject-42`) to give the
fractional rollout a stable bucketing key.

#### Grafana (Port `3000`)

The single window into the LGTM stack. Login is `admin` / `admin` (skip the
"change your password" prompt).

- **Dashboards → Fun With Flags — Feature Flag Metrics** — the dashboard the
  director keeps reloading. Empty for now.
- **Explore → Tempo** — search by service `fun-with-flags-java-spring`
  to see flag evaluations as span events nested inside HTTP request spans.
  Traces work even before you wire up metrics.

#### Prometheus (Port `9090`)

Exposed by the LGTM container. Useful for `curl`-driven debugging:
`curl 'http://localhost:9090/api/v1/query?query=feature_flag_evaluation_requests_total'`.

#### Tempo (Port `3200`)

Tempo's own HTTP API. The `verify.sh` script uses
`http://localhost:3200/api/search?tags=service.name=fun-with-flags-java-spring`
to assert traces are flowing.

#### flagd (Ports `8013` / `8014`)

`8013` is the gRPC RPC port the SDK talks to. `8014` is the HTTP eval port,
which is convenient for CLI checks. Example:

```bash
curl -s -X POST http://localhost:8014/flagd.evaluation.v1.Service/ResolveBoolean \
  -H 'Content-Type: application/json' \
  -d '{"flagKey":"vision_amplifier_v2","context":{"targetingKey":"subject-1"}}' | jq
```

#### OTLP receivers (Ports `4317` / `4318`)

The Spring Boot app exports traces (and, after you finish the wiring, metrics)
to the LGTM stack on `4317` (gRPC) and `4318` (HTTP).

### 3. Implement the Objective

There are three sub-tasks, in order:

#### 3a. Wire the OpenTelemetry meter provider

Open
`adventures/planned/00-side-effects-may-vary/expert/src/main/java/dev/openfeature/demo/java/demo/OpenTelemetryConfig.java`.
The `@Bean` method already calls `AutoConfiguredOpenTelemetrySdk.builder()`,
which produces an `OpenTelemetry` instance with **both** a `SdkTracerProvider`
and a `SdkMeterProvider` — but only the tracer provider has an exporter.
The meter provider is told `otel.metrics.exporter=none`, so any metrics it
records go nowhere.

Flip `otel.metrics.exporter` to `otlp` so the SDK attaches an
`OtlpGrpcMetricExporter`. The cleanest way is to update both the default in
`OpenTelemetryConfig.java` and the value in
`src/main/resources/application.properties`. While you're there, set
`otel.metric.export.interval=10000` so the dashboard updates within ten
seconds of new traffic instead of waiting a minute.

#### 3b. Register `MetricsHook(OpenTelemetry)` on the OpenFeature API

Open `OpenFeatureConfig.java`. The `TracesHook` is already registered;
`MetricsHook` is not. `MetricsHook` needs the `OpenTelemetry` instance to grab
the meter provider, so inject the bean via constructor injection and
`api.addHooks(new MetricsHook(openTelemetry));` next to the `TracesHook` call.

If you compile and run after this step, the **Fun With Flags — Feature Flag
Metrics** dashboard in Grafana stays empty — there is no traffic. Move on.

#### 3c. Turn on the loadgen, find the bad rollout, roll it back

Edit `flags.json` in the expert directory and flip `loadgen_active`'s
`defaultVariant` from `"off"` to `"on"`. flagd watches the file and picks up
changes within a second. The k6 loadgen container has been polling
`loadgen_active` every two seconds — it will notice and start hammering
`http://workspace:8080/` with five virtual users (the workspace service name resolves inside the compose network).

Now open the dashboard. Within ten to fifteen seconds you should see:

- An **evaluations-per-second** panel filling up
- A **variant distribution** pie that is heavily skewed — `vision_amplifier_v2`
  is at **100% on**, which is exactly the misbehaving Phase 3 rollout
- HTTP latency p99 sitting around **200–250ms**, far above the baseline
- An HTTP 5xx rate around **10%**, exactly what the audit log was complaining about

That's the diagnosis: the fractional rollout for `vision_amplifier_v2` is
inverted. The flag definition currently reads:

```json
"fractional": [
  ["off", 0],
  ["on", 100]
]
```

Edit `flags.json` again — flip the percentages so `off` gets `100` and `on`
gets `0`. Save. Within one or two seconds flagd reloads and the loadgen,
which generates a fresh `userId` per request, immediately moves to the safe
bucket. Watch the latency p99 panel collapse back to baseline and the 5xx
rate fall to zero.

**No deploy. No rebuild. No restart of the lab.**

### 4. Verify Your Solution

Once the dashboard is healthy, run the verifier:

```bash
adventures/planned/00-side-effects-may-vary/expert/verify.sh
```

The script asserts the lab, flagd, and LGTM are reachable, that
`vision_amplifier_v2` evaluates to `false` for a probe user, that the
`feature_flag_evaluation_requests_total` Prometheus counter is non-zero, that
Tempo has at least one trace for `fun-with-flags-java-spring`, and that the
HTTP 5xx rate over the last minute is below 1%.

If everything turns green, your solution is solid. 🎉

## ✅ Verification

For comprehensive validation and to officially claim completion:

1. **Commit and push your changes** to your fork
2. **Manually trigger the verification workflow** on GitHub Actions
3. **Share your success** with the
   [community](https://community.open-ecosystem.com/c/open-ecosystem-challenges/)

> 📖 **Need detailed verification instructions?** Check out the
> [Verification Guide](../../verification) for step-by-step instructions on
> both smoke tests and GitHub Actions workflows.
