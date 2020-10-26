.DEFAULT_GOAL := run

ROOT_DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

init:
	pipenv --three install
	pipenv install --dev --deploy

analyze:
	pipenv run flake8 ./src

tests:
	pipenv run pytest --cov=src test/jobs/

package:
	rm -rf build
	rm -rf dist
	python setup.py bdist_egg

requirements:
	pipenv lock -r > requirements.txt
	pipenv lock -r --dev-only > dev-requirements.txt

run_local: package
	DIST=$$(ls $(ROOT_DIR)/dist/*.egg); \
    spark-submit --py-files $$DIST src/main.py --job $(JOB_NAME) --res-path $(ROOT_DIR)/$(CONF_PATH)