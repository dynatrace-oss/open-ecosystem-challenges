# 🟡 Intermediate: The Modular Metropolis

After fixing the Foundation Stones, CloudHaven is thriving! The city has grown to three districts, and the Guild decided
to refactor the infrastructure into reusable modules. A senior engineer started the work using Test-Driven Development -
writing tests first, then implementing. But they were called away before finishing, leaving behind working tests... and
buggy code that doesn't match them. Your mission: fix the bugs, complete the integration test, and deploy the
infrastructure.

## ⏰ Deadline

Wednesday, 4 February 2026 at 23:59 CET

> ℹ️ You can still complete the challenge after this date, but points will only be awarded for submissions before the
> deadline.

## 💬 Join the discussion

Share your solutions and questions in
the [challenge thread](https://community.open-ecosystem.com/t/adventure-02-building-cloudhaven-intermediate-the-modular-metropolis)
in the Open Ecosystem Community.

## 🎯 Objective

By the end of this level, you should have:

- **All tests of the districts module pass**
- **A completed integration test** that applies infrastructure against the mock GCP API to verify end-to-end
  functionality
- **Three districts deployed** with correctly configured infrastructure (vaults and ledgers)

> ℹ️ **Important:** The tests are correct - they define the expected behavior. Your job is to fix the implementation to
> match what the tests expect. Don't modify existing tests unless a comment tells you to; let the tests guide your fixes.

## 🧠 What You'll Learn

- OpenTofu module structure & testing with `tofu test`
- Test-Driven Development (TDD) workflow
- Input validation
- How to use the `moved` block for refactoring infrastructure

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

- Fork the [repo](https://github.com/dynatrace-oss/open-ecosystem-challenges/)
- Create a Codespace
- Select "🌆 Adventure 02 | 🟡 Intermediate (The Modular Metropolis)"
- Wait ~2 minutes for the environment to initialize (`Cmd/Ctrl + Shift + P` → `View Creation Log` to view progress)

### 2. Access the GCP API Mock UI

- Open the **Ports** tab in the bottom panel
- Find the **GCP API Mock** row (port `30104`) and click the forwarded address
- This UI lets you explore the mock cloud resources (buckets, databases) created by your OpenTofu configuration

### 3. Fix the Configuration

The Guild's senior engineer started refactoring the infrastructure into modules but left before finishing. The tests
are failing, and the configuration has bugs.

Review the [🎯 Objective](#objective) section to understand what a successful solution looks like.

#### Where to Look

All OpenTofu files are located in:

```
adventures/02-building-cloudhaven/intermediate/
├── main.tf                    # Provider and backend configuration
├── variables.tf               # Input variables
├── districts.tf               # Module calls for each district
├── outputs.tf                 # Infrastructure outputs
├── moved.tf                   # Resource migration blocks
├── modules/district/          # The district module (fix bugs here)
│   ├── main.tf                # Locals and tier configuration
│   ├── variables.tf           # Input validation
│   ├── vault.tf               # Storage bucket resource
│   ├── ledger.tf              # Cloud SQL resource
│   ├── outputs.tf             # Module outputs
│   └── tests/                 # Module tests (read these!)
└── tests/
    └── integration.tftest.hcl # Complete this test
```

> 💡 **Tip:** Run `make test` to see which tests fail and start fixing bugs.

#### Apply Your Changes

After making your fixes:

```bash
make test      # Run all tests - should pass
make apply     # Apply infrastructure to mock GCP API
```

#### Helpful Documentation

- [Testing](https://opentofu.org/docs/cli/commands/test/)
- [Modules](https://opentofu.org/docs/language/modules/)
- [Input Validation](https://opentofu.org/docs/language/values/variables/#custom-validation-rules)
- [Moved Blocks](https://opentofu.org/docs/language/modules/develop/refactoring/)

### 4. Verify Your Solution

Once you think you've solved the challenge, it's time to verify!

#### Run the Smoke Test

Run the provided smoke test script from the challenge directory:

```bash
./smoke-test.sh
```

If the test passes, your solution is very likely correct! 🎉

#### Complete Full Verification

For comprehensive validation and to officially claim completion:

1. **Commit and push your changes** to your fork
2. **Manually trigger the verification workflow** on GitHub Actions
3. **Share your success** with the [community](https://community.open-ecosystem.com/t/adventure-02-building-cloudhaven-intermediate-the-modular-metropolis)

> 📖 **Need detailed verification instructions?** Check out the [Verification Guide](../../verification) for
> step-by-step instructions on both smoke tests and GitHub Actions workflows.
