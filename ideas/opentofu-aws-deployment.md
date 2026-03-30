# Adventure Idea: Infrastructure as Code with OpenTofu

## Overview

**Theme:** You're a DevOps engineer at "GreenCloud," a sustainable hosting provider. The infrastructure team manually creates cloud resources, leading to inconsistent configurations and slow deployments. Your mission is to standardize infrastructure provisioning using Infrastructure as Code.

**Skills:**

- Write and apply Infrastructure as Code configurations
- Manage cloud resources using OpenTofu
- Implement reusable infrastructure modules
- Handle state management securely

**Technologies:** OpenTofu, AWS (or cloud provider), Git

**Levels:**

- 🟢 Beginner: Automate cloud infrastructure deployment with OpenTofu

---

## Levels

### 🟢 Beginner: Automate Cloud Infrastructure

#### Story

GreenCloud's infrastructure team spends hours manually creating VPCs, EC2 instances, and databases for each new project. Configurations vary between projects, making it hard to debug issues. Your challenge is to create repeatable, version-controlled infrastructure templates.

#### The Problem

You need to deploy a standard web application stack: a VPC with public/private subnets, a PostgreSQL database, and EC2 instances running the application. Currently, this takes a day of manual work. Your goal is to write OpenTofu configurations that deploy this stack with a single command.

#### Objective

By the end of this level, the learner should:

- Deploy a complete VPC with subnets and internet gateway using `tofu apply`
- Verify that the RDS database is created in private subnets
- Confirm EC2 instances are launched with the correct security groups
- Successfully destroy all resources with `tofu destroy` to avoid ongoing costs

#### What You'll Learn

- Infrastructure as Code concepts and benefits
- OpenTofu syntax and workflow (init, plan, apply, destroy)
- Managing cloud resources with code
- Variables and outputs for reusable configurations
- State management basics

#### Tools & Infrastructure

- **Tools:** OpenTofu, AWS CLI (or cloud provider CLI), git
- **Infrastructure:** AWS Free Tier account (or equivalent), local development environment
