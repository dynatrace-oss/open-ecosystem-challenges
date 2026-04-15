# Build a New Adventure

Ready to turn an approved idea into a full adventure? This guide walks you through the implementation process.

## Before You Start

- **Pick an approved idea.** Browse [open implementation issues](https://github.com/dynatrace-oss/open-ecosystem-challenges/issues?q=is%3Aissue+is%3Aopen+label%3A%22adventure+idea%22) to find unclaimed ideas. Once you pick one, comment on its issue to claim it.
- **Read the idea thoroughly.** Understand the story, objectives, and learning outcomes.
- **Have your own idea?** [Propose it](adventure-ideas.md) — ideas go through review before they're available for implementation.
- **Ready to build?** Once an idea is approved and merged into `ideas/`, it's available via `make new-adventure`.

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

### 1. Scaffold the Files

Run the scaffolding script to generate the skeleton for your adventure level:

```bash
make new-adventure
```

This will prompt you to select an adventure and level, then generate:

- `adventures/planned/00-adventure-name/` — adventure base with `README.md`, `mkdocs.yaml`, and `docs/index.md`
- `adventures/planned/00-adventure-name/docs/<level>.md` — level guide
- `adventures/planned/00-adventure-name/<level>/verify.sh` — verification script skeleton
- `.devcontainer/00-adventure-name_NN-level/` — `devcontainer.json`, `post-create.sh`, `post-start.sh`

Search for `TODO` in the generated files to find everything that needs filling in.

### 2. Configure the Devcontainer

Open the generated `.devcontainer/00-adventure-name_NN-level/` files and fill in the TODOs.

For Kubernetes-based adventures, [Adventure 01](../../adventures/01-echoes-lost-in-orbit/) is a good reference for what features and setup scripts to use.

**post-create.sh** runs once when the container is created:
- Install CLI tools using setup scripts from `lib/` — every script accepts a `--version` flag to pin a specific version. Run any script with `--help` to see available flags and defaults.
- Pull container images
- Set up one-time configurations

Example calls in `post-create.sh`:
```bash
"$REPO_ROOT/lib/kubernetes/init.sh"                                            # use default versions
"$REPO_ROOT/lib/argocd/init.sh" --version v3.5.0                              # pin a version
"$REPO_ROOT/lib/argocd/init.sh" --read-only --version v3.5.0                  # combine flags
"$REPO_ROOT/lib/kubernetes/init.sh" --kubectl-version v1.35.0 --helm-version v4.1.0  # per-tool versions
```

**post-start.sh** runs every time the container starts:
- Start services (databases, clusters, etc.)
- Apply initial state

**Infrastructure constraints:**

Codespaces run on 2 cores and 8 GB RAM by default. Design your adventure within these limits — avoid memory-hungry workloads running in parallel and prefer lightweight images where possible.

Post-create should finish in under 15 minutes, but aim for well under that.

### 3. Build the Working Solution

Implement the fully working version first. This is what the solved challenge looks like where everything works correctly.

This approach helps you:
- Understand the problem space before designing the challenge
- Ensure the challenge is actually solvable
- Have a reference implementation for the solution walkthrough

### 4. Introduce the Challenges

Work backwards from your working solution to create the "broken" state participants will fix.

Good challenges are:
- **Realistic.** Introduce issues that could happen in real-world scenarios.
- **Discoverable.** Problems should be findable using standard tools and techniques.
- **Focused.** Each issue should teach something from the learning objectives.
- **Solvable.** Don't require knowledge outside what's being taught.

Not sure if a challenge belongs at Beginner, Intermediate, or Expert? See [Calibrating Difficulty](adventure-ideas.md#calibrating-difficulty) for concrete signals and time expectations.

### 5. Write the Documentation

Fill in the generated `docs/<level>.md` — it already contains the story, objectives, and learning outcomes from the idea file. Add:
- Architecture overview (how the level is set up)
- UI access instructions with port numbers
- Where to start investigating
- Helpful links to external docs

No spoilers — save those for a `solutions/<level>.md` file.

See [Adventure 01's beginner level](../../adventures/01-echoes-lost-in-orbit/docs/beginner.md) for a good example.

### 6. Create the Verification Script

Fill in the generated `<level>/verify.sh`. It already has the boilerplate wired up — add your checks between the `print_sub_header` and the summary block.

A good verification script:
- Passes when the challenge is solved correctly
- Fails with helpful error messages when not solved
- Generates a certificate users can copy to claim completion

**Check outcomes, not implementation.** Verify the state the participant should have reached — a service is healthy, traces are present in Jaeger, a metric is being collected — not how they got there. File content checks (`check_file_contains`) are a last resort: they break for valid alternative solutions and reward copy-pasting over understanding. If your objective says "see traces in Jaeger", your verification should check that traces exist, not that a specific import was added.

Browse `lib/scripts/` to see the available helper functions.

### 7. Final Test Run

Before submitting:

1. **Start fresh.** Open a new Codespace to test the full experience.
2. **Solve the challenge.** Complete it as a participant would.
3. **Run verification.** Ensure `verify.sh` passes when solved and fails when not.
4. **Check all links.** Documentation should be complete and accurate.

## Tips

- **[Open a draft PR early.](https://github.com/dynatrace-oss/open-ecosystem-challenges/compare)** Get feedback on structure before completing everything.
- **Ship one level at a time.** Each level gets its own PR — start with one, get it working, then build the next. Use `Part of #<tracking-issue>` on all but the last PR, and `Closes #<tracking-issue>` on the final one so the tracking issue closes automatically.
- **Test on slow connections.** Codespace startup time matters.
- **Write clear error messages.** Help participants understand what went wrong without giving away the solution.
