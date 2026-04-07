# Adventure Idea: ⚖️ Lex Imperfecta

## Overview

**Theme:** The Roman Republic has built a sophisticated legal system to protect its citizens — but the laws were written
in haste, and the exceptions were written too generously. Policies go unenforced, the wrong citizens are exempt, and
something has slipped through the gates unnoticed. As a newly appointed Praetor, your mission is to restore order before
chaos takes hold.

**Skills:**

- Enforce cluster security policies with admission control
- Manage and organize policies at scale across teams and environments
- Respond to runtime threats that bypass static policies

**Technologies:** Kyverno, Falco, Policy Reporter, Argo CD, Kubernetes

---

## Levels

### 🟢 Beginner: The Twelve Tables

#### Description

Fix broken Kyverno policies to restore proper admission control.

#### Story

The Republic's legal scholars have been busy — perhaps too busy. In their haste to codify the Twelve Tables, the foundation of the Republic's legal system, they introduced errors that now threaten the city's order. Workloads that should be blocked are running freely, and workloads that should be allowed are being turned away at the gates.

Another scholar left a note: "I tried to set up policies for privileged containers and required labels, but something's off — I can't figure out why the wrong things are getting through."

Your mission: investigate the Kyverno policies and restore proper admission control before chaos reaches the city.

#### The Problem

Several Kyverno `ClusterPolicy` resources are misconfigured. They are intended to block non-compliant workloads and allow compliant ones through — but they are failing to do so correctly. Some policies are not enforcing when they should, others are rejecting workloads they should allow.

#### Objective

By the end of this level, the learner should:

- Have all workloads **missing required labels** blocked at admission with a clear policy violation message
- Have all workloads **running as privileged containers** blocked at admission with a clear policy violation message
- Confirm that **all other workloads** deploy and run successfully in the cluster

#### What You'll Learn

- How Kyverno `ClusterPolicies` and `validate` rules work
- The difference between `Audit` and `Enforce` enforcement modes
- How to read and interpret Kyverno policy violations

#### Tools & Infrastructure

- **Tools:** `kubectl`, `kyverno` CLI, `k9s`
- **Infrastructure:** Kubernetes Cluster, Kyverno

---

### 🟡 Intermediate: Governing the Provinces

#### Description

Fix a misconfigured Kyverno policy setup and use Policy Reporter to restore proper governance across teams and namespaces.

#### Story

The Republic has grown. What once was a single city is now a sprawling empire of provinces, each governed by different magistrates with different needs. The legal scholars decided to manage all policies through a central archive — a GitOps system that ensures every province's laws are version-controlled and auditable.

But the migration introduced new chaos. Policies meant for one province are bleeding into another. Some provinces are ungoverned entirely. And the exceptions granted to certain citizens are... not quite right.

Your mission: investigate the policy estate, fix the scoping issues, and ensure each province is governed by the right laws.

#### The Problem

Several Kyverno `ClusterPolicy` and `Policy` resources are misconfigured. They are intended to enforce specific rules across different teams and namespaces — but they are failing to do so correctly. Policies are applying to the wrong provinces, some namespaces are left ungoverned, and exceptions that were meant to be narrow are broader than intended.

#### Objective

By the end of this level, the learner should:

- Have each namespace **governed by its corresponding policy** — policies are named to match their intended namespace
- Have **all namespaces covered** by at least one policy — no province left ungoverned
- Have all **exceptions scoped correctly** so only the intended workloads are exempt
- Confirm that **Policy Reporter shows no unexpected violations** across the cluster

#### What You'll Learn

- How to scope Kyverno policies to specific namespaces and teams
- How to write and manage policy exceptions correctly
- How to use Policy Reporter to audit and debug the policy estate

#### Tools & Infrastructure

- **Tools:** `kubectl`, `argocd` CLI, `kyverno` CLI, `k9s`
- **Infrastructure:** Kubernetes Cluster, Kyverno, Argo CD, Policy Reporter

---

### 🔴 Expert: Quis Custodiet

#### Description

Fix overly broad Kyverno policy exceptions and configure Falco to detect runtime threats that bypass static policies.

#### Story

The Republic is at peace — or so it seems. The Twelve Tables are enforced, the provinces are governed, and the central archive hums with order. The legal scholars are proud of their work.

Then a citizen raises the alarm. A workload is behaving suspiciously — accessing things it shouldn't, doing things that don't add up. You dismiss it at first: the policies are in place, the exceptions were carefully written. Nothing should have gotten through.

But the citizen is right.

Something is running inside the city walls that shouldn't be there. A closer look reveals the truth: an exception granted to a trusted citizen was written too broadly — and someone exploited it. The gates held, but the fine print betrayed the Republic.

Worse still: the Praetorian Guard (Falco) was supposed to be watching. A new patrol system was deployed to detect exactly this kind of threat at runtime — but it was never configured correctly. The guard was blind.

Your mission: trace the breach back to its root cause, harden the exceptions, and configure the Praetorian Guard so the Republic is never caught off guard again.

#### The Problem

The Kyverno policies appear solid, but a policy exception has been scoped too broadly — unintentionally allowing workloads that should be blocked. A Falco installation is present in the cluster and is intended to detect suspicious runtime behavior, but it has not been configured correctly and is failing to raise alerts.

#### Objective

By the end of this level, the learner should:

- Have **identified how the malicious workload bypassed** the policies and have it **blocked at admission**
- Have all **exceptions scoped correctly** so only the intended workloads are exempt
- Have **Falco detecting and alerting** on suspicious runtime behavior in the cluster
- Confirm that **Policy Reporter shows no unexpected violations** across the cluster

#### What You'll Learn

- How overly broad exceptions can silently undermine an otherwise solid policy estate
- How to configure Falco rules to detect runtime threats
- How static admission control and runtime threat detection complement each other

#### Tools & Infrastructure

- **Tools:** `kubectl`, `argocd` CLI, `kyverno` CLI, `falcoctl`, `k9s`
- **Infrastructure:** Kubernetes Cluster, Kyverno, Argo CD, Policy Reporter, Falco