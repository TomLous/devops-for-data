.DEFAULT_GOAL := init

ROOT_DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

PY_VERSION:=$(shell cat Pipfile | grep python_full_version | awk '{print $$3}' | tr -d '"')

.PHONY: install
install:
	@sudo -H python -m pip install --upgrade pipenv wheel

.PHONY: init
init:
	pipenv install --dev --deploy

.PHONY: init-local
init-local:
	@pre-commit install
	pipenv --rm
	pipenv install --dev
	pipenv shell

.PHONY: analyze
analyze:
	@pipenv run flake8

.PHONY: tests
tests:
	@rm -rf junit;\
	pipenv run pytest --cov=src test/jobs/ --doctest-modules --junitxml=junit/test-results.xml --cov-report=xml --cov-report=html

.PHONY: package
package:
	@rm -rf build
	rm -rf dist
	python setup.py bdist_egg
	tar czf "release.gzip" dist

# TODO fix semver (1.1.0-dev3 => 1.1.0, not 1.2.0)
.PHONY: bump-patch
bump-patch:
	@pipenv run bumpversion --tag patch --allow-dirty --list --verbose

.PHONY: bump-release
bump-release:
	@pipenv run bumpversion --tag $(BUMP_TYPE) --allow-dirty --list --verbose

.PHONY: bump-snapshot
bump-snapshot:
	@if grep -q "dev" "VERSION"; then\
		pipenv run bumpversion build --allow-dirty --list --no-tag --verbose; \
	else\
		pipenv run bumpversion release --allow-dirty --list --no-tag --verbose; \
	fi

.PHONY: bump-snapshot-and-push
bump-snapshot-and-push: set-github-config bump-snapshot git-push
.PHONY: bump-release-and-push
bump-release-and-push: set-github-config bump-release git-push
.PHONY: bump-patch-and-push
bump-patch-and-push: set-github-config bump-patch git-push

.PHONY: version
version:
	@cat VERSION

.PHONY: python-version
python-version:
	@echo $(PY_VERSION)

.PHONY: update-requirements
update-requirements:
	@pipenv run pipenv_to_requirements -f
	@git add . && git commit -m "Updated Pipfile.lock & requirements.txt"  --no-verify || true

.PHONY: update-requirements-and-push
update-requirements-and-push: set-github-config update-requirements git-push

# GIT Commands
.PHONY: set-github-config
set-github-config:
	git config --global user.name "$(GITHUB_ACTOR)"
	git config --global user.email "$(GITHUB_ACTOR)@users.noreply.github.com"

.PHONY: git-push
git-push:
	git push
	git push --tags

.PHONY: create-hotfix-branch
create-hotfix-branch:
	# TODO fix last tag (git describe --tags != git tag)
	git fetch
	git branch -d hotfix || true
	git checkout -b hotfix $$(git describe --tags --abbrev=0 | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$$")

.PHONY: create-feature-branch
create-feature-branch:
	@git checkout main && git fetch && git pull
	git checkout -b feature/$(FEATURE)

.PHONY: run-local
run-local: package
	DIST=$$(ls $(ROOT_DIR)/dist/*.egg); \
    spark-submit \
    --conf spark.driver.extraJavaOptions="-Dlog4j.configuration=file://$(ROOT_DIR)/$(CONF_PATH)/$(JOB_NAME)/resources/log4j.properties" \
    --py-files $$DIST src/main.py \
    --job $(JOB_NAME) --res-path $(ROOT_DIR)/$(CONF_PATH)

