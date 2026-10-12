# Command catalog. Every target is a thin alias for flutter/dart or docker compose; CI calls
# the same targets. Run `make` to list them. Same names as the web and backend repos where they
# mean the same thing.
.DEFAULT_GOAL := help

# Build configuration: env/<ENV>.json, or env/<ENV>.local.json when present (git-ignored, for
# personal overrides such as your computer's LAN address).
ENV ?= dev
ENV_FILE := $(firstword $(wildcard env/$(ENV).local.json) env/$(ENV).json)
# Release builds: obfuscated, with symbols kept to read crash stack traces (docs/releasing.md).
COMPOSE := docker compose -f docker/compose.yml
# Local backend port; every target passes it to the app (make run BACKEND_PORT=8090 if 8080 is taken).
BACKEND_PORT ?= 8080
export BACKEND_PORT
BACKEND_URL ?= http://localhost:$(BACKEND_PORT)
# The port goes last: a --dart-define overrides the same key from the file.
DEFINES := --dart-define-from-file=$(ENV_FILE) --dart-define=BACKEND_PORT=$(BACKEND_PORT)
DART_SOURCES := lib test tool integration_test
RELEASE = --release --obfuscate --split-debug-info=build/symbols/$(ENV) $(DEFINES)

.PHONY: help setup l10n fmt lint test coverage verify devices run screenshots backend-up backend-down db-reset e2e \
	api-check build-apk build-appbundle build-ios build-ipa clean

help: ## List targets
	@awk 'BEGIN {FS = ":.*## "} /^[a-z0-9-]+:.*## / {printf "  %-16s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## One-time: dependencies, generated localizations, a check of the toolchain
	flutter pub get
	dart run tool/l10n.dart
	flutter doctor

l10n: ## Rebuild localizations after editing l10n/<locale>/*.json
	dart run tool/l10n.dart

fmt: ## Format and apply automatic fixes
	dart fix --apply
	dart format $(DART_SOURCES)

lint: ## Format check, static analysis (infos fail too), localizations up to date
	dart format --output=none --set-exit-if-changed $(DART_SOURCES)
	flutter analyze --fatal-infos --fatal-warnings
	dart run tool/l10n.dart --check

test: ## Unit and widget tests
	flutter test

coverage: ## Tests with a coverage report in coverage/lcov.info
	flutter test --coverage

verify: lint test ## Everything CI's verify job runs

devices: ## List connected devices and the emulators/simulators that can be started
	flutter devices
	flutter emulators

# The device to use: DEVICE=<id>, else the running one, else one is started (EMULATOR=<id>).
DEVICE_ID = $$(dart tool/device.dart | tail -1)

run: ## Run the app; starts a simulator/emulator if none is running (ENV=, DEVICE=, EMULATOR=)
	@device=$(DEVICE_ID) && [ -n "$$device" ] && flutter run $(DEFINES) -d "$$device"

screenshots: backend-up ## Capture the README screenshots into docs/screenshots (starts a simulator/emulator)
	@device=$(DEVICE_ID) && [ -n "$$device" ] && flutter drive \
		--driver=tool/screenshots/driver.dart --target=tool/screenshots/screenshots_test.dart \
		$(DEFINES) -d "$$device"
	@# Phone-sized PNGs are large; keep the committed copies small where sips exists (macOS).
	@if command -v sips >/dev/null; then for f in docs/screenshots/*.png; do sips -Z 900 "$$f" >/dev/null; done; fi

backend-up: ## Start Postgres + the backend API on :$(BACKEND_PORT) (Docker), pulling the latest image
	@# :dev moves with every backend release; a cached copy would hide API changes.
	-$(COMPOSE) pull --quiet backend
	$(COMPOSE) up -d --wait --wait-timeout 300
	@echo "Backend ready at $(BACKEND_URL)"

backend-down: ## Stop the backend (keeps data)
	$(COMPOSE) down

db-reset: ## Stop the backend and delete its database
	$(COMPOSE) down -v

e2e: backend-up ## Integration tests against the backend; starts a simulator/emulator if needed (DEVICE=)
	@device=$(DEVICE_ID) && [ -n "$$device" ] && flutter test integration_test $(DEFINES) -d "$$device"

api-check: ## Fail if the backend's API no longer matches the app's models
	dart run tool/api_check.dart $(BACKEND_URL)

build-apk: ## Release APK (ENV=staging|prod), for testers and direct installs
	flutter build apk $(RELEASE)

build-appbundle: ## Release Android App Bundle for Google Play
	flutter build appbundle $(RELEASE)

build-ios: ## Release iOS build without signing (CI check)
	flutter build ios --no-codesign $(RELEASE)

build-ipa: ## Signed IPA for TestFlight / the App Store (needs signing set up in Xcode)
	flutter build ipa $(RELEASE)

clean: ## Delete build output
	flutter clean
