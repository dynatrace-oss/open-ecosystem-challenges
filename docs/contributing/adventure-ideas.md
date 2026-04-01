# Propose an Adventure Idea

Have a concept for a new challenge? We'd love to hear it!

Adventure ideas are proposals for new challenges. You don't need to implement anything yet. Just describe what the
adventure could look like and what learners would gain from it.

## Before You Start

- **Check existing ideas.** Browse [adventure idea issues](https://github.com/dynatrace-oss/open-ecosystem-challenges/issues?q=is%3Aissue+is%3Aopen+label%3A%22adventure+idea%22)
  and [open PRs](https://github.com/dynatrace-oss/open-ecosystem-challenges/pulls) to make sure your idea hasn't already been submitted or is in the pipeline.
- **Focus on actions, not tools.** Frame challenges around what learners will *do* (e.g., "release safely", "observe AI
  systems") rather than tools they'll use (e.g., "Argo Rollouts", "OpenTelemetry").
- **Consider multiple levels.** Three levels (Beginner, Intermediate, Expert) are recommended but not required. Even a
  single well-designed level is valuable.

## How to Submit

1. **Fork** the repository on GitHub
2. **Copy** `ideas/adventure-idea-template.md` and rename it to `ideas/your-adventure-name.md`:
   ```
   cp ideas/adventure-idea-template.md ideas/your-adventure-name.md
   ```
3. **Fill in the template** and commit your changes
4. **[Open a pull request](https://github.com/dynatrace-oss/open-ecosystem-challenges/compare)** with the title `Adventure Idea: [emoji] Your Adventure Name`

No issue required. Submit your idea directly as a PR.

## From Idea to Adventure

After you open a PR:

1. **Review.** Maintainers review your idea for fit and feasibility.
2. **Feedback.** We may suggest adjustments or ask clarifying questions.
3. **Approval.** Once approved and merged, your idea becomes available for implementation via `make new-adventure`.
4. **Implementation.** You or another contributor picks it up, builds it, and the idea moves to `ideas/.implemented/`.

You're welcome to implement your own idea after approval, but there's no obligation to do so.

### Idea Folder Structure

Ideas are organized by their status:

```
ideas/
├── [your-idea].md      # Proposals & approved ideas (submitted via PR)
└── .implemented/       # Completed adventures (reference only)
```

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

The 🟢 Beginner / 🟡 Intermediate / 🔴 Expert labels set participant expectations before they start. Getting this right matters - a mislabeled level is frustrating regardless of which direction it's off.

Three levels are recommended but not required. A single well-scoped level or a two-level adventure is perfectly valid.

### What each level feels like

**🟢 Beginner** - Get to know the tool. Participants encounter it for the first time and learn the fundamentals: what it does, how it's configured, and what "working" looks like. The challenge is contained and approachable.

**🟡 Intermediate** - Move into systems thinking. Participants have seen the tool before; now they see how it fits into a broader, more realistic setup. The interesting part is the integration - how things connect, interact, and break in non-obvious ways.

**🔴 Expert** - Something genuinely interesting. Not just "harder" - a qualitatively different challenge that rewards deep understanding. Adventure 01 is the best example: Expert isn't just more configuration, it's a completely different observability layer that ties everything together.

### A quick self-check

Ask: *Could someone who has read the docs but never used this tool in a real project solve this in under an hour?*

- **Yes** → Beginner
- **No - they'd need to understand how two systems interact** → Intermediate
- **No - they'd need to understand the full architecture** → Expert

### One level, a few new concepts

A common mistake is packing too much into a single level. Each level should introduce 2–3 new ideas - not a tour of everything the technology can do.

Adventure 01 is a useful reference: Beginner introduces Argo CD ApplicationSets → Intermediate adds Argo Rollouts and PromQL → Expert adds OpenTelemetry Collector and distributed tracing.

## Adventure Idea Template

A ready-to-use template is available at [`ideas/adventure-idea-template.md`](https://github.com/dynatrace-oss/open-ecosystem-challenges/blob/main/ideas/adventure-idea-template.md).

Copy it using the command below, fill in the placeholders, and follow the [How to Submit](#how-to-submit) steps above.

```
cp ideas/adventure-idea-template.md ideas/your-adventure-name.md
```

See [Echoes Lost in Orbit](https://github.com/dynatrace-oss/open-ecosystem-challenges/blob/main/ideas/.implemented/echoes-lost-in-orbit.md) for a complete example of a well-written idea.

## Writing Good Objectives

Objectives are verifiable outcomes, not tasks. Write them as the state a participant should reach, not the steps they should follow - specific enough that the verification script can check them directly.

| Task (avoid) | Outcome (aim for) |
|---|---|
| Fix the ApplicationSet | See two distinct Applications in the Argo CD dashboard |
| Add instrumentation | Send traces to the OpenTelemetry Collector at `http://localhost:30107` |

