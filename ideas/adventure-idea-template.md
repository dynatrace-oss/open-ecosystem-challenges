# Adventure Idea: [emoji] [Your Adventure Name]

<!-- =========================================================================
  HOW TO USE THIS TEMPLATE
  =========================================================================
  1. Fork the repository on GitHub.
  2. Copy this file:
        cp ideas/adventure-idea-template.md ideas/your-adventure-name.md
  3. Replace every [bracketed placeholder] with your content.
     Keep all formatting (headings, bold labels, etc.) exactly as they appear.
  4. Remove all HTML comments.
  5. Commit your changes and open a pull request with the title:
        Adventure Idea: [emoji] Your Adventure Name
  ========================================================================= -->

## Overview

<!-- Set up the scenario: who is the learner, what went wrong, what's at stake.
     Example: "You're a platform engineer at a fast-growing startup. A bad deploy
     just took down production. Roll back fast and put guardrails in place." -->

**Theme:** [2-3 sentences describing the scenario and what's at stake]

<!-- What learners will DO, not which tools they use.
     Good: "Release safely using progressive delivery"
     Avoid: "Use Argo Rollouts" -->

**Skills:**

- [Action-oriented skill 1, e.g., "Deploy reliably across multiple environments"]
- [Action-oriented skill 2]
- [Action-oriented skill 3]

<!-- Comma-separated. Only include tools participants directly use. -->

**Technologies:** [Tools involved, e.g., Argo CD, Kubernetes, Prometheus]

---

## Levels

<!-- =========================================================================
  Each level is a standalone challenge. Include Beginner, Intermediate,
  and/or Expert - delete any level block you don't need.

  DIFFICULTY GUIDE:
    🟢 Beginner - First encounter. Solvable in under an hour with just the docs.
    🟡 Intermediate - Has used the tool before. Integration and non-obvious failure modes.
    🔴 Expert - Qualitatively harder. Requires deep architectural understanding.

  SECTION GUIDE - each level needs all six #### sections:

  #### Description
    One sentence summarizing what the participant does.
    Example: "Diagnose a broken Argo CD sync and restore a failing deployment."

  #### Story
    Set the scene: who the participant is, what broke, what they need to fix.
    One to two paragraphs.
    Example: "The overnight deploy silently failed. You're the on-call engineer -
    the dashboard is red and the team is waiting."

  #### The Problem
    For the implementer only - never shown to participants.
    Describe exactly what to break or misconfigure in the challenge environment.
    Example: "The ApplicationSet generator uses the wrong path template,
    causing it to generate zero Applications."

  #### Objective
    Describe what success looks like, not what steps to take.
    Good:  "Two Applications appear in the Argo CD dashboard with Synced status"
    Avoid: "Fix the ApplicationSet"

  #### What You'll Learn
    2-3 concepts they'll understand after completing this level.
    Example: "How Argo CD sync waves control rollout order"

  #### Tools & Infrastructure
    Tools: what they run commands against.
    Infrastructure: what must be running in the environment.
  ========================================================================= -->

### 🟢 Beginner: [Level Name]

#### Description

[One sentence describing what the participant will do in this level]

#### Story

[Brief narrative setup for this level]

#### The Problem

[What's broken or misconfigured? Be specific enough for an implementer, but don't reveal the solution.]

#### Objective

By the end of this level, the learner should:

- [Concrete, verifiable outcome 1]
- [Concrete, verifiable outcome 2]
- [Concrete, verifiable outcome 3]

#### What You'll Learn

- [Specific concept 1]
- [Specific concept 2]
- [Specific concept 3]

#### Tools & Infrastructure

- **Tools:** [CLI tools, e.g., kubectl, argocd CLI]
- **Infrastructure:** [What needs to run, e.g., Kubernetes Cluster, Argo CD]

---

### 🟡 Intermediate: [Level Name]

#### Description

[One sentence describing what the participant will do in this level]

#### Story

[Brief narrative setup for this level]

#### The Problem

[What's broken or misconfigured? Be specific enough for an implementer, but don't reveal the solution.]

#### Objective

By the end of this level, the learner should:

- [Concrete, verifiable outcome 1]
- [Concrete, verifiable outcome 2]
- [Concrete, verifiable outcome 3]

#### What You'll Learn

- [Specific concept 1]
- [Specific concept 2]
- [Specific concept 3]

#### Tools & Infrastructure

- **Tools:** [CLI tools, e.g., kubectl, argocd CLI]
- **Infrastructure:** [What needs to run, e.g., Kubernetes Cluster, Argo CD]

---

### 🔴 Expert: [Level Name]

#### Description

[One sentence describing what the participant will do in this level]

#### Story

[Brief narrative setup for this level]

#### The Problem

[What's broken or misconfigured? Be specific enough for an implementer, but don't reveal the solution.]

#### Objective

By the end of this level, the learner should:

- [Concrete, verifiable outcome 1]
- [Concrete, verifiable outcome 2]
- [Concrete, verifiable outcome 3]

#### What You'll Learn

- [Specific concept 1]
- [Specific concept 2]
- [Specific concept 3]

#### Tools & Infrastructure

- **Tools:** [CLI tools, e.g., kubectl, argocd CLI]
- **Infrastructure:** [What needs to run, e.g., Kubernetes Cluster, Argo CD]
