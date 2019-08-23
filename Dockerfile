FROM python:2.7.14-stretch

ENV PROJECT_HOME=/srv/sciencebeam-alignment
WORKDIR ${PROJECT_HOME}

ENV VENV=${PROJECT_HOME}/venv
RUN virtualenv ${VENV}}
ENV PYTHONUSERBASE=${VENV} PATH=${VENV}/bin:$PATH

COPY requirements.build.txt ./
RUN pip install -r requirements.build.txt

COPY requirements.txt ./
RUN pip install -r requirements.txt

ARG install_dev
COPY requirements.dev.txt ./
RUN if [ "${install_dev}" = "y" ]; then pip install -r requirements.dev.txt; fi

COPY sciencebeam_alignment ./sciencebeam_alignment
COPY README.md MANIFEST.in setup.py print_version.sh ./

RUN python setup.py build_ext --inplace

COPY tests ./tests
COPY .pylintrc ./

ARG version
ADD docker ./docker
RUN ls -l && ./docker/set-version.sh "${version}"
LABEL org.opencontainers.image.version=${version}

RUN python setup.py sdist
