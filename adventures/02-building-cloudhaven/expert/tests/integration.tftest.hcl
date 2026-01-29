# ============================================================================
# Integration Test - Root Configuration
# ============================================================================
# This test applies the infrastructure and verifies district configurations.
# Uses a mock GCP API on port 9000 to avoid conflicts with real infrastructure.
#
# Reference: https://opentofu.org/docs/cli/commands/test/
#
# Run from the expert/ directory:
#   make test-integration
# ============================================================================

provider "google" {
  project = "the-guardian-protocols"
  region  = var.region

  # Point to the TEST mock GCP API (separate instance on port 9000)
  storage_custom_endpoint = "http://localhost:9000/storage/v1/"
  sql_custom_endpoint     = "http://localhost:9000/"

  # Skip authentication since we're using a mock API
  access_token = "a-super-secure-token"
}

# ============================================================================
# Test: Apply Infrastructure and Verify Districts
# ============================================================================
run "apply_districts" {
  command = apply

  # Verify vault names for each district
  assert {
    condition     = output.districts["north-market"].vault.name == "cloudhaven-north-market-vault"
    error_message = "North Market vault name should be 'cloudhaven-north-market-vault'"
  }

  assert {
    condition     = output.districts["south-bazaar"].vault.name == "cloudhaven-south-bazaar-vault"
    error_message = "South Bazaar vault name should be 'cloudhaven-south-bazaar-vault'"
  }

  assert {
    condition     = output.districts["scholars-district"].vault.name == "cloudhaven-scholars-district-vault"
    error_message = "Scholars District vault name should be 'cloudhaven-scholars-district-vault'"
  }

  # Verify tier-based disk sizes
  # standard tier = 20GB
  assert {
    condition     = output.districts["north-market"].ledger.disk_size == 20
    error_message = "North Market (standard tier) should have 20GB disk size"
  }

  # minimal tier = 10GB
  assert {
    condition     = output.districts["south-bazaar"].ledger.disk_size == 10
    error_message = "South Bazaar (minimal tier) should have 10GB disk size"
  }

  # critical tier = 50GB
  assert {
    condition     = output.districts["scholars-district"].ledger.disk_size == 50
    error_message = "Scholars District (critical tier) should have 50GB disk size"
  }

  # There could/should be more assertions here to verify other aspects of the districts but for the challenge this is just fine.
}
