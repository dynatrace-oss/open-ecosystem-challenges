# ============================================================================
# OpenTofu Configuration
# ============================================================================
# This file contains the foundational configuration for OpenTofu:
# - Version constraints
# - Provider configuration
# - Remote state backend
# ============================================================================

terraform {
  required_version = ">= 1.11.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.15.0"
    }
  }

  # ---------------------------------------------------------------------------
  # Remote State Backend
  # ---------------------------------------------------------------------------
  # The Infrastructure Guild stores state remotely in a GCS bucket to enable
  # collaboration between guild members. This prevents state conflicts and
  # provides a shared source of truth for infrastructure state.
  # ---------------------------------------------------------------------------
  backend "gcs" {
    bucket = "cloudhaven-tfstate"
  }
}

# -----------------------------------------------------------------------------
# Google Cloud Provider
# -----------------------------------------------------------------------------
# Configured to use the CloudHaven mock GCP API for local development.
# In real life, this would be omitted to point to actual GCP endpoints.
# -----------------------------------------------------------------------------
provider "google" {
  project = "the-guardian-protocols"
  region  = var.region

  # Technically, this wouldn't be necessary because we're also setting the
  # `STORAGE_EMULATOR_HOST` variable during setup but this makes things more
  # explicit.
  storage_custom_endpoint = "__GCP_MOCK_ENDPOINT__/storage/v1/"
  sql_custom_endpoint     = "__GCP_MOCK_ENDPOINT__/"

  # Skip authentication since we're using a mock API
  access_token = "a-super-secure-token"
}

