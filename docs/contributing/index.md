# Contributing Guide

Thank you for your interest in contributing to Open Ecosystem Challenges!

Whether you're fixing a typo, proposing an adventure idea, or building an entire challenge, your contribution matters.

## Ways to Contribute

| Type                          | Description                                                    | Guide                                               |
|-------------------------------|----------------------------------------------------------------|-----------------------------------------------------|
| ✨ Improvements & Bug Fixes   | Improve docs, enhance challenge setup, fix bugs                | This page                                           |
| 💡 Adventure Ideas            | Propose a new adventure with a full implementation plan        | [Adventure Ideas](adventure-ideas.md)               |
| 🏗️ New Adventures            | Build and implement a full adventure based on an approved idea | [Building Adventures](adventures.md)                |
| 📖 Solution Walkthroughs      | Write a step-by-step guide for a completed challenge           | [Solution Walkthroughs](solution-walkthroughs.md)   |

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). Be respectful and constructive.

## Before You Start

1. **Check existing issues.** Search [open issues](https://github.com/dynatrace-oss/open-ecosystem-challenges/issues) before creating a new one.
2. **Determine if you need an issue:**
      - **Small fixes** (typos, broken links): No issue needed, just open a PR.
      - **Larger improvements & bug fixes**: Open an issue first to discuss.
      - **Adventure ideas**: No issue needed, submit your idea directly as a PR.
      - **New adventures & solution walkthroughs**: Pick up an existing issue.
3. **Claim the issue.** If working on an existing issue, comment to let others know you're on it.

## Local Development Setup

There are two paths depending on what you're working on:

**Working on an adventure?** Use the adventure's devcontainer in GitHub Codespaces. It spins up all required infrastructure (Kubernetes, databases, etc.) automatically. See [Building Adventures](adventures.md) for details.

**Everything else?** Use the default devcontainer. You can run it in [GitHub Codespaces](https://docs.github.com/en/codespaces) or [locally in VS Code](https://code.visualstudio.com/docs/devcontainers/containers).

### Running the Documentation

In the default devcontainer, dependencies are pre-installed. Just run:

```bash
mkdocs serve
```

The docs site will be available at `http://localhost:8000`.

## Pull Request Process

1. **Fork the repository** and create your branch from `main`.
2. **Make your changes** with clear, focused commits.
3. **Test your changes.** Run verification scripts if applicable.
4. **Open a pull request** with a clear description of what you changed and why.
5. **Address feedback.** Maintainers will review and may request changes.

Keep PRs focused. Smaller, single-purpose PRs are easier to review and merge.

## Developer Certificate of Origin (DCO)

This project uses the [Developer Certificate of Origin](https://developercertificate.org/) (DCO). All commits must be signed off to certify that you have the right to submit the code and agree to the DCO terms.

Sign off your commits by adding `-s` to your commit command:

```bash
git commit -s -m "Your commit message"
```

If you've already made commits without signing off, you can amend them:

```bash
git commit --amend -s --no-edit
git push --force-with-lease
```

The DCO is enforced automatically via [cncf/dco2](https://github.com/cncf/dco2). PRs without signed-off commits will be flagged.

## Getting Help

- **Ideas & bugs?** [Open an issue](https://github.com/dynatrace-oss/open-ecosystem-challenges/issues)
- **Questions & discussions?** [Open Ecosystem Community](https://community.open-ecosystem.com/c/challenges)

## License

This project is licensed under the [MIT License](https://github.com/dynatrace-oss/open-ecosystem-challenges/blob/main/LICENSE).

By contributing, you agree that your contributions will be licensed under the same MIT License.

## Thank You

Every contribution helps make these challenges better for the community. We appreciate your time and effort!