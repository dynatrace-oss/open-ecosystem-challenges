# Adventure Idea: 🧪 Side Effects May Vary

## Overview

**Theme:** A research lab is testing a vision-enhancement serum on volunteers. The serum is supposed to take ordinary eyes and produce sharper, even enhanced sight — useful for observation work. The lab is a Spring Boot service; OpenFeature is the dosing protocol; `flags.json` decides which formulation each subject receives. The flagship Phase 3 trial — a new amplifier algorithm — has started showing trouble: subjects stabilise slower, and roughly one in ten emerge blind. The dashboard that should be tracking all of this is dark, because the lab forgot to wire the metric exporter. Your mission across three levels: stand up the lab, dose subjects by cohort, then turn on the lights and roll back the trial before more subjects lose their sight.

**Skills:**

- Wire OpenFeature into a real application and resolve flags from a configuration file
- Target individual cohorts of subjects with different feature variants and audit every dose in the logs
- Roll out a risky algorithm in measured phases and roll it back from observability data when it misbehaves

**Technologies:** OpenFeature Java SDK, flagd, Spring Boot, Grafana LGTM (Tempo + Prometheus + Loki), Testcontainers

---

## Levels

### 🟢 Beginner: Stand up the lab

#### Description

Wire OpenFeature into a Spring Boot service so the lab's `vision_state` reading comes from a flag file instead of a hard-coded literal.

#### Story

The lab is on its first shift. Every subject who walks in gets the same reading on their chart, no matter the formulation, because the dispenser is not consulting the dosing protocol at all. The lab director has approved the switch: replace the hard-coded literal with an OpenFeature client, point it at flagd in file mode, and let the formulation in `flags.json` decide which `vision_state` is recorded for each subject. While you are at it, prove the lab can change the formulation between doses without restarting the dispenser.

#### The Problem

The Spring Boot starter app has an `IndexController` whose `GET /` returns a string literal. There is no OpenFeature dependency in the `pom.xml`, no provider configured, and no `flags.json` in the working directory. The participant must add the OpenFeature SDK and the flagd contrib provider, configure a `FlagdProvider` in `Resolver.FILE` mode, drop a `flags.json` in the working directory, and switch the controller to call `client.getStringDetails` against the `vision_state` flag.

#### Objective

By the end of this level, the learner should:

- Have `curl http://localhost:8080/` return a `vision_state` reading **resolved from `flags.json`** (not the hard-coded fallback)
- Confirm the response payload includes the OpenFeature evaluation details (variant, reason, value)
- Edit `flags.json` to change the `defaultVariant`, save, and have the **next** request return the new variant **without restarting the app**

#### What You'll Learn

- How an OpenFeature client and provider work together — the SDK is provider-agnostic and the flagd provider plugs in via dependency only
- What `flags.json` looks like for flagd file mode (state, variants, defaultVariant)
- Why hot-reload of the flag file matters operationally — configuration without redeploy

#### Tools & Infrastructure

- **Tools:** `curl`, `./mvnw`, `jq` (optional for prettier output)
- **Infrastructure:** A local Java 21 toolchain. No flagd container in this level; the FILE-mode provider reads the JSON directly.

---

### 🟡 Intermediate: Dose by cohort

#### Description

Add request-scoped context, a global runtime context, and an audit hook so the lab doses the right formulation per subject cohort and records every reading.

#### Story

The trial is widening. Subjects from the German training programme are showing up on the German shift, but the dispenser still hands every one of them the same default formulation — the cohort information is sitting unused on the request. The lab director also wants every reading correlated to the lab generation that produced it, so older lab equipment can be steered to a different formulation without changing the dispenser code. And every dose — every single one — needs an audit log line.

#### The Problem

The dispenser from the Beginner level reads the flag, but the same variant goes out to every request — the OpenFeature client never sees the `language` query parameter, never sees the framework version, and there is no logging hook registered. The flag definition in `flags.json` already has a `language == de` targeting branch and a `springVersion >= 3.0.0` branch, but neither attribute is in the evaluation context yet, so the targeting has nothing to fire on.

#### Objective

By the end of this level, the learner should:

- Have a Spring `HandlerInterceptor` that reads `?language=` from the request and sets it on the OpenFeature transaction context, then clears it after the response
- Have a global evaluation context that carries `springVersion` from `SpringVersion.getVersion()`
- Have a custom `Hook` registered that logs every flag evaluation with the flag key, variant, and reason
- Confirm `curl /?language=de` returns the cohort-targeted variant, `curl /` (no language) returns the lab-era-targeted variant, and the app log shows one hook line per request

#### What You'll Learn

- How OpenFeature's transaction-context propagation works in a thread-per-request server
- The difference between request-scoped context (the cohort) and global eval context (the lab era), and when each is appropriate
- How hooks let you attach cross-cutting behaviour (logging today, observability tomorrow) without modifying every call site

#### Tools & Infrastructure

- **Tools:** `curl`, `./mvnw`, `tail -f` against the app log
- **Infrastructure:** Same Java 21 toolchain. flagd is still in FILE mode — no container yet.

---

### 🔴 Expert: Phase 3 — read the chart

#### Description

Replace file-mode flagd with a remote container, finish wiring OpenTelemetry traces and metrics through to the Grafana LGTM stack, find the misbehaving Phase 3 amplifier in the dashboard, and roll it back without redeploying.

#### Story

The trial just went wide. flagd is now its own container — the lab's dosing protocol runs as a service, not as a JSON file on disk. OpenTelemetry is half-wired: a traces exporter is shipping spans to Tempo, but the meter provider is unconfigured, so the rollout dashboard is dark. And Phase 3 of the new amplifier — `vision_amplifier_v2` — is dosed at 100 percent of subjects. Each dose is now 200 milliseconds slower to stabilise, and roughly one in ten subjects emerges blind. The lab is the lab — it cannot fix what it cannot see. The dashboard is dark.

The director wants three things, in order: the dashboard lit up, the bad phase identified, and the dose rolled back to a safe number — all without redeploying the dispenser.

#### The Problem

The level ships a working dispenser pointed at a remote `flagd` container in `Resolver.RPC` mode, plus a Grafana LGTM container with OTLP receivers on the standard ports. The OpenTelemetry SDK in the app is wired for traces (the OTel `TracesHook` is registered, the exporter writes to Tempo) but the meter provider is not configured, so the OpenFeature `MetricsHook` cannot record. The `flags.json` mounted into the flagd container has `vision_amplifier_v2` with a fractional rollout at 0 percent off / 100 percent on — every subject gets the bad amplifier. The participant must finish the metric-exporter wiring, register `MetricsHook`, observe the latency and 5xx panels (the 5xx is the lab's containment failure for blind subjects), identify which fractional bucket is misbehaving, and edit `flags.json` to flip the percentages back (100 percent off / 0 percent on) while the app keeps running.

#### Objective

By the end of this level, the learner should:

- Have `MetricsHook` registered and the OTel meter provider configured to export to the LGTM stack on `localhost:4317`
- Have **at least one trace** for `fun-with-flags-java-spring` visible in the Grafana **Explore → Tempo** view
- Have the **Fun With Flags — Feature Flag Metrics** dashboard showing live evaluation rate, variant distribution, and latency by variant
- Have `vision_amplifier_v2` rolled back to **0 percent on**, confirmed by reading the flag from flagd's HTTP eval API on `:8014`, and the HTTP 5xx rate dropping below threshold afterwards

#### What You'll Learn

- How the OpenFeature OTel hooks join flag evaluations to the rest of an app's telemetry without a separate ingestion path
- How fractional rollout in flagd buckets subjects by `targetingKey` and how to read the bucketing from a dashboard
- How a flag flip is a faster operational lever than a redeploy when a rollout is misbehaving

#### Tools & Infrastructure

- **Tools:** `curl`, `./mvnw`, `docker compose`, a browser pointed at Grafana on `:3000`
- **Infrastructure:** Java 21 toolchain, `flagd` container on `:8013`/`:8014`, `grafana/otel-lgtm` container on `:3000`/`:4317`/`:4318`, k6 loadgen container driving traffic
