# 🟢 Beginner: Broken Echoes

The Echo Server is misbehaving. Both environments seem to be down, and messages are silent. Your mission: investigate
the ArgoCD configuration and restore proper multi-environment delivery.

## ⏰ Deadline

Monday, 15 December 2025 at 10:00 CET
> ℹ️ You can still complete the challenge after this date, but points will only be awarded for submissions before the
> deadline.

## 💬 Join the discussion

Share your solutions and questions in
the [challenge thread](https://community.open-ecosystem.com/t/adventure-01-echoes-lost-in-orbit-easy-broken-echoes/117)
in the Open Ecosystem Community.

## 🎯 Objective

By the end of this level, you should:

- See **two distinct Applications** in the Argo CD dashboard (one per environment)
- Ensure each Application deploys to its **own isolated namespace**
- **Make the system resilient** so changes from outside Git cannot break it
- Confirm that **updates happen automatically** without leaving stale resources behind

## 🧠 What You'll Learn

- How Argo CD ApplicationSets work
- How to reason about templating and sync policies
- How drift detection and self-healing operate in GitOps workflows

## ✅ How to Play

### 1. Fork the Repository

- Click the "Fork" button in the top-right corner of the GitHub repo or
  use [this link](https://github.com/dynatrace-oss/open-ecosystem-challenges/fork).

### 2. Start a Codespace

- From your fork, click the green **Code** button → **Codespaces hamburger menu** → **New with options**.
  ![Create a new Codespace](./images/new-codespace.png)
- Select the **Adventure 01 | 🟢 Beginner (Broken Echoes)** configuration.
  ![Codespace options](./images/codespace-options.png)

> ⚠️ **Important:** The challenge will not work if you choose another configuration (or the default).

### 3. Wait for Infrastructure to Deploy

- Your Codespace will automatically provision a Kubernetes cluster, Argo CD, and the sample app. This usually takes
  around 5 minutes.

> 💡 **Tip:** To check the progress press `Cmd + Shift + P` (or `Ctrl + Shift + P` on Windows/Linux) and search for
`View Creation Log`.

### 4. Access the Argo CD Dashboard

- Open the **Ports** tab in the bottom panel
- Find the Argo CD row (port `30100`) and click the forwarded address

  ![Ports](./images/ports.png)

- Log in using:
  ```
  Username: readonly
  Password: a-super-secure-password
  ```

### 5. Fix the Configuration

- All errors are located in this ApplicationSet:
  ```
  adventures/01-echoes-lost-in-orbit/beginner/manifests/appset.yaml
  ```
- Learn more about [ApplicationSets](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/) and
  the [Application Specification](https://argo-cd.readthedocs.io/en/stable/user-guide/application-specification/) in
  the [ArgoCD docs](https://argo-cd.readthedocs.io/en/stable/user-guide/application-specification/).

> 📦 **About Kustomize:** This challenge uses [Kustomize](https://kustomize.io/) under the hood to manage Kubernetes
> manifests. Kustomize allows us to maintain a **base** set of manifests (deployment, service) and apply
> environment-specific customizations through **overlays** (staging, prod). Each overlay can modify the base
> configuration—like changing replica counts or namespaces—without duplicating YAML. Argo CD automatically detects and
> applies these Kustomize configurations, so you don't need to run Kustomize commands manually. Your focus is on fixing
> the ApplicationSet to properly reference these Kustomize-managed paths.

- After making changes, apply them:
  ```
  kubectl apply -n argocd -f adventures/01-echoes-lost-in-orbit/beginner/manifests/appset.yaml
  ```
  (Run from the repo root)

### 6. Verify Your Solution

Once you think you've solved the challenge, it's time to verify!

#### Run the Smoke Test

Run the provided smoke test script from the repo root:

```bash
adventures/01-echoes-lost-in-orbit/beginner/smoke-test.sh
```

If the test passes, your solution is very likely correct! 🎉

#### Complete Full Verification

For comprehensive validation and to officially claim completion:

1. **Commit and push your changes** to your fork
2. **Manually trigger the verification workflow** on GitHub Actions
3. **Share your success** with
   the [community](https://community.open-ecosystem.com/t/adventure-01-echoes-lost-in-orbit-easy-broken-echoes/117)

> 📖 **Need detailed verification instructions?** Check out the [Verification Guide](../../verification.md) for
> step-by-step instructions on both smoke tests and GitHub Actions workflows.
