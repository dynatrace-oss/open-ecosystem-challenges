# Adventure Idea: 🛰️ Echoes Lost in Orbit

## Overview

**Theme:** The Intergalactic Union's communication network is in disarray. The Echo Server has gone silent, a language pack rollout for a new species is failing, and the hyperspace transport system needs robust observability. As an SRE, you'll restore order by fixing GitOps configurations, stabilizing progressive delivery, and building an observability pipeline.

**Skills:**

- Deploy reliably across multiple environments
- Release safely using progressive delivery
- Observe distributed systems with tracing and metrics

**Technologies:** Argo CD, Argo Rollouts, OpenTelemetry, Prometheus, Jaeger, Kubernetes

---

## Levels

### 🟢 Beginner: Broken Echoes

#### Description

Fix a broken multi-environment GitOps setup

#### Story

The Echo Server is misbehaving. Both environments (`staging` and `production`) seem to be down, and messages are silent. The previous engineer left a note saying "I tried to set up this fancy ApplicationSet thing to deploy to both environments at once, but now nothing works."

Your mission: Investigate the Argo CD configuration and restore proper multi-environment delivery.

#### The Problem

The Argo CD `ApplicationSet` is misconfigured. It is intended to dynamically generate two Argo CD Applications (one for staging, one for prod) from a single configuration, but it is failing to do so correctly.

#### Objective

By the end of this level, the learner should:

- See **two distinct Applications** in the Argo CD dashboard (one per environment)
- Ensure each Application deploys to its **own isolated namespace**
- **Make the system resilient** so Argo CD automatically reverts manual changes made to the cluster
- Confirm that **updates happen automatically** without leaving stale resources behind

#### What You'll Learn

- How Argo CD ApplicationSets work
- How to reason about templating and sync policies
- How drift detection and self-healing operate in GitOps workflows

#### Tools & Infrastructure

- **Tools:** `kubectl`, `argocd` CLI, `k9s`
- **Infrastructure:** Kubernetes Cluster, Argo CD

---

### 🟡 Intermediate: The Silent Canary

#### Description

Stabilize a failing canary rollout with metrics-based analysis

#### Story

After fixing the communication outage, the Intergalactic Union welcomed a new species: the Zephyrians. The communications team attempted to deploy their language files using a progressive delivery system, but the rollout is failing. The Zephyrians are still waiting to communicate with the rest of the galaxy.

A previous engineer configured automated canary deployments with health checks but left the setup incomplete. Your mission: debug the broken rollout and bring the Zephyrians' voices online.

#### The Problem

The Argo Rollouts canary deployment is misconfigured. The `AnalysisTemplate` contains broken PromQL queries that prevent the rollout from progressing through its canary stages.

#### Objective

By the end of this level, the learner should:

- Have **version 6.9.3** deployed successfully in both **staging** and **production** environments
- See rollouts **automatically progress** through canary stages based on health metrics
- Have two **working PromQL queries** in the `AnalysisTemplate` that validate application health during releases
- See all rollouts complete successfully

#### What You'll Learn

- How to write PromQL queries to monitor application health
- How progressive delivery reduces deployment risk with automated validation
- How to debug and fix broken canary deployments
- How Argo Rollouts and Prometheus work together for data-driven deployment decisions

#### Tools & Infrastructure

- **Tools:** `kubectl`, `argocd` CLI, `kubectl-argo-rollouts`
- **Infrastructure:** Kubernetes Cluster, Argo CD, Argo Rollouts, Prometheus

---

### 🔴 Expert: Hyperspace Operations & Transport

#### Description

Build an observability pipeline to validate traffic before promoting releases

#### Story

Word of your progressive release mastery spread across the galaxy. The Bytari, a highly advanced species from the Andromeda sector, want to apply progressive delivery to their mission-critical service: HotROD (Hyperspace Operations & Transport - Rapid Orbital Dispatch), an interstellar ride-sharing service handling dispatch requests across thousands of star systems.

A previous engineer started instrumenting HotROD with OpenTelemetry and configured Argo Rollouts for automated validation, but left the setup incomplete. The observability pipeline is broken. The Bytari believe in single-environment progressive delivery validated purely by trace-derived metrics.

Your mission: Fix the observability pipeline and canary validation. Make HotROD deployment-ready with proper distributed tracing.

#### The Problem

The OpenTelemetry Collector pipeline is misconfigured. Traces aren't being converted to metrics correctly, and the canary analysis queries can't validate deployments without proper observability signals.

#### Objective

By the end of this level, the learner should:

- Have **automated rollout progression** to HotROD version `1.76.0` driven by observability signals
- Have **OpenTelemetry Collector** configured with OTLP receiver, spanmetrics connector, and exports to Jaeger and Prometheus
- Have **canary analysis** validating deployments with traffic detection (>= 0.05 req/s), error rate (< 5%), and latency thresholds (p95 < 1000ms)

#### What You'll Learn

- Configure OpenTelemetry Collector pipelines (receivers, connectors, exporters)
- Use the Span Metrics Connector to convert traces into metrics
- Prevent "idle canaries" that deploy successfully but received no traffic
- Integrate distributed tracing for automated rollout decisions
- Write PromQL queries based on trace-derived metrics

#### Tools & Infrastructure

- **Tools:** `kubectl`, `argocd` CLI, `kubectl-argo-rollouts`
- **Infrastructure:** Kubernetes Cluster, Argo CD, Argo Rollouts, OpenTelemetry Collector, Jaeger, Prometheus
