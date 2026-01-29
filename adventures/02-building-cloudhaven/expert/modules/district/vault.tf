# ----------------------------------------------------------------------------
# Storage Vaults (Buckets)
# Used for storing merchant goods
# ----------------------------------------------------------------------------
resource "google_storage_bucket" "vault" {
  name                        = "cloudhaven-${var.name}-vault"
  location                    = local.location
  storage_class               = local.tier_config.vault_storage_class
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age                = 90
      with_state         = "ARCHIVED"
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }

  soft_delete_policy {
    retention_duration_seconds = 604800 # 7 days
  }

  labels = merge(local.common_labels, {
    purpose = "merchant-storage"
  })
}