# ============================================================================
# District Module
# ============================================================================
# This module provisions the core infrastructure for a CloudHaven district:
# - Storage Vault (GCS Bucket): For storing merchant goods (vault.tf)
# - Ledger Database (Cloud SQL): For tracking inventory (ledger.tf)
#
# Resources are configured with production-ready settings including:
# - Versioning and lifecycle management for storage
# - Automated backups and point-in-time recovery for databases
# - Proper labeling for cost tracking and organization
# ============================================================================

terraform {
  required_version = ">= 1.11.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.0.0, < 8.0.0"
    }
  }
}

# ----------------------------------------------------------------------------
# Local Values
# ----------------------------------------------------------------------------
locals {
  # Location mapping for storage buckets
  # Regions map to multi-regional locations for better availability
  location_map = {
    "europe-west1" = "EU"
    "europe-west3" = "EU"
    "us-central1"  = "US"
  }

  location = local.location_map[var.region]

  # Common labels applied to all resources
  common_labels = {
    district   = var.name
    managed-by = "opentofu"
  }

  # Tier-based configuration mapping
  # Each tier defines appropriate settings for database, storage, and protection
  tier_configs = {
    critical = {
      database_tier       = "db-g1-small"
      database_disk_size  = 50
      vault_storage_class = "STANDARD"
    }
    standard = {
      database_tier       = "db-f1-micro"
      database_disk_size  = 20
      vault_storage_class = "STANDARD"
    }
    minimal = {
      database_tier       = "db-f1-micro"
      database_disk_size  = 10
      vault_storage_class = "NEARLINE"
    }
  }

  # Selected configuration based on the tier variable
  tier_config = local.tier_configs[var.tier]
}


