# 🔭 03: The AI Observatory

Welcome to the third adventure in the **Open Ecosystem Challenge** series!
Your mission: investigate a mysterious bandwidth anomaly at a remote research station by instrumenting its AI system.
This is a hands-on journey through **AI Observability** with **OpenTelemetry**, **OpenLLMetry**, and **Jaeger**.

The entire **infrastructure is pre-provisioned in your Codespace** — Kubernetes cluster, Ollama, and observability tools
are ready to go.
**You don't need to set up anything locally. Just focus on solving the problem.**

## 🪐 The Backstory

You are stationed at **Perimeter Alpha**, a research outpost on the newly discovered planet **HB-7742**. The station is
run by **HubSystem**, a central AI that manages everything from life support to data analysis.

Recently, the station's bandwidth usage has spiked to **847% above baseline**, but no one knows why. As the systems
engineer, it's your job to instrument the AI, trace its activities, and uncover the root cause of the anomaly.

**Your mission: Bring visibility to the station's AI and solve the mystery.**

## 🎮 Choose Your Level

Each level is a standalone challenge with its own Codespace that builds on the story while being technically
independent — pick your level and start wherever you feel comfortable!

> 💡 Not sure which level to choose? [Learn more about levels](/#how-it-works)

### 🟢 Beginner: Calibrating the Lens

- **Status:** ✅ Available
- **Topics:** [OpenTelemetry](https://opentelemetry.io/), [OpenLLMetry](https://github.com/traceloop/openllmetry), [Jaeger](https://www.jaegertracing.io/)

The HubSystem is running "blind". Your mission: instrument the Python application with OpenLLMetry, send traces to the
collector, and use Jaeger to find out what the AI is actually doing.

[**Start the Beginner Challenge**](./beginner.md){ .md-button .md-button--primary }

