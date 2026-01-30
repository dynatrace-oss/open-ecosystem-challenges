# 🌆️ Adventure 02: Building CloudHaven

Welcome to the second adventure in the **Open Ecosystem Challenge** series!  
Your mission: modernize CloudHaven's infrastructure from manual provisioning to a self-service platform.  
This is a hands-on journey through infrastructure as code with **OpenTofu** and **GitHub Actions**.

The entire **infrastructure is pre-provisioned in your Codespace** — OpenTofu and
mock cloud services are ready to go when you need them.
**You don't need to set up anything locally. Just focus on solving the problem.**

## 🏗️ The Backstory

Welcome to CloudHaven, a bustling digital metropolis where every district depends on essential services to thrive.
You've just joined the Infrastructure Guild, a team of platform engineers responsible for providing the tools and
services that keep the city running.

CloudHaven is expanding rapidly. The Merchant's Quarter needs storage vaults for their goods and ledgers for tracking
inventory. The Scholar's District requires secure archives for ancient texts. The Artisan's Quarter demands workshops
with specialized tools. Each district has unique needs, but they all depend on the Guild to provide reliable, scalable
infrastructure services.

The Guild used to provision everything manually through cloud consoles — a process that was slow, error-prone, and
impossible to track. Recently, they've started adopting Infrastructure as Code, but the transition is incomplete.

The Guild Master has assigned you to complete the modernization journey.

**Your mission: Build the services and tools that will support CloudHaven's future growth.**

## 🎮 Choose Your Level

Each level is a standalone challenge with its own Codespace that builds on the story while being technically
independent — pick your level and start wherever you feel comfortable!

> 💡 Not sure which level to choose? [Learn more about levels](/#how-it-works)

### 🟢 Beginner: The Foundation Stones

**Status:** ✅ Available  
**Topics:** [OpenTofu](https://opentofu.org/), Remote State, Dynamic Resources

The Guild needs essential services: storage vaults for merchant goods, ledger systems for tracking inventory, and
eventually an audit archive to monitor trade across districts. A previous Guild engineer started provisioning these
services using OpenTofu but left before finishing. The state is stored locally, making collaboration impossible, and
some services remain half-configured or misconfigured.

Your mission: Complete the OpenTofu configuration and establish proper state management.

[**Start the Beginner Challenge**](./beginner.md){ .md-button .md-button--primary }

### 🟡 Intermediate: The Modular Metropolis

**Status:** ✅ Available  
**Topics:** [OpenTofu](https://opentofu.org/), Modules, Testing, Input Validation

CloudHaven is thriving after you fixed the Foundation Stones! The city has grown to three districts, and the Guild 
decided to refactor the infrastructure into reusable modules. A senior engineer started the work using Test-Driven 
Development — writing tests first, then implementing. But they were called away before finishing, leaving behind 
working tests... and buggy code that doesn't match them.

Your mission: Fix the bugs, complete the integration test, and deploy the infrastructure.

[**Start the Intermediate Challenge**](./intermediate.md){ .md-button .md-button--primary }

### 🔴 Expert: The Guardian Protocols

**Status:** ✅ Available  
**Topics:** GitHub Actions, OpenTofu Plan/Apply, Security Scanning (Trivy)

CloudHaven needs automated guardians: workflows that detect infrastructure drift, validate pull requests with plans,
integration tests, and security scans, and then apply safe changes. A previous engineer started the setup but left it
incomplete. Your mission: bring the Guardian Protocols online.

[**Start the Expert Challenge**](./expert.md){ .md-button .md-button--primary }
