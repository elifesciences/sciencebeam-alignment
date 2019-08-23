FROM python:2.7.14-stretch

ENV PROJECT_HOME=/srv/sciencebeam-alignment
WORKDIR ${PROJECT_HOME}

ENV VENV=${PROJECT_HOME}/venv
RUN virtualenv ${VENV}}
ENV PYTHONUSERBASE=${VENV} PATH=${VENV}/bin:$PATH

COPY requirements.txt ./
RUN pip install -r requirements.txt

ARG install_dev
COPY requirements.dev.txt ./
RUN if [ "${install_dev}" = "y" ]; then pip install -r requirements.dev.txt; fi

COPY sciencebeam_alignment ./sciencebeam_alignment
COPY MANIFEST.in setup.py print_version.sh ./

RUN python setup.py build_ext --inplace

RUN python setup.py sdist

COPY tests ./tests
COPY .pylintrc ./
