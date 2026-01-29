# ============================================================================
# Variables Input Validation Tests
# ============================================================================
# Tests for the input validation rules defined in variables.tf.
# Validates that invalid inputs are rejected during plan.
#
# Run tests from the module directory:
#   cd modules/district && tofu test
# ============================================================================

mock_provider "google" {
  # Mock provider for plan-only tests - no actual API calls needed
}

# ============================================================================

# ============================================================================
# REGION VALIDATION TESTS
# ============================================================================
# Only specific GCP regions are allowed.
# ============================================================================

run "valid_region_europe_west1" {
  command = plan

  variables {
    name        = "test-district"
    description = "Test district"
    region      = "europe-west1"
    tier        = "standard"
  }

  # Should succeed - europe-west1 is valid
  assert {
    condition     = var.region == "europe-west1"
    error_message = "europe-west1 should be a valid region"
  }
}

run "valid_region_europe_west3" {
  command = plan

  variables {
    name        = "test-district"
    description = "Test district"
    region      = "europe-west3"
    tier        = "standard"
  }

  # Should succeed - europe-west3 is valid
  assert {
    condition     = var.region == "europe-west3"
    error_message = "europe-west3 should be a valid region"
  }
}

run "valid_region_us_central1" {
  command = plan

  variables {
    name        = "test-district"
    description = "Test district"
    region      = "us-central1"
    tier        = "standard"
  }

  # Should succeed - us-central1 is valid
  assert {
    condition     = var.region == "us-central1"
    error_message = "us-central1 should be a valid region"
  }
}

run "invalid_region_rejected" {
  command = plan

  variables {
    name        = "test-district"
    description = "Test district"
    region      = "us-east1" # Not in allowed list!
    tier        = "standard"
  }

  expect_failures = [
    var.region
  ]
}



# ============================================================================
# TIER VALIDATION TESTS
# ============================================================================
# Only 'critical', 'standard', and 'minimal' tiers are allowed.
# ============================================================================

run "valid_tier_critical" {
  command = plan

  variables {
    name        = "test-district"
    description = "Test district"
    region      = "europe-west1"
    tier        = "critical"
  }

  assert {
    condition     = var.tier == "critical"
    error_message = "critical should be a valid tier"
  }
}

run "valid_tier_standard" {
  command = plan

  variables {
    name        = "test-district"
    description = "Test district"
    region      = "europe-west1"
    tier        = "standard"
  }

  assert {
    condition     = var.tier == "standard"
    error_message = "standard should be a valid tier"
  }
}

run "valid_tier_minimal" {
  command = plan

  variables {
    name        = "test-district"
    description = "Test district"
    region      = "europe-west1"
    tier        = "minimal"
  }

  assert {
    condition     = var.tier == "minimal"
    error_message = "minimal should be a valid tier"
  }
}

run "invalid_tier_rejected" {
  command = plan

  variables {
    name        = "test-district"
    description = "Test district"
    region      = "europe-west1"
    tier        = "basic" # Not allowed! Use 'minimal' instead
  }

  expect_failures = [
    var.tier
  ]
}


# ============================================================================
# NAME VALIDATION TESTS
# ============================================================================
# District names must be lowercase, start with a letter, and contain
# only letters, numbers, and hyphens.
# ============================================================================

run "valid_name_simple" {
  command = plan

  variables {
    name        = "north-market"
    description = "Test district"
    region      = "europe-west1"
    tier        = "standard"
  }

  assert {
    condition     = var.name == "north-market"
    error_message = "north-market should be a valid name"
  }
}

run "valid_name_with_numbers" {
  command = plan

  variables {
    name        = "district-42"
    description = "Test district"
    region      = "europe-west1"
    tier        = "standard"
  }

  assert {
    condition     = var.name == "district-42"
    error_message = "district-42 should be a valid name"
  }
}

run "invalid_name_uppercase_rejected" {
  command = plan

  variables {
    name        = "Test-District" # Uppercase not allowed!
    description = "Test district"
    region      = "europe-west1"
    tier        = "standard"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_starts_with_number_rejected" {
  command = plan

  variables {
    name        = "123-district" # Must start with letter!
    description = "Test district"
    region      = "europe-west1"
    tier        = "standard"
  }

  expect_failures = [
    var.name
  ]
}

run "invalid_name_ends_with_hyphen_rejected" {
  command = plan

  variables {
    name        = "district-" # Cannot end with hyphen!
    description = "Test district"
    region      = "europe-west1"
    tier        = "standard"
  }

  expect_failures = [
    var.name
  ]
}
