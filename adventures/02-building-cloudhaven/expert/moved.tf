# ============================================================================
# Resource Migration - Moved Blocks
# ============================================================================
# These blocks handle the migration of resources from the beginner-level flat
# structure to the intermediate-level modular structure.
#
# Previously, resources were defined directly in merchants.tf using for_each:
#   - google_storage_bucket.vault["district-name"]
#   - google_sql_database_instance.ledger["district-name"]
#
# Now, resources are encapsulated in district modules:
#   - module.<district>.google_storage_bucket.vault
#   - module.<district>.google_sql_database_instance.ledger
#
# The moved blocks below tell OpenTofu to update state references without
# destroying and recreating resources.
# ============================================================================

# ----------------------------------------------------------------------------
# North Market
# ----------------------------------------------------------------------------
moved {
  from = google_storage_bucket.vault["north-market"]
  to   = module.north_market.google_storage_bucket.vault
}

moved {
  from = google_sql_database_instance.ledger["north-market"]
  to   = module.north_market.google_sql_database_instance.ledger
}

# ----------------------------------------------------------------------------
# South Bazaar
# ----------------------------------------------------------------------------
moved {
  from = google_storage_bucket.vault["south-bazaar"]
  to   = module.south_bazaar.google_storage_bucket.vault
}

moved {
  from = google_sql_database_instance.ledger["south-bazaar"]
  to   = module.south_bazaar.google_sql_database_instance.ledger
}
