# ============================================================================
# District Module - Outputs
# ============================================================================
# Exposes resource details needed for integration with other systems.
# ============================================================================

# ----------------------------------------------------------------------------
# Storage Vault Output
# ----------------------------------------------------------------------------
output "vault" {
  description = "Storage vault (GCS bucket) details for integration"
  value = {
    name     = google_storage_bucket.vault.name
    url      = google_storage_bucket.vault.url
    location = google_storage_bucket.vault.location
  }
}

# ----------------------------------------------------------------------------
# Ledger Database Output
# ----------------------------------------------------------------------------
output "ledger" {
  description = "Ledger database (Cloud SQL) connection details"
  value = {
    connection_name  = google_sql_database_instance.ledger.connection_name
    database_version = google_sql_database_instance.ledger.database_version
    disk_size        = google_sql_database_instance.ledger.settings[0].disk_size
  }
}
