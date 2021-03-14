.DEFAULT_GOAL := init

ROOT_DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

install:
	@sudo -H python -m pip install --upgrade pipenv wheel

init:
	pipenv --three install --dev --deploy

init_local:
	@pre-commit install
	pipenv shell

analyze:
	@pipenv run flake8 ./src

tests:
	@rm -rf junit;\
	pipenv run pytest --cov=src test/jobs/ --doctest-modules --junitxml=junit/test-results.xml --cov-report=xml --cov-report=html

package:
	@rm -rf build
	rm -rf dist
	python setup.py bdist_egg
	tar czf "release.gzip" dist

bump-patch:
	@pipenv run bumpversion --tag patch --allow-dirty --list --verbose

bump-release:
	@pipenv run bumpversion --tag release --allow-dirty --list --verbose

bump-snapshot:
	@if grep -q "dev" "VERSION"; then\
		pipenv run bumpversion build --allow-dirty --list --no-tag --verbose; \
	else\
		pipenv run bumpversion minor --allow-dirty --list --no-tag --verbose; \
	fi

bump-snapshot-and-push: set-github-config bump-snapshot git-push
bump-release-and-push: set-github-config bump-release git-push
bump-patch-and-push: set-github-config bump-patch git-push

version:
	@cat VERSION

python-version:
	@cat Pipfile | grep python_full_version | awk '{print $$3}' | tr -d '"'

update-requirements:
	@pipenv run pipenv_to_requirements -f
	@git add . && git commit -m "Updated Pipfile.lock & requirements.txt"  --no-verify || true

update-requirements-and-push: set-github-config update-requirements git-push

# GIT Commands
set-github-config:
	git config --global user.name "$(GITHUB_ACTOR)"
	git config --global user.email "$(GITHUB_ACTOR)@users.noreply.github.com"

git-push:
	git push
	git push --tags


create-hotfix-branch:
	git fetch
	git branch -d hotfix || true
	git checkout -b hotfix $$(git describe --tags --abbrev=0 | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$$")

create-feature-branch:
	@git checkout main && git fetch && git pull
	git checkout -b feature/$(FEATURE)

run_local: package
	@DIST=$$(ls $(ROOT_DIR)/dist/*.egg); \
    spark-submit --py-files $$DIST src/main.py --job $(JOB_NAME) --res-path $(ROOT_DIR)/$(CONF_PATH)