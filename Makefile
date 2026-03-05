.PHONY: help deps lint template test all snapshot-update plugin-install

# Default target
help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

## Install helm-unittest plugin
plugin-install: ## Install helm-unittest Helm plugin
	helm plugin install https://github.com/helm-unittest/helm-unittest --version "~1"

## Download dependencies for charts that have Chart.lock
deps: ## Download Helm dependencies for charts with Chart.lock
	@echo "Installing Helm dependencies for charts with Chart.lock..."
	@for chart in addon_charts/*/Chart.lock; do \
		if [ -f "$$chart" ]; then \
			chart_dir=$$(dirname "$$chart"); \
			echo "Updating dependencies for $$chart_dir..."; \
			helm dependency update "$$chart_dir"; \
		fi \
	done
	@echo "Dependency installation complete"

## Lint all Helm charts (base_chart + addon_charts)
lint: ## Lint all Helm charts
	@echo "Linting base_chart..."
	helm lint base_chart/
	@echo ""
	@echo "Linting addon charts..."
	@for chart in addon_charts/*/; do \
		chart_name=$$(basename "$$chart"); \
		echo "Linting $$chart_name..."; \
		helm lint "$$chart"; \
	done
	@echo ""
	@echo "All charts linted successfully"

## Render all Helm templates
template: ## Render all Helm templates
	@echo "Rendering base_chart templates..."
	helm template base_chart/ --values base_chart/values.yaml > /dev/null
	@echo "base_chart templates rendered successfully"
	@echo ""
	@echo "Rendering addon chart templates..."
	@for chart in addon_charts/*/; do \
		chart_name=$$(basename "$$chart"); \
		echo "Rendering $$chart_name templates..."; \
		helm template "$$chart_name" "$$chart" > /dev/null; \
	done
	@echo ""
	@echo "All templates rendered successfully"

## Run helm-unittest tests for charts with tests/ directory
test: ## Run helm-unittest tests
	@echo "Running helm-unittest tests..."
	@test_count=0; \
	for chart in addon_charts/*/; do \
		chart_name=$$(basename "$$chart"); \
		if [ -d "$$chart/tests" ]; then \
			echo "Testing $$chart_name..."; \
			helm unittest "$$chart"; \
			test_count=$$((test_count + 1)); \
		fi \
	done; \
	if [ $$test_count -eq 0 ]; then \
		echo "No test directories found in addon charts"; \
	else \
		echo "All tests completed"; \
	fi

## Update helm-unittest snapshots
snapshot-update: ## Update helm-unittest snapshots
	@echo "Updating helm-unittest snapshots..."
	@for chart in addon_charts/*/; do \
		chart_name=$$(basename "$$chart"); \
		if [ -d "$$chart/tests" ]; then \
			echo "Updating snapshots for $$chart_name..."; \
			helm unittest -u "$$chart"; \
		fi \
	done
	@echo "Snapshot update complete"

## Run all targets: deps, lint, template, test
all: deps lint template test ## Run all targets (deps, lint, template, test)
	@echo ""
	@echo "All targets completed successfully"
