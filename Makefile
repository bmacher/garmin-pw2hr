SDK_HOME := $(HOME)/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.1.0-2026-03-09-6a872a80b
MONKEYC := $(SDK_HOME)/bin/monkeyc
JAVA_HOME := /opt/homebrew/opt/openjdk@17
KEY := developer_key.der

.PHONY: release build

release:
	@current=$$(grep -o 'version="[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"' manifest.xml | head -1 | sed 's/version="//;s/"//'); \
	echo "Current version: $$current"; \
	echo ""; \
	echo "Select bump type:"; \
	echo "  1) major"; \
	echo "  2) minor"; \
	echo "  3) hotfix"; \
	echo ""; \
	read -p "Choice [1/2/3]: " choice; \
	major=$$(echo $$current | cut -d. -f1); \
	minor=$$(echo $$current | cut -d. -f2); \
	patch=$$(echo $$current | cut -d. -f3); \
	case $$choice in \
		1) major=$$((major + 1)); minor=0; patch=0;; \
		2) minor=$$((minor + 1)); patch=0;; \
		3) patch=$$((patch + 1));; \
		*) echo "Invalid choice"; exit 1;; \
	esac; \
	new="$$major.$$minor.$$patch"; \
	echo ""; \
	echo "Bumping $$current → $$new"; \
	sed -i '' "s/version=\"$$current\"/version=\"$$new\"/" manifest.xml; \
	git add manifest.xml; \
	git commit -m "release: $$new"; \
	git tag -a "$$new" -m "release $$new"; \
	echo ""; \
	echo "✅ Version bumped to $$new and tagged $$new"; \
	echo "   Run 'git push && git push --tags' to publish."

build:
	@echo "Available releases:"; \
	echo ""; \
	tags=$$(git tag --sort=-v:refname); \
	if [ -z "$$tags" ]; then echo "No tags found."; exit 1; fi; \
	i=1; \
	for tag in $$tags; do echo "  $$i) $$tag"; i=$$((i + 1)); done; \
	echo ""; \
	read -p "Select release to build: " choice; \
	i=1; \
	selected=""; \
	for tag in $$tags; do \
		if [ "$$i" = "$$choice" ]; then selected=$$tag; fi; \
		i=$$((i + 1)); \
	done; \
	if [ -z "$$selected" ]; then echo "Invalid choice"; exit 1; fi; \
	echo ""; \
	echo "Building $$selected..."; \
	git stash --include-untracked -q 2>/dev/null; \
	git checkout "$$selected" -q; \
	mkdir -p release; \
	JAVA_HOME="$(JAVA_HOME)" "$(MONKEYC)" -f monkey.jungle -o "release/Pw2Hr-$$selected.iq" -e -y "$(KEY)" -r; \
	git checkout - -q; \
	git stash pop -q 2>/dev/null || true; \
	echo ""; \
	echo "✅ Built release/Pw2Hr-$$selected.iq"
