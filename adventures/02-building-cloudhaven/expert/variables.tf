# ============================================================================
# CloudHaven Infrastructure - Variables
# ============================================================================


variable "region" {
  description = "The default GCP region for resources"
  type        = string
  default     = "europe-west1"

  validation {
    condition     = contains(["europe-west1", "europe-west3", "us-central1"], var.region)
    error_message = "Region must be one of: europe-west1, europe-west3, us-central1."
  }
}
