.DEFAULT_GOAL := run

init:
	pipenv --three install
	pipenv shell
	pipenv install --dev --deploy

analyze:
	flake8 ./src


run_tests:
	pytest --cov=src test/jobs/

package:
	find . -name '__pycache__' | xargs rm -rf
	rm -f jobs.zip
	cd src/ && zip -r ../jobs.zip jobs/

requirements:
	pipenv lock -r > requirements.txt
	pipenv lock -r --dev-only > dev-requirements.txt


run_local: package
	spark-submit --py-files jobs.zip src/main.py --job $(JOB_NAME) --res-path $(CONF_PATH)
