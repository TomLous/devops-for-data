# devops-for-data
Tutorial project for setting up devops flows for data engineers &amp; scientists
 
##  Makefile
Contains commands used locally and in CI/CD flow
 - make install
 - make init-local

## Pipenv
Pipenv is now setup.

Use pipenv shell or pipenv run pytest
Dependencies via Pipfile & Pipfile.lock

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

## Issues

### Workflow
When a release is abandoned sometimes the tag is not removed. to fix it
    `git push --delete origin v[version]`

### TODO
- [ ] Not working on windows?
- [ ] Issues solved linux (yampl, lak, setuptools)?
- [ ] R&D best practices (setup.py deprecated?)
- [ ] Poetry?
- [ ] Pipenv via makefile, not pycharm
- [ ] pre-commit install
- [ ] java version check (issues v17?)
  - https://stackoverflow.com/questions/47891295/cannot-access-a-member-of-class-java-nio-directbytebuffer-in-module-java-base
- [ ] Update github actions versions?
