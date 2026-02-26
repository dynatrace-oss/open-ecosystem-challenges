# ============================================================================
# Makefile for The AI Observatory - Expert Level: The Noise Filter
# ============================================================================
# This Makefile provides convenient commands for running
# the ART Pilot System and Traffic Simulator.
# ============================================================================

.PHONY: help art traffic apply-otel-config restart-collector verify

# Default target - show help
help:
	@echo "The AI Observatory - Expert Level: The Noise Filter"
	@echo ""
	@echo "Application:"
	@echo "  make art                       - Start the ART Pilot System CLI"
	@echo "  make traffic                   - Generate background traffic (with fault injection)"
	@echo ""
	@echo "Infrastructure:"
	@echo "  make apply-otel-config         - Apply the OTel Collector config"
	@echo "  make restart-otel-collector    - Restart the OTel Collector to pick up new config"
	@echo ""
	@echo "Verification:"
	@echo "  make verify                    - Run verification checks"

# ----------------------------------------------------------------------------
# Application Targets
# ----------------------------------------------------------------------------

art:
	@python art.py

traffic:
	@python simulate_traffic.py

# ----------------------------------------------------------------------------
# Infrastructure Targets
# ----------------------------------------------------------------------------

apply-otel-config:
	@kubectl apply -f manifests/otel-collector-config.yaml -n otel

restart-otel-collector:
	@kubectl rollout restart deployment/collector -n otel
	@kubectl rollout status deployment/collector -n otel --timeout=60s

# ----------------------------------------------------------------------------
# Verification Targets
# ----------------------------------------------------------------------------

verify:
	@./verify.sh
