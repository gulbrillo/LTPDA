BRANCH ?= develop
DOCKER ?= docker
PACKAGE = pyda
DOCKER_IMAGE = gwdiexp/${PACKAGE}:${BRANCH}
OLD_PY_VERSION = 3.7

all: mypy test package

test:
	PYTHONPATH=`pwd` poetry run py.test

test-docker:
	${DOCKER} run -v `pwd`:/code --rm -it ${DOCKER_IMAGE} make test

mypy:
	poetry run mypy ${PACKAGE}

pylint:
	poetry run pylint ${PACKAGE}

black:
	poetry run black ${PACKAGE} tests

package:
	poetry build

upload:
	poetry config pypi-token.pypi ${POETRY_PYPI_TOKEN_PYPI}
	poetry publish

docker:
	${DOCKER} build . -f docker/Dockerfile -t ${DOCKER_IMAGE}
	${DOCKER} build . -f docker/Dockerfile -t ${DOCKER_IMAGE}-${OLD_PY_VERSION} \
		--build-arg PYTHON_VERSION=${OLD_PY_VERSION}

docker-push:
	${DOCKER} login
	${DOCKER} push ${DOCKER_IMAGE}
	${DOCKER} push ${DOCKER_IMAGE}-${OLD_PY_VERSION}

clean:
	@rm -r dist/

.PHONY: mypy test package docker
