# 🧪 Adventure 00: Side Effects May Vary

A research lab is testing a vision-enhancement serum on volunteers. The **lab** is a Spring Boot service. **OpenFeature** is the dosing protocol. The formulation in `flags.json` decides which `vision_state` each subject ends up in — `blurry`, `sharp`, `enhanced`, `clouded` — and which experimental amplifier they receive.

The flagship Phase 3 trial — a new vision-amplifier algorithm — has started showing trouble: subjects stabilise slower, and roughly one in ten emerge **blind**. The dashboard that should be tracking all of this is dark, because the lab forgot to wire the metric exporter. Your mission across three levels: **stand up the lab**, **dose subjects by cohort**, then **turn on the lights and roll back the trial** before more subjects lose their sight.

The entire **infrastructure is pre-provisioned in your Codespace**.
**You don't need to set up anything locally. Just focus on solving the problem.**

## 🪐 The Backstory

OpenFeature is a vendor-neutral standard for feature flags. The reference cloud-native implementation is **flagd** — it serves flag definitions from a JSON file, locally or remotely, and the OpenFeature SDK in your application calls it on every evaluation.

In this adventure, the lab uses OpenFeature exactly the way a real engineering team would: a Spring Boot service holds the SDK client, flagd holds the flag definitions, and the dosing rules in `flags.json` decide what every subject receives. By the end, you'll have wired the SDK in from scratch, learned to dose subjects by cohort, and rolled back a misbehaving Phase 3 trial without redeploying.

## 🎮 Choose Your Level

Each level is a standalone challenge with its own Codespace that builds on the story while being technically independent — pick your level and start wherever you feel comfortable.

### 🟢 Beginner: Stand up the lab

- **Status:** 🚧 Coming Soon
- **Topics:** OpenFeature Java SDK, flagd file mode, Spring Boot

Wire OpenFeature into a Spring Boot service so the lab's `vision_state` reading comes from a flag file instead of a hard-coded literal.

[**Start the Beginner Challenge**](./beginner.md){ .md-button .md-button--primary }

### 🟡 Intermediate: Dose by cohort

- **Status:** 🚧 Coming Soon
- **Topics:** OpenFeature targeting, transaction context, hooks, Spring `HandlerInterceptor`

Add request-scoped context, a global runtime context, and an audit hook so the lab doses the right formulation per subject cohort and records every reading.

[**Start the Intermediate Challenge**](./intermediate.md){ .md-button .md-button--primary }

### 🔴 Expert: Phase 3 — read the chart

- **Status:** 🚧 Coming Soon
- **Topics:** Remote flagd, OpenTelemetry traces + metrics, Grafana LGTM, fractional rollout, OpenFeature OTel hooks

Replace file-mode flagd with a remote container, finish wiring OpenTelemetry through to the Grafana LGTM stack, find the misbehaving Phase 3 amplifier in the dashboard, and roll it back without redeploying.

[**Start the Expert Challenge**](./expert.md){ .md-button .md-button--primary }
