# 🔴 Expert: The Noise Filter

You made it to RaviHyral. The Perihelion docked at a small independent research station — Outpost Verada — run by a
loose collective of academics who agreed to look the other way. No questions asked. In exchange, ART offered to share
its observability data with the station's monitoring team. A goodwill gesture.

That was three hours ago. Now the station's lead engineer is at your docking port, looking annoyed.

> 👩‍💻 **Engineer**: "Your ship's AI is flooding our Jaeger instance. Do you have any idea how many spans it's
> generating? We can't find anything in there."
>
> 🤖 **SecUnit**: "ART."
>
> 🤖 **ART**: "Comprehensive telemetry is a feature."
>
> 👩‍💻 **Engineer**: "It's 40,000 spans an hour. Every healthy query. Every token. It doesn't even follow conventions. We
> only care about failures and anomalies — the things that actually need attention."
>
> 🤖 **SecUnit**: "ART. Fix it."
>
> 🤖 **ART**: "...Fine."

The engineer hands you access to the collector config and the application code, then walks away. Two problems to
solve: ART's spans don't follow OTel GenAI semantic conventions and the collector is currently forwarding everything.

> 📚 **Credits**: The characters of this adventure are borrowed from the
> fantastic [Murderbot Diaries series by Martha Wells](https://www.marthawells.com/murderbot.htm)! 🤖❤️
> ️
>
> If you haven't read these books yet, I highly encourage you to do so. It is an absolutely brilliant series: funny,
> action-packed, and surprisingly heartwarming. It follows a security unit that hacked its own governor module and now
> just wants to be left alone to watch media, but keeps getting pulled into human nonsense. It really is a great read!

## 🏗️ Architecture

Same setup as the intermediate level: the **ART Pilot System runs as a local Python application** (outside Kubernetes)
with a RAG (Retrieval-Augmented Generation) architecture, while AI infrastructure (Ollama for LLM, Qdrant for vector
storage) and observability tools (OpenTelemetry Collector, Jaeger) run inside Kubernetes.

## ⏰ Deadline

Sunday, 8 March 2026 at 23:59 CET

> ℹ️ You can still complete the challenge after this date, but points will only be awarded for submissions before the
> deadline.

## 💬 Join the discussion

Share your solutions and questions in
the [challenge thread](TODO)
in the Open Ecosystem Community.

## 🎯 Objective

By the end of this level, you should:

- **Fix ART's `chat` span** to
  follow [OpenTelemetry GenAI semantic conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/gen-ai-spans/) —
  including token usage
- **Configure tail sampling** in the [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/) to only keep
  traces that contain errors or take longer than 5 seconds

## 🧠 What You'll Learn

- How to apply **[OpenTelemetry](https://opentelemetry.io/) GenAI semantic conventions** to LLM spans, including token
  usage attributes
- How to configure **tail sampling** in the [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/) to
  reduce noise and keep only meaningful traces

## 🧰 Toolbox

Your Codespace comes pre-configured with the following tools to help you solve the challenge:

- `python`: The programming language used for the ART application
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
- Select "🔭 Adventure 03 | 🔴 Expert (The Noise Filter)"
- Wait ~15 minutes for the environment to initialize (`Cmd/Ctrl + Shift + P` → `View Creation Log` to view progress)

### 2. Access the UIs

- Open the **Ports** tab in the bottom panel to access the following UIs

#### Jaeger (Port 30103)

The Jaeger UI shows distributed traces from ART. You can use it to verify your spans look correct and that sampling is
working as expected.

- Find the Jaeger row (port 30103) and click the forwarded address

### 3. Fix ART's Telemetry

ART is flooding Jaeger with noisy, non-standard traces. Your task is to fix the instrumentation and configure the
collector to filter out the noise.

Review the [🎯 Objective](#objective) section to understand what a successful solution looks like.

#### Where to Look

The application code is located in:

```
./art.py
```

The OpenTelemetry Collector config is located in:

```
./manifests/otel-collector-config.yaml
```

#### How to Run

Start the traffic simulator to generate traces:

```bash
make traffic
```

This will simulate SecUnit pestering ART for coordinates every few seconds.

> ℹ️ **Important:** After making changes to `art.py`, restart `make traffic` to pick up the new instrumentation.
> After making changes to `manifests/otel-collector-config.yaml`, apply them to the cluster first:
>
> ```bash
> kubectl apply -f manifests/otel-collector-config.yaml -n otel
> kubectl rollout restart deployment/collector -n otel
> ```

If you'd like to interact with ART directly instead, you can run:

```bash
make art
```

#### Helpful Documentation

- [OpenTelemetry GenAI Semantic Conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/gen-ai-spans/)
- [OpenTelemetry Python — Recording Exceptions](https://opentelemetry.io/docs/languages/python/instrumentation/#record-exceptions)
- [Python `contextlib.contextmanager`](https://docs.python.org/3/library/contextlib.html#contextlib.contextmanager)
- [OTel Collector Tail Sampling Processor](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/tailsamplingprocessor)

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
4. **Copy this certificate** and paste it into
   the [challenge thread](TODO)
   to claim your victory! 🏆

