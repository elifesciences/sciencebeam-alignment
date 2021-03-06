DOCKER_COMPOSE_DEV = VERSION="$(VERSION)" docker-compose
DOCKER_COMPOSE_CI = VERSION="$(VERSION)" docker-compose -f docker-compose.yml
DOCKER_COMPOSE = $(DOCKER_COMPOSE_DEV)

VENV = venv
PIP = $(VENV)/bin/pip
PYTHON = $(VENV)/bin/python

RUN = $(DOCKER_COMPOSE) run --rm sciencebeam-alignment
DEV_RUN = $(RUN)

NOT_SLOW_PYTEST_ARGS = -m 'not slow'

ARGS =


.PHONY: build


venv-clean:
	@if [ -d "$(VENV)" ]; then \
		rm -rf "$(VENV)"; \
	fi


venv-create:
	python3 -m venv $(VENV)


dev-install:
	$(PIP) install -r requirements.build.txt
	$(PIP) install -r requirements.txt
	$(PIP) install -r requirements.dev.txt
	$(PIP) install -e . --no-deps


dev-cython-clean:
	rm -f sciencebeam_alignment/align_fast_utils.c sciencebeam_alignment/align_fast_utils.so


dev-cython-compile:
	$(PYTHON) setup.py build_ext --inplace


dev-venv: venv-create dev-install dev-cython-compile


dev-flake8:
	$(PYTHON) -m flake8 sciencebeam_alignment tests setup.py


dev-pylint:
	$(PYTHON) -m pylint sciencebeam_alignment tests setup.py


dev-lint: dev-flake8 dev-pylint


dev-pytest:
	$(PYTHON) -m pytest -p no:cacheprovider $(ARGS)


dev-watch:
	$(PYTHON) -m pytest_watch -- -p no:cacheprovider $(ARGS)


dev-test: dev-lint dev-pytest


build:
	$(DOCKER_COMPOSE) build sciencebeam-alignment


shell:
	$(RUN) bash


shell-dev:
	$(DEV_RUN) bash


flake8:
	$(DEV_RUN) flake8 sciencebeam_alignment tests setup.py


pylint:
	$(DEV_RUN) pylint sciencebeam_alignment tests setup.py


pytest:
	$(DEV_RUN) pytest -p no:cacheprovider $(ARGS)


pytest-not-slow:
	@$(MAKE) ARGS="$(ARGS) $(NOT_SLOW_PYTEST_ARGS)" pytest


.watch:
	$(DEV_RUN) pytest-watch -- -p no:cacheprovider -p no:warnings $(ARGS)


watch-slow:
	@$(MAKE) .watch


watch:
	@$(MAKE) ARGS="$(ARGS) $(NOT_SLOW_PYTEST_ARGS)" .watch


test-setup-install:
	$(RUN) python setup.py install


lint: flake8 pylint


test: \
	lint \
	pytest \
	test-setup-install


ci-build-and-test:
	$(MAKE) DOCKER_COMPOSE="$(DOCKER_COMPOSE_CI)" \
		build test


ci-clean:
	$(DOCKER_COMPOSE_CI) down -v


ci-push-testpypi:
	$(DOCKER_COMPOSE_CI) run --rm \
		-v $$PWD/.pypirc:/root/.pypirc \
		sciencebeam-alignment \
		./docker/push-testpypi-commit-version.sh "$(COMMIT)"


ci-push-pypi:
	$(DOCKER_COMPOSE_CI) run --rm \
		-v $$PWD/.pypirc:/root/.pypirc \
		sciencebeam-alignment \
		./docker/push-pypi-version.sh "$(VERSION)"


ci-verify-version:
	$(DOCKER_COMPOSE_CI) run --rm sciencebeam-alignment ./docker/verify-version.sh "$(VERSION)"
