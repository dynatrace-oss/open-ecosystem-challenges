# ============================================================================
# Vault (Storage Bucket) Tests
# ============================================================================
# Tests for the storage vault resource defined in vault.tf.
# Validates naming, security settings, and tier-based configuration.
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
# Vault names should follow: cloudhaven-{name}-vault
# ============================================================================

run "vault_naming_convention" {
  command = plan

  variables {
    name        = "test-district"
    description = "A test district"
    region      = "europe-west1"
    tier        = "standard"
  }

  assert {
    condition     = google_storage_bucket.vault.name == "cloudhaven-test-district-vault"
    error_message = "Vault name should follow pattern: cloudhaven-{name}-vault"
  }
}

run "vault_naming_with_region" {
  command = plan

  variables {
    name        = "market"
    description = "A marketplace district"
    region      = "europe-west3"
    tier        = "standard"
  }

  assert {
    condition     = google_storage_bucket.vault.name == "cloudhaven-market-vault"
    error_message = "Vault name should be consistent across regions"
  }
}


# ============================================================================
# TIER CONFIGURATION TESTS
# ============================================================================
# Tier affects storage class and deletion protection.
# ============================================================================

run "vault_critical_tier_settings" {
  command = plan

  variables {
    name        = "critical-district"
    description = "A critical district"
    region      = "europe-west1"
    tier        = "critical"
  }

  # Critical tier should use STANDARD storage class
  assert {
    condition     = google_storage_bucket.vault.storage_class == "STANDARD"
    error_message = "Critical tier should use STANDARD storage class"
  }
}

run "vault_minimal_tier_settings" {
  command = plan

  variables {
    name        = "minimal-district"
    description = "A minimal district for testing"
    region      = "europe-west1"
    tier        = "minimal"
  }

  # Minimal tier should use cheaper storage class
  assert {
    condition     = google_storage_bucket.vault.storage_class == "NEARLINE"
    error_message = "Minimal tier should use NEARLINE storage class"
  }
}


# ============================================================================
# SECURITY SETTINGS TESTS
# ============================================================================
# Storage buckets should have security best practices enabled.
# ============================================================================

run "vault_security_settings" {
  command = plan

  variables {
    name        = "security-test"
    description = "Testing security settings"
    region      = "europe-west1"
    tier        = "standard"
  }

  # Uniform bucket-level access should be enabled
  assert {
    condition     = google_storage_bucket.vault.uniform_bucket_level_access == true
    error_message = "Vault should have uniform bucket-level access enabled"
  }

  # Public access prevention should be enforced
  assert {
    condition     = google_storage_bucket.vault.public_access_prevention == "enforced"
    error_message = "Vault should have public access prevention enforced"
  }

  # Versioning should be enabled for data protection
  assert {
    condition     = google_storage_bucket.vault.versioning[0].enabled == true
    error_message = "Vault should have versioning enabled"
  }
}


# ============================================================================
# LOCATION MAPPING TESTS
# ============================================================================
# Regions should be correctly mapped to multi-regional locations.
# ============================================================================

run "vault_location_mapping_eu" {
  command = plan

  variables {
    name        = "location-test"
    description = "Testing location mapping"
    region      = "europe-west1"
    tier        = "standard"
  }

  assert {
    condition     = google_storage_bucket.vault.location == "EU"
    error_message = "europe-west1 should map to EU location"
  }
}

run "vault_location_mapping_us" {
  command = plan

  variables {
    name        = "location-test"
    description = "Testing location mapping"
    region      = "us-central1"
    tier        = "standard"
  }

  assert {
    condition     = google_storage_bucket.vault.location == "US"
    error_message = "us-central1 should map to US location"
  }
}


# ============================================================================
# LABELS TESTS
# ============================================================================
# All resources should have proper labels for organization and cost tracking.
# ============================================================================

run "vault_labels" {
  command = plan

  variables {
    name        = "labels-test"
    description = "Testing resource labels"
    region      = "europe-west1"
    tier        = "critical"
  }

  assert {
    condition     = google_storage_bucket.vault.labels["district"] == "labels-test"
    error_message = "Vault should have district label"
  }


  assert {
    condition     = google_storage_bucket.vault.labels["managed-by"] == "opentofu"
    error_message = "Vault should have managed-by label"
  }

  assert {
    condition     = google_storage_bucket.vault.labels["purpose"] == "merchant-storage"
    error_message = "Vault should have purpose label"
  }
}


# ============================================================================
# OUTPUT TESTS
# ============================================================================
# Verify that vault outputs contain the expected values.
# ============================================================================

run "vault_output_values" {
  command = plan

  variables {
    name        = "output-test"
    description = "Testing outputs"
    region      = "europe-west1"
    tier        = "standard"
  }

  # Verify vault output contains expected name
  assert {
    condition     = output.vault.name == "cloudhaven-output-test-vault"
    error_message = "Vault output should contain correct name"
  }

  # Verify location is mapped correctly
  assert {
    condition     = output.vault.location == "EU"
    error_message = "Vault output should contain correct location"
  }
}

