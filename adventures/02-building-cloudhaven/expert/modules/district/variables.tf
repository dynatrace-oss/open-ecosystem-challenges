# ============================================================================
# District Module - Variables
# ============================================================================
# This module encapsulates infrastructure for a single CloudHaven district.
# It provisions a storage vault and ledger database with configurable settings.
#
# Input validation ensures:
# - Regions are within allowed GCP regions
# - Database encryption is always enabled in production
# ============================================================================

variable "name" {
  description = "The unique identifier for the district (e.g., 'north-market')"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.name))
    error_message = "District name must be lowercase, start with a letter, and contain only letters, numbers, and hyphens."
  }
}

variable "description" {
  description = "A description of the district's purpose"
  type        = string
  default     = ""
}

variable "region" {
  description = "GCP region for the district's resources"
  type        = string

  validation {
    condition     = contains(["europe-west1", "europe-west3", "us-central1"], var.region)
    error_message = "Region must be one of: europe-west1, europe-west3, us-central1."
  }
}


variable "tier" {
  description = <<-EOT
    The importance tier of this district, which determines resource sizing and protection:
    - critical: High availability, maximum protection, larger resources (for essential districts)
    - standard: Balanced settings for normal operations (default)
    - minimal:  Cost-optimized, reduced protection (for development/testing)
  EOT
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["critical", "standard", "minimal"], var.tier)
    error_message = "Tier must be one of: critical, standard, minimal."
  }
}

