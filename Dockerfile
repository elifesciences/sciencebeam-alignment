FROM python:2.7.14-stretch

ENV PROJECT_HOME=/srv/sciencebeam-alignment
WORKDIR ${PROJECT_HOME}

ENV VENV=${PROJECT_HOME}/venv
RUN virtualenv ${VENV}}
ENV PYTHONUSERBASE=${VENV} PATH=${VENV}/bin:$PATH

COPY requirements.txt ${PROJECT_HOME}/
RUN pip install -r requirements.txt

COPY sciencebeam_alignment ${PROJECT_HOME}/sciencebeam_alignment
COPY *.conf *.sh *.in *.txt *.py .pylintrc ${PROJECT_HOME}/

RUN python setup.py build_ext --inplace

COPY requirements.dev.txt ${PROJECT_HOME}/
RUN pip install -r requirements.dev.txt
