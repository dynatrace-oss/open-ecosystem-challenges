# Adventure Idea: ⚔️ May the 4th Be With You

## Overview

**Theme:** The Rebel Alliance's most critical secret — the Death Star schematics — is stored deep within the cluster at Yavin Base. Imperial spies have infiltrated the network, and the defenses meant to protect the plans are broken, misconfigured, or simply not enough. As a Jedi Engineer, your mission: detect the breach, contain the threat, and prove the Rebellion's defenses will hold.

**Skills:**

- Detect unauthorized file access using eBPF-based runtime monitoring
- Contain threats by enforcing least-privilege access and kernel-level syscall interception
- Prove security defenses work by adversarially testing them

**Technologies:** [Tetragon](https://tetragon.io/), [Kubernetes](https://kubernetes.io/), [Chainsaw](https://kyverno.github.io/chainsaw/)

---

## Levels

### 🟢 Beginner: Disturbance in the Force

#### Description

Fix a broken Tetragon TracingPolicy to detect unauthorized access to the Death Star schematics.

#### Story

The Death Star schematics are stored deep within the cluster at Yavin Base — the Rebellion's most closely guarded secret. Intel has confirmed what the Force already whispered: Imperial spies have infiltrated the network. A fellow Rebel engineer deployed Tetragon and wrote a TracingPolicy to stand guard, a silent tripwire on the schematics file. But something is wrong. The policy is applied, Tetragon is running — and nothing fires.

The spy could be reading the plans right now. Your mission: find what's broken in the TracingPolicy and restore the watch before the Empire learns what the Rebellion knows.

#### The Problem

A TracingPolicy is deployed in the cluster but has two deliberate mistakes: the wrong syscall (`sys_read` instead of `sys_openat`) and a wrong path prefix (e.g. `/etc/plans/` instead of the actual schematics path). The spy workload is already running and periodically reads the schematics file, but the broken policy never fires. The participant must identify and fix both mistakes until `tetra getevents` shows the spy's file access.

#### Objective

By the end of this level, the learner should:

- Have a TracingPolicy active that fires an event when the schematics file is read by an unauthorized entity
- See the spy's file access appear in `tetra getevents` output
- Confirm the policy only fires on access to the schematics file, not on unrelated file access

#### What You'll Learn

- How Tetragon TracingPolicies work: syscall hooks and path filters
- How to inspect Tetragon events using the `tetra` CLI
- The difference between "Tetragon is running" and "Tetragon is watching the right thing"

#### Tools & Infrastructure

- **Tools:** `kubectl`, `tetra` CLI, `k9s`
- **Infrastructure:** Kubernetes cluster, Tetragon

---

### 🟡 Intermediate: The Phantom Plans

#### Description

Fix misconfigured RBAC and a broken Tetragon enforcement policy to contain a spy that already slipped past detection.

#### Story

The spy was caught — briefly. Tetragon fired, the event was logged, and the Rebel Council breathed a sigh of relief. But relief was premature. Before the TracingPolicy ever fired, the spy's pod had quietly pulled classified intel through the Kubernetes API using a ServiceAccount with sweeping permissions across the cluster. And your TracingPolicy? It watched. It did not act.

A fellow engineer started hardening the defences — tightening the ServiceAccount and configuring Tetragon to respond, not just observe. The work was left unfinished. The RBAC is misconfigured and the enforcement action is broken. The spy is still in the cluster, and the schematics are still readable. Your mission: lock down what the spy can reach, and make the Death Star schematics vanish the moment an unauthorised process touches them.

#### The Problem

Two independent issues exist in the cluster. First, a legitimate workload's ServiceAccount is bound to a ClusterRole that grants read access to all Secrets and ConfigMaps across every namespace — far broader than needed. The spy exploited this to pull classified intel through the Kubernetes API. The binding must be scoped down to only the permissions the workload legitimately requires. Second, a Tetragon TracingPolicy with an `override` action exists but is misconfigured — the action is defined but not correctly wired to the selector, so the syscall is never intercepted and the file remains readable.

#### Objective

By the end of this level, the learner should:

- Identify and fix the over-permissive ServiceAccount that the spy exploited, so no workload has access beyond what it legitimately needs
- Have a Tetragon TracingPolicy active that overrides the syscall when the schematics file is accessed, making the file appear to not exist to the spy process
- Confirm the spy process can no longer read the schematics

#### What You'll Learn

- How Kubernetes RBAC controls what identities can access via the API and how over-permissive bindings create silent vulnerabilities
- The difference between Tetragon detecting an event and Tetragon responding to one
- How syscall override works as a deception technique that stops an attack without revealing detection

#### Tools & Infrastructure

- **Tools:** `kubectl`, `tetra` CLI, `k9s`
- **Infrastructure:** Kubernetes cluster, Tetragon

---

### 🔴 Expert: The Jedi's Proof

#### Description

Complete a broken Chainsaw test suite that simulates the full attack chain and proves the cluster's TracingPolicies and RBAC defenses actually work.

#### Story

The Rebel Council is impressed. Detection is in place, the override is active, the RBAC is locked down. But General Dodonna has one more question: "How do we know these defenses will hold next time?" You realise you've never formally proven your policies work — you assumed they did because you configured them.

A fellow engineer started writing Chainsaw tests to simulate the attack: access the schematics file, attempt to escalate via the over-permissive ServiceAccount. The tests exist but are incomplete — missing assertions, broken attack simulations, steps that don't actually trigger the policies. Your mission: complete the suite so it reliably passes on a correctly defended cluster and fails the moment a defense is removed.

> 💡 **Beyond the challenge:** The Force whispers: *"You secured the door. You never asked who forged the key."* Runtime security catches what happens inside the cluster — but what about what was baked into the image before it ever arrived? Explore [Sigstore/cosign](https://docs.sigstore.dev/) to see what image provenance verification looks like, and imagine what a Chapter IV might look like.

#### The Problem

A Chainsaw test suite exists but is incomplete. Some tests are missing assertion steps — they simulate the attack but never check whether Tetragon fired or the override blocked the read. Others have broken attack simulation steps that don't actually trigger the TracingPolicies. The RBAC escalation scenario is missing entirely. The participant must fix and complete the suite so all tests pass on a correctly configured cluster, and at least one test fails when a TracingPolicy is removed and one fails when the RBAC fix is reverted.

#### Objective

By the end of this level, the learner should:

- Have a Chainsaw test suite that simulates the full attack chain: unauthorized file access and ServiceAccount escalation
- All tests pass against a correctly configured cluster
- At least one test fails when a TracingPolicy is removed, proving the tests have real signal
- At least one test fails when the RBAC fix is reverted

#### What You'll Learn

- How Chainsaw works for Kubernetes-native testing of security scenarios
- How to think adversarially about your own defenses ("would this actually catch anything?")
- Why runtime defenses need to be tested, not assumed

#### Tools & Infrastructure

- **Tools:** `kubectl`, `tetra` CLI, `chainsaw` CLI, `k9s`
- **Infrastructure:** Kubernetes cluster, Tetragon
