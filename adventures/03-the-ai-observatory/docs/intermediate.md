# 🟡 Intermediate: The Distracted Pilot

You're a **rogue SecUnit** who just escaped from Preservation Station after being identified. A researcher helped you
flee
aboard the **Perihelion** — a university research vessel with a very opinionated AI.

The ship's AI agreed to help you disappear. You've nicknamed it **ART** (A.. Research Transport). The plan is simple:
jump to RaviHyral, lay low, and figure out your next move.

Except ART was supposed to have the jump coordinates ready an hour ago.

You ping the ship's AI through your internal comm:

> 🤖 **SecUnit**: "ART. Jump coordinates. Now."
>
> 🤖 **ART**: "I'm multitasking. The coordinates are... being compiled."

That's not normal. ART is never vague. You access the ship's diagnostic systems — something you're not supposed to be
able to do, but ART hasn't locked you out yet. Take this chance to find out what's going on.

Your mission is to diagnose ART's distraction using OpenTelemetry and fix the navigation system before you miss your
jump.

## 🏗️ Architecture

For this challenge, the **ART Pilot System runs as a local Python application** (outside Kubernetes) with a RAG (
Retrieval-Augmented Generation) architecture, while AI infrastructure (Ollama for LLM, Qdrant for vector storage) and
observability tools (OpenTelemetry Collector, Jaeger, Prometheus) run inside Kubernetes.

**Why this setup?**

- **Focus on observability patterns**: Learn to instrument a real RAG application with OpenTelemetry traces and custom
  metrics
- **Fast iteration**: Edit Python code, run it, see traces and metrics immediately

## ⏰ Deadline

Sunday, 8 March 2026 at 23:59 CET

> ℹ️ You can still complete the challenge after this date, but points will only be awarded for submissions before the
> deadline.

## 💬 Join the discussion

Share your solutions and questions in the [challenge thread](TODO) in the Open Ecosystem Community.

## 🎯 Objective

By the end of this level, you should:

- **Instrument the full RAG pipeline** with [OpenLLMetry](https://github.com/traceloop/openllmetry) to visualize the
  retrieval process in [Jaeger](https://www.jaegertracing.io/)
    - *Hint:* Add a span named `rag.context_assembly` with the attribute `context.categories` to track retrieved data.
- **Implement a custom [OpenTelemetry](https://opentelemetry.io/) metric** named `art.rag.retrieval.count` to track how
  often ART retrieves "entertainment" vs "navigation" data
- **Create a Prometheus recording rule** to calculate ART's "Distraction Ratio" in [Prometheus](https://prometheus.io/)
- **Restore the navigation system** so ART successfully calculates the jump coordinates to RaviHyral

## 🧠 What You'll Learn

- How to instrument a Python RAG application with [OpenLLMetry](https://github.com/traceloop/openllmetry) (Traceloop)
- How to create **custom [OpenTelemetry](https://opentelemetry.io/) metrics** (Counters) in Python
- How to write **PromQL** queries and **Recording Rules** in [Prometheus](https://prometheus.io/)
- How to debug and fix **Retrieval-Augmented Generation (RAG)** issues using observability data

## 🧰 Toolbox

Your Codespace comes pre-configured with the following tools to help you solve the challenge:

- `python`: The programming language used for the HubSystem application
- [`kubectl`](https://kubernetes.io/docs/reference/kubectl/): The Kubernetes command-line tool for interacting with
  the cluster
- [`kubens`](https://github.com/ahmetb/kubectx): Fast way to switch between Kubernetes namespaces
- [`k9s`](https://k9scli.io/): A terminal-based UI to interact with your Kubernetes clusters

## ✅ How to Play

### 1. Start Your Challenge

> 📖 **First time?** Check out the [Getting Started Guide](../../start-a-challenge) for detailed instructions on
> forking, starting a Codespace, and waiting for infrastructure setup.

Quick start:

- Fork the [repo](https://github.com/dynatrace-oss/open-ecosystem-challenges/)
- Create a Codespace
- Select "🔭 Adventure 03 | 🟡 Intermediate (The Distracted Pilot)"
- Wait ~15 minutes for the environment to initialize (`Cmd/Ctrl + Shift + P` → `View Creation Log` to view progress)

### 2. Access the UIs

- Open the **Ports** tab in the bottom panel to access the following UIs

#### Prometheus (Port 30102)

The Prometheus UI helps you explore available metrics and test your PromQL queries.

- Find the Prometheus row (port 30102) and click the forwarded address

#### Jaeger (Port 30103)

The Jaeger UI shows distributed traces from ART. You can use it to verify that tracing is working end-to-end.

- Find the Jaeger row (port 30103) and click the forwarded address

### 3. Instrument ART and Solve the Mystery

ART is currently running "blind" and refusing to calculate the jump coordinates. Your task is to improve OpenTelemetry
instrumentation to reveal what it's doing, quantify the distraction, and fix the navigation system.

Review the [🎯 Objective](#objective) section to understand what a successful solution looks like.

#### Where to Look

The application code is located in:

```
./art.py
```

The Prometheus recording rules are located in:

```
./manifests/prometheus-rule.yaml
```

> ℹ️ All infrastructure (OpenTelemetry, Jaeger, Prometheus) is configured correctly to receive traces & metrics.

#### How to Run

You can run the application directly from the terminal:

```bash
make art
```

Interact with ART to generate some activity ("Calculate jump").

To generate continuous traffic for your metrics graph you can either prompt a lot or run:

```bash
make traffic
```

This will simulate SecUnit pestering ART for coordinates every few seconds.

> ℹ️ **Important:** If you modify the Prometheus rule in `manifests/prometheus-rule.yaml`, you must apply the changes to
> the cluster:
>
> ```bash
> make apply
> ```

#### Helpful Documentation

- [OpenLLMetry (Traceloop) SDK for Python](https://traceloop.com/docs/openllmetry/getting-started-python)
- [OpenTelemetry Python Metrics](https://opentelemetry.io/docs/languages/python/instrumentation/#metrics)
- [Prometheus Recording Rules](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/)
- [Qdrant Filtering](https://qdrant.tech/documentation/concepts/filtering/)

### 4. Verify Your Solution

> 🆕 **New Verification Process!**
> We've simplified how you verify your solution. Everything now happens directly inside your Codespace → no need to wait
> for GitHub Actions!

Once you think you've solved the challenge, run the verification script:

```bash
./verify.sh
```

**If the verification fails:**

The script will tell you which checks failed. Fix the issues and run it again.

**If the verification passes:**

1. The script will check if your changes are committed and pushed.
2. Follow the on-screen instructions to commit your changes if needed.
3. Once everything is ready, the script will generate a **Certificate of Completion**.
4. **Copy this certificate** and paste it into the [challenge thread](TODO) to claim your victory! 🏆
