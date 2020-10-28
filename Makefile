.DEFAULT_GOAL := run

ROOT_DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

install:
	@python -m pip install --upgrade pipenv wheel

init:
	@pipenv --three install
	pipenv install --dev --deploy

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

bump_minor:
	@pipenv run bump2version minor --allow-dirty --list

bump_major:
	@pipenv run bump2version minor --allow-dirty --list --dry-run

requirements:
	@pipenv lock -r > requirements.txt
	pipenv lock -r --dev-only > dev-requirements.txt

run_local: package
	@DIST=$$(ls $(ROOT_DIR)/dist/*.egg); \
    spark-submit --py-files $$DIST src/main.py --job $(JOB_NAME) --res-path $(ROOT_DIR)/$(CONF_PATH)