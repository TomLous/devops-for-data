# devops-for-data
Tutorial project for setting up devops flows for data engineers &amp; scientists

# TODO fix for windows!

##  Makefile
Contains commands used locally and in CI/CD flow
 - make install
 - make init-local

## Pipenv
Pipenv is now setup.

Use pipenv shell or pipenv run pytest
Dependencies via Pipfile & Pipefile.lock

Can be pushed to: 
- requirements.txt
- requirements-dev.txt

## Precommit
Hooks that check that all depencies are in order before pushing

pre-commit install
pre-commit run --all-files

## Setup 
setup.py, setup.cfg and .bumpversion.cfg to keep all versions and metadata condensed
 
## Github Actions
CI/CD flow
