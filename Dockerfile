ARG DOCKER_REGISTRY=""
ARG PYTHON_MAJOR_VERSION="3.11"
ARG OS_DISTRIBUTION="bookworm"
ARG PIP_INDEX_URL=""
ARG PIP_ROOT_USER_ACTION="ignore"
ARG PIP_DISABLE_PIP_VERSION_CHECK=1
ARG PY_PACKAGES="/opt/packages"


FROM ${DOCKER_REGISTRY}python:${PYTHON_MAJOR_VERSION}-${OS_DISTRIBUTION} as builder

ARG PIP_INDEX_URL
ARG PIP_ROOT_USER_ACTION
ARG PIP_DISABLE_PIP_VERSION_CHECK

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

WORKDIR /build

COPY pyproject.toml requirements*.txt README.md ./

RUN pip install -r requirements-build.txt -r requirements-lint.txt
RUN pip wheel -w /dist --find-links /dist -r requirements.txt
RUN pip install --no-index --find-links /dist -r requirements.txt

COPY app app

RUN flake8
RUN mypy -p app

RUN python -m build --wheel --outdir /dist


FROM ${DOCKER_REGISTRY}python:${PYTHON_MAJOR_VERSION}-${OS_DISTRIBUTION} as release

ARG PY_PACKAGES
ARG PIP_ROOT_USER_ACTION

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

COPY --from=builder /dist/*.whl "${PY_PACKAGES}/"
RUN pip install --compile --no-index --find-links "${PY_PACKAGES}" "${PY_PACKAGES}"/*app*.whl && \
    pip check

ENTRYPOINT ["app-cli"]


FROM release as tests

ARG PIP_INDEX_URL
ARG PIP_ROOT_USER_ACTION
ARG PIP_DISABLE_PIP_VERSION_CHECK

WORKDIR /tests

RUN app-cli --help >/dev/null

COPY pyproject.toml requirements-test.txt ./

RUN pip install -r requirements-test.txt && \
    pip check

COPY tests tests

RUN pytest


FROM release
