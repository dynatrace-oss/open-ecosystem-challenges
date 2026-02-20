# ============================================================================
# Makefile for The AI Observatory - Intermediate Level
# ============================================================================
# This Makefile provides convenient commands for running
# the ART Pilot System and Traffic Simulator.
# ============================================================================

.PHONY: help art traffic

# Default target - show help
help:
	@echo "The AI Observatory - Available Commands:"
	@echo ""
	@echo "Application:"
	@echo "  make art          - Start the ART Pilot System CLI"
	@echo "  make traffic      - Generate background traffic for metrics"

# ----------------------------------------------------------------------------
# Application Targets
# ----------------------------------------------------------------------------

art:
	@python art.py

traffic:
	@python simulate_traffic.py

# ----------------------------------------------------------------------------
# Prometheus Targets
# ----------------------------------------------------------------------------

apply-rules:
	@echo "📊 Applying Prometheus recording rules from manifests/prometheus-rule.yaml..."
	@kubectl apply -f manifests/prometheus-rule-solution.yaml
	@echo "✅ PrometheusRule applied!"
	@echo ""
	@echo "⏳ The Prometheus Operator will automatically reload the configuration."
	@echo "   This usually takes ~10-15 seconds."
	@echo ""
	@echo "💡 View chart at: https://$$CODESPACE_NAME-30102.$$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN/graph?g0.expr=art%3Adistraction_ratio&g0.tab=0"


