# 🟢 Beginner: The Foundation Stones

The Merchant's Quarter needs essential services, but the previous Guild engineer left the OpenTofu configuration
incomplete and misconfigured. Your mission: Fix the issues, complete the setup, and establish proper infrastructure
management for the Guild.

## ⏰ Deadline

Wednesday, 4 February 2026 at 23:59 CET

> ℹ️ You can still complete the challenge after this date, but points will only be awarded for submissions before the
> deadline.

## 💬 Join the discussion

Share your solutions and questions in
the [challenge thread](https://community.open-ecosystem.com/t/practice-infrastructure-as-code-with-zero-setup-adventure-02-beginner)
in the Open Ecosystem Community.

## 🎯 Objective

By the end of this level, you should:

- Provision **storage vaults and ledger databases** for each district dynamically
- Deploy the **audit database** only when there is more than one district
- Store state remotely in a **GCS backend** following best practices so the Guild can collaborate
- Resolve all **TODOs** in the code and successfully run `tofu apply`

## 🧠 What You'll Learn

- OpenTofu/Terraform basics
- Remote state backends for team collaboration
- Dynamic resource provisioning with `for_each`
- Conditional resources with the brand new `enabled` meta-argument

## 🧰 Toolbox

Your Codespace comes pre-configured with the following tools to help you solve the challenge:

- [`tofu`](https://opentofu.org/): The OpenTofu CLI for infrastructure provisioning
- [`gcp-api-mock`](https://github.com/KatharinaSick/gcp-api-mock): A mock GCP API running locally to simulate cloud
  resources without real cloud costs

> ⚠️ **Note:** The mock API only supports Cloud Storage and Cloud SQL, and only the functions needed for this challenge
> have been properly tested.

## ✅ How to Play

### 1. Start Your Challenge

> 📖 **First time?** Check out the [Getting Started Guide](../../start-a-challenge) for detailed instructions on
> forking, starting a Codespace, and waiting for infrastructure setup.

Quick start:

- Fork the [repo](https://dynatrace-oss.github.io/open-ecosystem-challenges/)
- Create a Codespace
- Select "🌆 Adventure 02 | 🟢 Beginner (The Foundation Stones)"
- Wait ~2 minutes for the environment to initialize (`Cmd/Ctrl + Shift + P` → `View Creation Log` to view progress)

### 2. Access the GCP API Mock UI

- Open the **Ports** tab in the bottom panel
- Find the **GCP API Mock** row (port `30104`) and click the forwarded address
- This UI lets you explore the mock cloud resources (buckets, databases) created by your OpenTofu configuration

### 3. Fix the Configuration

The Merchant's Quarter is waiting for their infrastructure, but the previous engineer left things in a mess. Your task
is to investigate, identify, and fix the issues.

Review the [🎯 Objective](#objective) section to understand what a successful solution looks like. The
[GCP API Mock UI](#2-access-the-gcp-api-mock-ui) can help you explore the resources created by your configuration.

#### Where to Look

All OpenTofu files are located in:

```
adventures/02-building-cloudhaven/beginner/
```

> 💡 **Tip:** Run `grep -r "TODO" .` to find all TODOs left by the previous engineer.

Review the existing files and look for `TODO` comments:

- `main.tf`: Provider and backend configuration
- `state.tf`: State bucket configuration
- `variables.tf`: District definitions
- `merchants.tf`: Resource definitions for vaults and ledgers
- `audit.tf`: Audit database configuration
- `outputs.tf`: Infrastructure outputs

#### Apply Your Changes

After making your fixes, test and apply them using `tofu apply`.

> 💡 **Tip:** If you change the backend configuration, you'll need to run `tofu init -migrate-state` to migrate the
> state to the new backend.

#### Helpful Documentation

- [OpenTofu Documentation](https://opentofu.org/docs/)
- [OpenTofu Meta-Arguments](https://opentofu.org/docs/language/meta-arguments/count/)
- [OpenTofu Backend Configuration](https://opentofu.org/docs/language/settings/backends/configuration/)
- [Google Cloud Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

### 4. Verify Your Solution

Once you think you've solved the challenge, it's time to verify!

#### Run the Smoke Test

Run the provided smoke test script from the repo root:

```bash
./smoke-test.sh
```

If the test passes, your solution is very likely correct! 🎉

#### Complete Full Verification

For comprehensive validation and to officially claim completion:

1. **Commit and push your changes** to your fork
2. **Manually trigger the verification workflow** on GitHub Actions
3. **Share your success** with the [community](TODO)

> 📖 **Need detailed verification instructions?** Check out the [Verification Guide](../../verification) for
> step-by-step instructions on both smoke tests and GitHub Actions workflows.

