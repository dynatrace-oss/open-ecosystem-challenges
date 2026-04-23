.PHONY: help apply verify

help:
	@echo "Lex Imperfecta - Beginner: Available Commands:"
	@echo "  make apply    Apply policies and re-deploy all workloads"
	@echo "  make verify   Run the verification script"

apply:
	@kubectl delete pod compliant missing-labels privileged privileged-init-container --ignore-not-found > /dev/null 2>&1; true
	@echo "Applied Policies:"; \
	for f in manifests/policies/*.yaml; do \
		name=$$(grep '^  name:' "$$f" | awk '{print $$2}'); \
		kubectl apply -f "$$f" > /dev/null 2>&1 && echo "  $$name"; \
	done; \
	echo ""
	@echo "Applied Pods:"; \
	blocked=""; \
	for f in manifests/pods/*.yaml; do \
		name=$$(grep '^  name:' "$$f" | awk '{print $$2}'); \
		if kubectl apply -f "$$f" > /dev/null 2>&1; then \
			echo "  $$name"; \
		else \
			blocked="$$blocked $$name"; \
		fi; \
	done; \
	echo ""; \
	echo "Blocked Pods:"; \
	for name in $$blocked; do echo "  $$name"; done

verify:
	@./verify.sh
