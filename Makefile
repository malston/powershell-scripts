# Makefile for PowerShell Scripts Repository
# Provides convenient commands for common tasks

# Default shell for commands
SHELL := /bin/bash

# PowerShell executable detection
PWSH := $(shell command -v pwsh 2> /dev/null)
ifeq ($(PWSH),)
    PWSH := $(shell command -v powershell 2> /dev/null)
endif

# Colors for output - using printf for better compatibility
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

# Phony targets (not files)
.PHONY: help check-prereqs install install-modules install-powercli install-all test lint build clean update run-systeminfo import-module

## Help
help: ## Show this help message
	@printf "$(BLUE)PowerShell Scripts Repository - Makefile$(NC)\n"
	@printf "$(BLUE)==========================================$(NC)\n"
	@printf "\n"
	@printf "$(GREEN)Available targets:$(NC)\n"
	@printf "\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[0;33m%-20s\033[0m %s\n", $$1, $$2}'
	@printf "\n"
	@printf "$(GREEN)Examples:$(NC)\n"
	@printf "  make install          # Install all required modules\n"
	@printf "  make test             # Run Pester tests\n"
	@printf "  make install-powercli # Install VMware PowerCLI\n"
	@printf "\n"

## Prerequisites
check-prereqs: ## Check if PowerShell is installed
	@printf "$(BLUE)Checking prerequisites...$(NC)\n"
	@if [ -z "$(PWSH)" ]; then \
		printf "$(RED)❌ PowerShell not found!$(NC)\n"; \
		printf "Please install PowerShell Core (pwsh) first:\n"; \
		printf "  macOS: brew install --cask powershell\n"; \
		printf "  Linux: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell\n"; \
		printf "  Windows: https://aka.ms/powershell\n"; \
		exit 1; \
	else \
		printf "$(GREEN)✅ PowerShell found: $(PWSH)$(NC)\n"; \
		$(PWSH) -NoProfile -Command "Write-Host 'PowerShell Version:' \$$PSVersionTable.PSVersion -ForegroundColor Green"; \
	fi

## Installation
install: check-prereqs install-modules ## Install all required PowerShell modules
	@printf "$(GREEN)✅ All modules installed successfully!$(NC)\n"

install-modules: check-prereqs ## Install required PowerShell modules (Pester, PSScriptAnalyzer)
	@printf "$(BLUE)Installing required PowerShell modules...$(NC)\n"
	@printf "$(YELLOW)Installing Pester (testing framework)...$(NC)\n"
	@$(PWSH) -NoProfile -Command " \
		if (-not (Get-Module -Name Pester -ListAvailable | Where-Object Version -ge '5.0.0')) { \
			Write-Host 'Installing Pester...' -ForegroundColor Yellow; \
			Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser; \
		} else { \
			Write-Host 'Pester already installed' -ForegroundColor Green; \
		}"
	@printf "$(YELLOW)Installing PSScriptAnalyzer (code analysis)...$(NC)\n"
	@$(PWSH) -NoProfile -Command " \
		if (-not (Get-Module -Name PSScriptAnalyzer -ListAvailable)) { \
			Write-Host 'Installing PSScriptAnalyzer...' -ForegroundColor Yellow; \
			Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser; \
		} else { \
			Write-Host 'PSScriptAnalyzer already installed' -ForegroundColor Green; \
		}"
	@printf "$(GREEN)✅ Required modules installed$(NC)\n"

install-powercli: check-prereqs ## Install VMware PowerCLI
	@printf "$(BLUE)Installing VMware PowerCLI...$(NC)\n"
	@$(PWSH) -NoProfile -File ./scripts/administration/Install-PowerCLI.ps1
	@printf "$(GREEN)✅ PowerCLI installation complete$(NC)\n"

install-all: install install-powercli ## Install all modules including PowerCLI
	@printf "$(GREEN)✅ All installations complete!$(NC)\n"

## Development
import-module: check-prereqs ## Import MyModule into PowerShell session
	@printf "$(BLUE)Importing MyModule...$(NC)\n"
	@$(PWSH) -NoProfile -Command " \
		Import-Module ./modules/MyModule/MyModule.psd1 -Force -Verbose; \
		Get-Module MyModule | Format-List"
	@printf "$(GREEN)✅ Module imported$(NC)\n"

test: check-prereqs ## Run Pester tests
	@printf "$(BLUE)Running Pester tests...$(NC)\n"
	@$(PWSH) -NoProfile -Command " \
		if (-not (Get-Module -Name Pester -ListAvailable)) { \
			Write-Host 'Pester not found. Installing...' -ForegroundColor Yellow; \
			Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser; \
		}; \
		Invoke-Pester -Path ./tests -Output Detailed"

test-coverage: check-prereqs ## Run tests with code coverage
	@printf "$(BLUE)Running tests with code coverage...$(NC)\n"
	@$(PWSH) -NoProfile -Command " \
		$$config = New-PesterConfiguration; \
		$$config.CodeCoverage.Enabled = $$true; \
		$$config.CodeCoverage.Path = './modules/**/*.ps1'; \
		$$config.Output.Verbosity = 'Detailed'; \
		Invoke-Pester -Configuration $$config"

lint: check-prereqs ## Run PSScriptAnalyzer on all scripts
	@printf "$(BLUE)Running PSScriptAnalyzer...$(NC)\n"
	@$(PWSH) -NoProfile -Command " \
		if (-not (Get-Module -Name PSScriptAnalyzer -ListAvailable)) { \
			Write-Host 'PSScriptAnalyzer not found. Installing...' -ForegroundColor Yellow; \
			Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser; \
		}; \
		Write-Host 'Analyzing scripts...' -ForegroundColor Yellow; \
		\$$results = Invoke-ScriptAnalyzer -Path . -Recurse; \
		if (\$$results) { \
			\$$results | Format-Table -AutoSize; \
			exit 1; \
		} else { \
			Write-Host '✅ No issues found!' -ForegroundColor Green; \
		}"

## Build
build: check-prereqs lint test ## Run full build pipeline (lint, test)
	@printf "$(BLUE)Running build script...$(NC)\n"
	@$(PWSH) -NoProfile -File ./tools/build.ps1 -Task Build
	@printf "$(GREEN)✅ Build complete$(NC)\n"

build-all: check-prereqs ## Run complete build pipeline with packaging
	@printf "$(BLUE)Running full build pipeline...$(NC)\n"
	@$(PWSH) -NoProfile -File ./tools/build.ps1 -Task All
	@printf "$(GREEN)✅ Full build complete$(NC)\n"

package: check-prereqs ## Package the module for distribution
	@printf "$(BLUE)Packaging module...$(NC)\n"
	@$(PWSH) -NoProfile -File ./tools/build.ps1 -Task Package
	@printf "$(GREEN)✅ Package created$(NC)\n"

## Utility
run-systeminfo: check-prereqs ## Run the Get-SystemInfo script
	@printf "$(BLUE)Running Get-SystemInfo...$(NC)\n"
	@$(PWSH) -NoProfile -File ./scripts/administration/Get-SystemInfo.ps1

update: check-prereqs ## Update all installed PowerShell modules
	@printf "$(BLUE)Updating PowerShell modules...$(NC)\n"
	@$(PWSH) -NoProfile -Command " \
		@('Pester', 'PSScriptAnalyzer', 'VCF.PowerCLI') | ForEach-Object { \
			if (Get-Module -Name $$_ -ListAvailable) { \
				Write-Host \"Updating $$_...\" -ForegroundColor Yellow; \
				Update-Module -Name $$_ -Force; \
			} \
		}"
	@printf "$(GREEN)✅ Modules updated$(NC)\n"

clean: ## Clean build artifacts and test results
	@printf "$(BLUE)Cleaning build artifacts...$(NC)\n"
	@rm -rf output/
	@rm -f TestResults.xml coverage.xml *.trx
	@rm -f SystemInfo-*.json SystemInfo-*.csv
	@find . -name "*.log" -type f -delete
	@find . -name "*.bak" -type f -delete
	@printf "$(GREEN)✅ Cleaned$(NC)\n"

## Docker (optional)
docker-build: ## Build Docker image with PowerShell
	@printf "$(BLUE)Building Docker image...$(NC)\n"
	@echo "FROM mcr.microsoft.com/powershell:latest" > Dockerfile.tmp
	@echo "WORKDIR /workspace" >> Dockerfile.tmp
	@echo "COPY . ." >> Dockerfile.tmp
	@echo "RUN pwsh -Command 'Install-Module -Name Pester, PSScriptAnalyzer -Force -SkipPublisherCheck'" >> Dockerfile.tmp
	@echo "CMD [\"pwsh\"]" >> Dockerfile.tmp
	@docker build -f Dockerfile.tmp -t powershell-scripts .
	@rm Dockerfile.tmp
	@printf "$(GREEN)✅ Docker image built$(NC)\n"

docker-run: ## Run PowerShell in Docker container
	@printf "$(BLUE)Running PowerShell in Docker...$(NC)\n"
	@docker run -it --rm -v $(PWD):/workspace powershell-scripts

## CI/CD
ci: check-prereqs lint test ## Run CI pipeline (lint and test)
	@printf "$(GREEN)✅ CI pipeline passed$(NC)\n"

## Info
info: check-prereqs ## Show system and module information
	@printf "$(BLUE)System Information:$(NC)\n"
	@$(PWSH) -NoProfile -Command " \
		Write-Host 'PowerShell Version:' \$$PSVersionTable.PSVersion; \
		Write-Host 'Edition:' \$$PSVersionTable.PSEdition; \
		Write-Host 'OS:' \$$PSVersionTable.OS; \
		Write-Host 'Platform:' \$$PSVersionTable.Platform; \
		Write-Host ''; \
		Write-Host 'Installed Modules:' -ForegroundColor Yellow; \
		@('Pester', 'PSScriptAnalyzer', 'VCF.PowerCLI') | ForEach-Object { \
			\$$module = Get-Module -Name \$$_ -ListAvailable | Select-Object -First 1; \
			if (\$$module) { \
				Write-Host \"  \$$_\`t\`t\$$(\$$module.Version)\" -ForegroundColor Green; \
			} else { \
				Write-Host \"  \$$_\`t\`tNot Installed\" -ForegroundColor Red; \
			} \
		}"

list-scripts: ## List all available PowerShell scripts
	@printf "$(BLUE)Available PowerShell Scripts:$(NC)\n"
	@echo ""
	@printf "$(YELLOW)Administration Scripts:$(NC)\n"
	@ls -1 scripts/administration/*.ps1 2>/dev/null | xargs -n1 basename | sed 's/^/  /'
	@echo ""
	@printf "$(YELLOW)Module Functions:$(NC)\n"
	@ls -1 modules/MyModule/Public/*.ps1 2>/dev/null | xargs -n1 basename | sed 's/\.ps1//' | sed 's/^/  /'
	@echo ""
	@printf "$(YELLOW)Tools:$(NC)\n"
	@ls -1 tools/*.ps1 2>/dev/null | xargs -n1 basename | sed 's/^/  /'

# Quick shortcuts
.PHONY: i t l b c
i: install ## Shortcut for install
t: test ## Shortcut for test
l: lint ## Shortcut for lint
b: build ## Shortcut for build
c: clean ## Shortcut for clean