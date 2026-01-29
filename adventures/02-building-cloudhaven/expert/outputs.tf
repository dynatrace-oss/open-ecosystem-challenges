# ============================================================================
# CloudHaven Infrastructure - Outputs
# ============================================================================
# Exposes infrastructure details for consumption by other systems.
# ============================================================================

output "districts" {
  description = "Infrastructure details for each district"
  value = {
    north-market = {
      vault  = module.north_market.vault
      ledger = module.north_market.ledger
    }
    south-bazaar = {
      vault  = module.south_bazaar.vault
      ledger = module.south_bazaar.ledger
    }
    scholars-district = {
      vault  = module.scholars_district.vault
      ledger = module.scholars_district.ledger
    }
  }
}
