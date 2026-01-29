# District Module

Provisions core infrastructure for a CloudHaven district.

## Resources Created

- **Storage Vault** (GCS Bucket) - For storing merchant goods
- **Ledger Database** (Cloud SQL PostgreSQL) - For tracking inventory

## Usage

```hcl
module "district" {
  source = "./modules/district"

  name        = "north-market"
  description = "Northern marketplace district"
  region      = "europe-west1"
  tier        = "standard"
}
```

## Inputs

| Name        | Description                    | Type   | Required |
|-------------|--------------------------------|--------|----------|
| name        | District identifier            | string | yes      |
| description | District purpose               | string | no       |
| region      | GCP region                     | string | yes      |
| tier        | critical, standard, or minimal | string | no       |

## Outputs

| Name   | Description                                                   |
|--------|---------------------------------------------------------------|
| vault  | Bucket name, url, and location                                |
| ledger | Database connection_name, private_ip, and version (sensitive) |
