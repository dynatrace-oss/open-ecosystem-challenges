# Propose an Adventure Idea

Have a concept for a new challenge? We'd love to hear it!

Adventure ideas are proposals for new challenges. You don't need to implement anything yet. Just describe what the
adventure could look like and what learners would gain from it.

## Before You Start

- **Check existing ideas.**
  Browse [adventure idea issues](https://github.com/dynatrace-oss/open-ecosystem-challenges/issues?q=is%3Aissue+is%3Aopen+label%3A%22adventure+idea%22)
  and [open PRs](https://github.com/dynatrace-oss/open-ecosystem-challenges/pulls) to avoid duplicates.
- **Focus on actions, not tools.** Frame challenges around what learners will *do* (e.g., "release safely", "observe AI
  systems") rather than tools they'll use (e.g., "Argo Rollouts", "OpenTelemetry").
- **Consider multiple levels.** Three levels (Beginner, Intermediate, Expert) are recommended but not required. Even a
  single well-designed level is valuable.

## What Makes a Good Adventure Idea?

Strong adventure ideas share these qualities:

| Quality             | Description                                                          |
|---------------------|----------------------------------------------------------------------|
| **Action-oriented** | Focuses on what learners will *do*, not just what tools they'll use  |
| **Story-driven**    | Has an engaging narrative that motivates the challenges              |
| **Progressive**     | Multiple levels that build on each other (recommended, not required) |
| **Practical**       | Teaches skills applicable to real-world scenarios                    |
| **Self-contained**  | Can run entirely in a [devcontainer](https://containers.dev/)        |

## Calibrating Difficulty

The 🟢 Beginner / 🟡 Intermediate / 🔴 Expert labels set participant expectations before they start. Getting this right matters — a mislabeled level is frustrating regardless of which direction it's off.

Three levels are recommended but not required. A single well-scoped level or a two-level adventure is perfectly valid.

### What each level feels like

**🟢 Beginner** — Get to know the tool. Participants encounter it for the first time and learn the fundamentals: what it does, how it's configured, and what "working" looks like. The challenge is contained and approachable.

**🟡 Intermediate** — Move into systems thinking. Participants have seen the tool before; now they see how it fits into a broader, more realistic setup. The interesting part is the integration — how things connect, interact, and break in non-obvious ways.

**🔴 Expert** — Something genuinely interesting. Not just "harder" — a qualitatively different challenge that rewards deep understanding. Adventure 01 is the best example: Expert isn't just more configuration, it's a completely different observability layer that ties everything together.

### A quick self-check

Ask: *Could someone who has read the docs but never used this tool in a real project solve this in under an hour?*

- **Yes** → Beginner
- **No — they'd need to understand how two systems interact** → Intermediate
- **No — they'd need to understand the full architecture** → Expert

### One level, a few new concepts

A common mistake is packing too much into a single level. Each level should introduce 2–3 new ideas — not a tour of everything the technology can do.

Adventure 01 is a useful reference: Beginner introduces Argo CD ApplicationSets → Intermediate adds Argo Rollouts and PromQL → Expert adds OpenTelemetry Collector and distributed tracing.

## How to Submit

1. **Create a new file** in `ideas/` named `your-adventure-name.md`
2. **Use the template** below to describe your idea
3. **Open a pull request** with the title `Adventure Idea: Your Adventure Name`

No issue required. Submit your idea directly as a PR.

## Adventure Idea Template

Use this structure for your proposal. The three-level format is recommended but not required. Adjust based on your idea.

```markdown
# Adventure Idea: [Your Adventure Name]

## Overview

**Theme:** [2-3 sentences describing the scenario and what's at stake. Who is the learner in this story?]

**Skills:**

- [Action-oriented skill 1, e.g., "Deploy reliably across multiple environments"]
- [Action-oriented skill 2]
- [Action-oriented skill 3]

**Technologies:** [Tools involved, e.g., Argo CD, Kubernetes, Prometheus]

**Levels:**

- 🟢 Beginner: [One-liner description]
- 🟡 Intermediate: [One-liner description]
- 🔴 Expert: [One-liner description]

---

## Levels

### 🟢 Beginner: [Level Name]

#### Story

[Brief narrative setup for this level]

#### The Problem

[What's broken or misconfigured? Be specific enough for an implementer, but don't reveal the solution.]

#### Objective

By the end of this level, the learner should:

- [Concrete, verifiable outcome 1]
- [Concrete, verifiable outcome 2]
- [Concrete, verifiable outcome 3]

> See **Writing Good Objectives** below the template for guidance on what makes a strong objective.

#### What You'll Learn

- [Specific concept 1]
- [Specific concept 2]
- [Specific concept 3]

#### Tools & Infrastructure

- **Tools:** [CLI tools, e.g., kubectl, argocd CLI]
- **Infrastructure:** [What needs to run, e.g., Kubernetes Cluster, Argo CD]

---

### 🟡 Intermediate: [Level Name]

[Same structure as Beginner]

---

### 🔴 Expert: [Level Name]

[Same structure as Beginner]
```

## Writing Good Objectives

Objectives are verifiable outcomes, not tasks. Write them as the state a participant should reach, not the steps they should follow — specific enough that the verification script can check them directly.

| Task (avoid) | Outcome (aim for) |
|---|---|
| Fix the ApplicationSet | See two distinct Applications in the Argo CD dashboard |
| Add instrumentation | Send traces to the OpenTelemetry Collector at `http://localhost:30107` |

## Example

See [Echoes Lost in Orbit](https://github.com/dynatrace-oss/open-ecosystem-challenges/blob/main/ideas/.implemented/echoes-lost-in-orbit.md)
for a complete example of an implemented adventure idea.

## What Happens Next?

1. **Review.** Maintainers review your idea for fit and feasibility.
2. **Feedback.** We may suggest adjustments or ask clarifying questions.
3. **Approval.** Once approved, your idea becomes available for implementation.
4. **Implementation.** You or another contributor can pick it up and build it.

You're welcome to implement your own idea after approval, but there's no obligation to do so.
