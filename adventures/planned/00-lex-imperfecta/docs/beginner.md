# 🟢 Beginner: The Twelve Tables

> **Best suited for:** Platform engineers, SREs, and developers curious about Kubernetes security — no prior Kyverno experience needed, but familiarity with basic `kubectl` and YAML will help.

The Republic's legal scholars have been busy — perhaps too busy. In their haste to codify the Twelve Tables, the foundation of the Republic's legal system, they introduced errors that now threaten the city's order. Workloads that should be blocked are running freely, and workloads that should be allowed are being turned away at the gates.

Another scholar left a note: "I tried to set up policies for privileged containers and required labels, but something's off — I can't figure out why the wrong things are getting through."

Your mission: investigate the Kyverno policies and restore proper admission control before chaos reaches the city.

## 🏗️ Architecture

The defining principle of the Twelve Tables was that Roman law was enforced **at the gates** — before a citizen could act, not after the damage was done. Kubernetes admission control works exactly the same way: Kyverno intercepts every request to create or update a workload and checks it against your policies *before* it reaches the cluster. A misconfigured policy doesn't just fail to enforce — it fails silently, letting non-compliant workloads slip through unnoticed while you assume everything is fine.

That's the situation you've inherited. Your Codespace comes with a Kubernetes cluster and Kyverno pre-installed. Two `ClusterPolicy` resources are already deployed — but both are misconfigured. The policies live in `manifests/policies/`. You will edit them directly and re-apply with `kubectl`.

The pods in `manifests/pods/` are there for reference only — **you don't need to edit them**.

No GitOps, no dashboards — just you, the policies, and the cluster.

## 🎯 Objective

By the end of this level, you should have:

- All workloads **missing the `republic.rome/gens` label** blocked at admission with a clear policy violation message
- All workloads **running as privileged containers** blocked at admission with a clear policy violation message
- Confirmed that **all other workloads** deploy and run successfully in the cluster

## 🧠 What You'll Learn

- How Kyverno [`ClusterPolicies`](https://kyverno.io/docs/writing-policies/) and [`validate`](https://kyverno.io/docs/writing-policies/validate/) rules work
- The difference between [`Audit` and `Enforce`](https://kyverno.io/docs/writing-policies/policy-settings/#validation-failure-action) enforcement modes
- How to write and interpret Kyverno [`deny` conditions](https://kyverno.io/docs/writing-policies/validate/#deny-rules)
- How to use [custom label keys](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) to enforce workload identity standards

## 🧰 Toolbox

Your Codespace comes pre-configured with the following tools:

| Tool | What it's for |
|------|---------------|
| `kubectl` | Apply and inspect cluster resources |
| `kyverno` CLI | Test and lint policies locally before applying |
| `k9s` | Explore cluster resources in a terminal UI |

## ⏰ Deadline

> ℹ️ You can still complete the challenge after this date, but points will only be awarded for submissions before the
> deadline.

## 💬 Join the discussion

Share your solutions and questions in
the [challenge thread](TODO)
in the Open Ecosystem Community.

## ✅ How to Play

### 1. Start Your Challenge

> 📖 **First time?** Check out the [Getting Started Guide](../../start-a-challenge) for detailed instructions on
> forking, starting a Codespace, and waiting for infrastructure setup.

Quick start:

- Fork the [repo](https://github.com/dynatrace-oss/open-ecosystem-challenges/)
- Create a Codespace
- Select "⚖️ Adventure 00 | 🟢 Beginner (The Twelve Tables)"
- Wait a couple of minutes for the environment to initialize (`Cmd/Ctrl + Shift + P` → `View Creation Log` to view progress)

### 2. Explore the Cluster

When your Codespace is ready, four pods are already running — or trying to. Open a terminal and check what's going on:

```bash
kubectl get pods
```

Inspect why a pod was blocked or admitted:

```bash
kubectl describe pod <pod-name>
```

Check the policies that are in place:

```bash
kubectl get clusterpolicies
kubectl get clusterpolicy require-labels -o yaml
kubectl get clusterpolicy no-privileged-containers -o yaml
```

You can also launch **k9s** for a terminal UI view of all cluster resources:

```bash
k9s
```

Navigate to `ClusterPolicy` resources with `:clusterpolicies` to inspect both policies.

### 3. Fix the Policies

Review the [🎯 Objective](#objective) and investigate what's wrong in `manifests/policies/`.

Both broken policies are in `manifests/policies/`. Read them carefully — each has a different kind of misconfiguration.

#### Test Locally with the Kyverno CLI

Before applying to the cluster, you can use the `kyverno` CLI to test your policy changes locally against the workload manifests:

```bash
kyverno apply manifests/policies/require-labels.yaml --resource manifests/pods/missing-labels.yaml
kyverno apply manifests/policies/no-privileged-containers.yaml --resource manifests/pods/privileged.yaml
```

This gives you fast feedback without touching the cluster.

#### Apply to the Cluster

Once you're happy with your changes, re-apply everything:

```bash
make apply
```

This re-applies the policies and re-deploys all workloads so you immediately see the effect of your changes.

#### Helpful Documentation

- [Kyverno Policy Validation](https://kyverno.io/docs/writing-policies/validate/)
- [Kyverno Enforcement Modes](https://kyverno.io/docs/writing-policies/policy-settings/#validation-failure-action)
- [Kyverno Deny Rules](https://kyverno.io/docs/writing-policies/validate/#deny-rules)

### 4. Verify Your Solution

Once you think you've solved the challenge, run the verification script:

```bash
./verify.sh
# or: make verify
```

**If the verification fails:**

The script will tell you which checks failed and give you a hint. Fix the issues and run it again.

**If the verification passes:**

1. The script will check if your changes are committed and pushed.
2. Follow the on-screen instructions to commit your changes if needed.
3. Once everything is ready, the script will generate a **Certificate of Completion**.
4. **Copy this certificate** and paste it into
   the [challenge thread](TODO)
   to claim your victory! 🏆
