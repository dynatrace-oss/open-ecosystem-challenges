# ============================================================================
# Ledger (Cloud SQL Database) Tests
# ============================================================================
# Tests for the ledger database resource defined in ledger.tf.
# Validates naming, tier-based sizing, and production-ready settings.
#
# Run tests from the module directory:
#   cd modules/district && tofu test
# ============================================================================

mock_provider "google" {
  # Mock provider for plan-only tests - no actual API calls needed
}

# ============================================================================

# ============================================================================
# NAMING CONVENTION TESTS
# ============================================================================
# Ledger names should follow: cloudhaven-{name}-ledger
# ============================================================================

run "ledger_naming_convention" {
  command = plan

  variables {
    name        = "test-district"
    description = "A test district"
    region      = "europe-west1"
    tier        = "standard"
  }

  assert {
    condition     = google_sql_database_instance.ledger.name == "cloudhaven-test-district-ledger"
    error_message = "Ledger name should follow pattern: cloudhaven-{name}-ledger"
  }
}

run "ledger_naming_with_region" {
  command = plan

  variables {
    name        = "market"
    description = "A marketplace district"
    region      = "europe-west3"
    tier        = "standard"
  }

  assert {
    condition     = google_sql_database_instance.ledger.name == "cloudhaven-market-ledger"
    error_message = "Ledger name should be consistent across regions"
  }
}


# ============================================================================
# TIER CONFIGURATION TESTS
# ============================================================================
# Tier affects database instance size, and disk size.
# ============================================================================

run "ledger_critical_tier_settings" {
  command = plan

  variables {
    name        = "critical-district"
    description = "A critical district"
    region      = "europe-west1"
    tier        = "critical"
  }

  # Critical tier should use larger database instance
  assert {
    condition     = google_sql_database_instance.ledger.settings[0].tier == "db-g1-small"
    error_message = "Critical tier should use db-g1-small database tier"
  }

  # Critical tier should have larger disk
  assert {
    condition     = google_sql_database_instance.ledger.settings[0].disk_size == 50
    error_message = "Critical tier should have 50GB disk size"
  }
}

run "ledger_standard_tier_settings" {
  command = plan

  variables {
    name        = "standard-district"
    description = "A standard district"
    region      = "europe-west1"
    tier        = "standard"
  }

  # Standard tier should use smaller database instance
  assert {
    condition     = google_sql_database_instance.ledger.settings[0].tier == "db-f1-micro"
    error_message = "Standard tier should use db-f1-micro database tier"
  }

  # Standard tier should have moderate disk
  assert {
    condition     = google_sql_database_instance.ledger.settings[0].disk_size == 20
    error_message = "Standard tier should have 20GB disk size"
  }
}

run "ledger_minimal_tier_settings" {
  command = plan

  variables {
    name        = "minimal-district"
    description = "A minimal district for testing"
    region      = "europe-west1"
    tier        = "minimal"
  }

  # Minimal tier should use smallest database instance
  assert {
    condition     = google_sql_database_instance.ledger.settings[0].tier == "db-f1-micro"
    error_message = "Minimal tier should use db-f1-micro database tier"
  }

  # Minimal tier should have smallest disk
  assert {
    condition     = google_sql_database_instance.ledger.settings[0].disk_size == 10
    error_message = "Minimal tier should have 10GB disk size"
  }
}


# ============================================================================
# DATABASE CONFIGURATION TESTS
# ============================================================================
# Database should be configured with production-ready settings.
# ============================================================================

run "ledger_database_settings" {
  command = plan

  variables {
    name        = "database-test"
    description = "Testing database settings"
    region      = "europe-west1"
    tier        = "standard"
  }

  # Should use PostgreSQL 15
  assert {
    condition     = google_sql_database_instance.ledger.database_version == "POSTGRES_15"
    error_message = "Ledger should use PostgreSQL 15"
  }

  # Should use SSD disk for performance
  assert {
    condition     = google_sql_database_instance.ledger.settings[0].disk_type == "PD_SSD"
    error_message = "Ledger should use SSD disk"
  }

  # Should have backups enabled
  assert {
    condition     = google_sql_database_instance.ledger.settings[0].backup_configuration[0].enabled == true
    error_message = "Ledger should have backups enabled"
  }

  # Should have point-in-time recovery enabled
  assert {
    condition     = google_sql_database_instance.ledger.settings[0].backup_configuration[0].point_in_time_recovery_enabled == true
    error_message = "Ledger should have point-in-time recovery enabled"
  }
}


# ============================================================================
# LABELS TESTS
# ============================================================================
# Database should have proper labels for organization and cost tracking.
# ============================================================================

run "ledger_labels" {
  command = plan

  variables {
    name        = "labels-test"
    description = "Testing resource labels"
    region      = "europe-west1"
    tier        = "critical"
  }

  assert {
    condition     = google_sql_database_instance.ledger.settings[0].user_labels["district"] == "labels-test"
    error_message = "Ledger should have district label"
  }


  assert {
    condition     = google_sql_database_instance.ledger.settings[0].user_labels["managed-by"] == "opentofu"
    error_message = "Ledger should have managed-by label"
  }

  assert {
    condition     = google_sql_database_instance.ledger.settings[0].user_labels["purpose"] == "merchant-ledger"
    error_message = "Ledger should have purpose label"
  }
}


# ============================================================================
# OUTPUT TESTS
# ============================================================================
# Verify that ledger outputs contain the expected values.
# ============================================================================

run "ledger_output_values" {
  command = plan

  variables {
    name        = "output-test"
    description = "Testing outputs"
    region      = "europe-west1"
    tier        = "standard"
  }

  # Verify connection_name attribute exists (will be computed after apply)
  assert {
    condition     = output.ledger.connection_name != null || can(output.ledger.connection_name)
    error_message = "Ledger output should contain connection_name attribute"
  }

  # Verify database version is included
  assert {
    condition     = output.ledger.database_version == "POSTGRES_15"
    error_message = "Ledger output should contain correct database_version"
  }
}

