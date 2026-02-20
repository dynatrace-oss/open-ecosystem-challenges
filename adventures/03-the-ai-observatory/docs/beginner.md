# 🟢 Beginner: Calibrating the Lens

You're a researcher stationed at **Perimeter Alpha** — a remote research outpost on the newly discovered planet
**HB-7742**. Your team of six scientists is protected by a single SecUnit, assigned by the corporation to ensure your
safety during the survey mission.

All station queries flow through **HubSystem** — the station's central AI that handles everything from data analysis
to status reports.

Three weeks into the mission, you notice something odd in your morning diagnostics:

> ⚠️ **BANDWIDTH ALERT**: Communication module usage at **847% above baseline**

Nobody's streaming. Nobody's running large data transfers. The planet surveys are on schedule. So... what's consuming
all that bandwidth?

As the station's systems engineer (someone had to dual-role), you decide to investigate. You've heard about this new
observability protocol — **OpenTelemetry** — that the company has been rolling out. Time to instrument HubSystem and
find out what's really going on.

## 🏗️ Architecture

For this challenge, all AI and observability infrastructure (Ollama, OpenTelemetry Collector, Jaeger) runs inside
Kubernetes, while the **HubSystem runs as a local Python application** (outside the Kubernetes cluster).

**Why this setup?**

- **Focus on instrumentation**: You'll learn OpenTelemetry without wrestling with containers and Kubernetes deployments
  when updating the Hubsystem app
- **Fast iteration**: Edit the Python code, run it, see traces immediately → no build/deploy cycle

## ⏰ Deadline

Sunday, 8 March 2026 at 23:59 CET

> ℹ️ You can still complete the challenge after this date, but points will only be awarded for submissions before the
> deadline.

## 💬 Join the discussion

Share your solutions and questions in
the [challenge thread](https://community.open-ecosystem.com/t/instrument-your-first-llm-adventure-03-beginner-is-live)
in the Open Ecosystem Community.

## 🎯 Objective

By the end of this level, you should:

- **Enable OpenTelemetry instrumentation** for the HubSystem using [**OpenLLMetry**](https://github.com/traceloop/openllmetry)
- **Send OpenLLMetry traces** to the [**OpenTelemetry Collector**](https://opentelemetry.io/docs/collector/) at `http://localhost:30107`
- **See and analyze traces** in [**Jaeger**](https://www.jaegertracing.io/) to find out what causes the high bandwidth usage
- **Provide the correct answer** in `quiz.txt`

## 🧠 What You'll Learn

- How to instrument Python AI applications with [**OpenLLMetry**](https://github.com/traceloop/openllmetry)
- How to analyze traces in [**Jaeger**](https://www.jaegertracing.io/)

## 🧰 Toolbox

Your Codespace comes pre-configured with the following tools to help you solve the challenge:

- `python`: The programming language used for the HubSystem application
- [`kubectl`](https://kubernetes.io/docs/reference/kubectl/): The Kubernetes command-line tool for interacting with
  the cluster
- [`kubens`](https://github.com/ahmetb/kubectx): Fast way to switch between Kubernetes namespaces
- [`k9s`](https://k9scli.io/): A terminal-based UI to interact with your Kubernetes clusters

> ℹ️ **Note:** You shouldn't need to interact with Kubernetes directly for this challenge, as the infrastructure is
> pre-provisioned and managed for you. Focus on the Python code.

## ✅ How to Play

### 1. Start Your Challenge

> 📖 **First time?** Check out the [Getting Started Guide](../../start-a-challenge) for detailed instructions on
> forking, starting a Codespace, and waiting for infrastructure setup.

Quick start:

- Fork the [repo](https://github.com/dynatrace-oss/open-ecosystem-challenges/)
- Create a Codespace
- Select "🔭 Adventure 03 | 🟢 Beginner (Calibrating the Lens)"
- Wait ~10 minutes for the environment to initialize (`Cmd/Ctrl + Shift + P` → `View Creation Log` to view progress)

### 2. Access the Jaeger UI

- Open the **Ports** tab in the bottom panel
- Find the **Jaeger** row (port `30103`) and click the forwarded address
- This is where you will analyze the traces sent by the HubSystem

### 3. Instrument the HubSystem and Solve the Mystery

The HubSystem is currently running "blind". Your task is to add OpenTelemetry instrumentation to reveal what it's doing.

Review the [🎯 Objective](#objective) section to understand what a successful solution looks like.

#### Where to Look

The application code is located in:

```
./hubsystem.py
```

> ℹ️ OpenTelemetry and Jaeger are configured correctly.

Once you can see traces in [Jaeger](#2-access-the-jaeger-ui), find the one responsible for the high bandwidth usage and
inspect its attributes to answer the quiz in `quiz.txt`.

#### How to Run

You can run the application directly from the terminal:

```bash
make hubsystem
```

Interact with the AI to generate some activity, then check Jaeger for traces.

#### Helpful Documentation

- [OpenLLMetry (Traceloop) SDK for Python](https://traceloop.com/docs/openllmetry/getting-started-python)
- [Jaeger](https://www.jaegertracing.io/docs/latest/)

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
4. **Copy this certificate** and paste it into the [challenge thread](https://community.open-ecosystem.com/t/instrument-your-first-llm-adventure-03-beginner-is-live) to claim your victory! 🏆
