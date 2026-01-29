# ============================================================================
# CloudHaven Districts
# ============================================================================

# ----------------------------------------------------------------------------
# Existing Districts (migrated from beginner level)
# ----------------------------------------------------------------------------
module "north_market" {
  source = "./modules/district"

  name        = "north-market"
  description = "The bustling northern trading hub"
  region      = var.region
  tier        = "standard"
}

module "south_bazaar" {
  source = "./modules/district"

  name        = "south-bazaar"
  description = "The vibrant southern marketplace"
  region      = var.region
  tier        = "minimal"
}

# ----------------------------------------------------------------------------
# New Districts (added in intermediate level)
# ----------------------------------------------------------------------------
module "scholars_district" {
  source = "./modules/district"

  name        = "scholars-district"
  description = "The seat of learning and knowledge preservation"
  region      = var.region
  tier        = "critical"
}

