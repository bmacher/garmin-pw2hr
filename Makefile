.PHONY: release

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
