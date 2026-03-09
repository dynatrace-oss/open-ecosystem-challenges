# Build a New Adventure

Ready to turn an approved idea into a full adventure? This guide walks you through the implementation process.

## Before You Start

- **Pick an approved idea.** Browse [adventure idea issues](https://github.com/dynatrace-oss/open-ecosystem-challenges/issues?q=is%3Aissue+is%3Aopen+label%3A%22adventure+idea%22) and comment to claim one. Have your own idea? [Submit it first](adventure-ideas.md).
- **Read the idea thoroughly.** Understand the story, objectives, and learning outcomes.

## What You'll Build

An adventure consists of:

| Component | Purpose |
|-----------|---------|
| **Challenge files** | The "broken" state participants will fix |
| **Documentation** | Story, objectives, hints, and solution walkthroughs |
| **Devcontainer** | Pre-configured environment with all required infrastructure |
| **Verification script** | Validates solutions and generates completion certificate |

## Adventure Structure

Use `00` as the adventure number during development. When your adventure is scheduled for release, maintainers will assign the final number and move it out of `planned/`.

```
adventures/planned/00-adventure-name/
├── README.md                    # Brief intro + link to docs
├── mkdocs.yaml                  # Navigation for this adventure
├── docs/
│   ├── index.md                 # Adventure introduction
│   ├── beginner.md              # Level guide
│   ├── intermediate.md
│   ├── expert.md
│   └── solutions/
│       ├── beginner.md          # Solution walkthrough
│       ├── intermediate.md
│       └── expert.md
├── beginner/
│   ├── verify.sh                # Verification script
│   └── [challenge files]
├── intermediate/
│   └── ...
└── expert/
    └── ...

.devcontainer/00-adventure-name_01-beginner/
├── devcontainer.json
├── post-create.sh               # Runs once (install tools)
└── post-start.sh                # Runs every start (start services)
```

## Step-by-Step

### 1. Configure the Devcontainer

Start by setting up the environment. Check an existing adventure with a similar setup as a blueprint for what you need. For Kubernetes-based adventures, [Adventure 01](../../adventures/01-echoes-lost-in-orbit/) is a good reference.

Create a devcontainer for each level in `.devcontainer/00-adventure-name_NN-level/` (e.g., `01-beginner`, `02-intermediate`, `03-expert`). The number prefix on levels ensures proper sorting in the GitHub UI.

**devcontainer.json:**
```json
{
  "name": "Adventure 00 | 🟢 Beginner",
  "image": "mcr.microsoft.com/devcontainers/base:bullseye",
  "features": {
    // Add required features (docker, kubectl, etc.)
  },
  "postCreateCommand": "bash .devcontainer/00-adventure-name_01-beginner/post-create.sh",
  "postStartCommand": "bash .devcontainer/00-adventure-name_01-beginner/post-start.sh",
  "forwardPorts": []
}
```

**post-create.sh** runs once when the container is created:
- Install CLI tools
- Pull container images
- Set up one-time configurations

**post-start.sh** runs every time the container starts:
- Start services (databases, clusters, etc.)
- Apply initial state
- Set up port forwarding

**Infrastructure constraints:**

Codespaces run on 2 cores and 8 GB RAM by default. Design your adventure within these limits — avoid memory-hungry workloads running in parallel and prefer lightweight images where possible.

Post-create should finish in under 15 minutes, but aim for well under that.

### 2. Build the Working Solution

Implement the fully working version first. This is what the solved challenge looks like where everything works correctly.

This approach helps you:
- Understand the problem space before designing the challenge
- Ensure the challenge is actually solvable
- Have a reference implementation for the solution walkthrough

### 3. Introduce the Challenges

Work backwards from your working solution to create the "broken" state participants will fix.

Good challenges are:
- **Realistic.** Introduce issues that could happen in real-world scenarios.
- **Discoverable.** Problems should be findable using standard tools and techniques.
- **Focused.** Each issue should teach something from the learning objectives.
- **Solvable.** Don't require knowledge outside what's being taught.

Not sure if a challenge belongs at Beginner, Intermediate, or Expert? See [Calibrating Difficulty](adventure-ideas.md#calibrating-difficulty) for concrete signals and time expectations.

### 4. Write the Documentation

**Level guide (e.g., `docs/beginner.md`):**
- Story context
- Objectives (what success looks like)
- Helpful links to external docs
- No spoilers

See [Adventure 01's beginner level](../../adventures/01-echoes-lost-in-orbit/docs/beginner.md) for a good example.

**MkDocs configuration (`mkdocs.yaml`):**
```yaml
site_name: '00: Adventure Name'

nav:
  - Introduction: index.md
  - 'Beginner': beginner.md
  - 'Intermediate': intermediate.md
  - 'Expert': expert.md
  - 'Solutions':
      - 'Beginner': solutions/beginner.md
      - 'Intermediate': solutions/intermediate.md
      - 'Expert': solutions/expert.md
```

### 5. Create the Verification Script

Each level needs a `verify.sh` that validates the solution and generates a completion certificate.

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/scripts/loader.sh"

# Your validation logic here using shared helpers
# Browse lib/scripts/ to see what's available

# On success, generate certificate
check_submission_readiness "adventure-name" "level"
```

A good verification script:
- Passes when the challenge is solved correctly
- Fails with helpful error messages when not solved
- Generates a certificate users can copy to claim completion

**Check outcomes, not implementation.** Verify the state the participant should have reached — a service is healthy, traces are present in Jaeger, a metric is being collected — not how they got there. File content checks (`check_file_contains`) are a last resort: they break for valid alternative solutions and reward copy-pasting over understanding. If your objective says "see traces in Jaeger", your verification should check that traces exist, not that a specific import was added.

### 6. Final Test Run

Before submitting:

1. **Start fresh.** Open a new Codespace to test the full experience.
2. **Solve the challenge.** Complete it as a participant would.
3. **Run verification.** Ensure `verify.sh` passes when solved and fails when not.
4. **Check all links.** Documentation should be complete and accurate.

## Tips

- **Open a draft PR early.** Get feedback on structure before completing everything.
- **Start with one level.** Get it working before building all three.
- **Test on slow connections.** Codespace startup time matters.
- **Write clear error messages.** Help participants understand what went wrong without giving away the solution.