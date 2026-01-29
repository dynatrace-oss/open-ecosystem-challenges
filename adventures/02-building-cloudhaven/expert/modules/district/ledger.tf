# ----------------------------------------------------------------------------
# Ledger Database (Cloud SQL PostgreSQL)
# Used for tracking merchant inventory
# ----------------------------------------------------------------------------
resource "google_sql_database_instance" "ledger" {
  name             = "cloudhaven-${var.name}-ledger"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier              = local.tier_config.database_tier
    availability_type = "REGIONAL"
    disk_size         = local.tier_config.database_disk_size
    disk_type         = "PD_SSD"
    disk_autoresize   = true

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "03:00"
      transaction_log_retention_days = 7

      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }

    maintenance_window {
      day          = 7 # Sunday
      hour         = 4 # 4 AM
      update_track = "stable"
    }

    # trivy:ignore:AVD-GCP-0015 ssl_mode is set to ENCRYPTED_ONLY (Trivy bug: https://github.com/aquasecurity/trivy/discussions/9998)
    ip_configuration {
      ipv4_enabled    = false
      private_network = "projects/cloudhaven/global/networks/default"
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    insights_config {
      query_insights_enabled  = true
      query_plans_per_minute  = 5
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }

    user_labels = merge(local.common_labels, {
      purpose = "merchant-ledger"
    })

    deletion_protection_enabled = false
  }

  deletion_protection = false
}
