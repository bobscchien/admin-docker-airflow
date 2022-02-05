# Get the basic image
FROM python:3.8

# Add metadata to the image as a key value pair. For example, LABEL version="1.0"
LABEL maintainer="Bob Chien <bob.sc.chien@gmail.com>"

# Setup environment variables 
# !!! should be the same as config/conf.ini !!!
ENV PYTHON_VER=3.8 \
    USER_HOME=/home/airflow
ENV AIRFLOW_HOME=${USER_HOME}/airflow \
    VIRTUAL_HOME=${USER_HOME}/airflow-venv \
    PYTHON_DIR=${USER_HOME}/.local/bin
ENV PIPENV_DIR=${PYTHON_DIR}/pipenv

# Install Linux tools
RUN apt-get update && \
    apt-get install -y \
        ssh openssh-server openssh-client \
        net-tools iproute2 iputils-ping telnet vim && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Setup users
RUN useradd -u 1311 --create-home --no-log-init --shell /bin/bash airflow && \
    echo 'airflow:airflow' | chpasswd && \
    echo 'root:root' | chpasswd && \
    echo "export PATH=\$PATH:${PYTHON_DIR}" >> ${USER_HOME}/.bashrc && \
    echo "export AIRFLOW_HOME=${AIRFLOW_HOME}" >> ${USER_HOME}/.bashrc && \
    . ${USER_HOME}/.bashrc
USER airflow

# Install Python packages
RUN python -m pip --no-cache-dir install --upgrade pip && \
    python -m pip --no-cache-dir install --upgrade \
        setuptools wheel && \
    python -m pip --no-cache-dir install \
        virtualenv pipenv

# Install virtual environment & airflow
RUN mkdir -p ${AIRFLOW_HOME} ${VIRTUAL_HOME} && \
    echo "AIRFLOW_HOME=${AIRFLOW_HOME}" >> ${VIRTUAL_HOME}/.env && \
    cd ${VIRTUAL_HOME} && \
    ${PIPENV_DIR} --python ${PYTHON_VER} && \
    ${PIPENV_DIR} install \
        'apache-airflow[ssh,crypto,docker,jdbc,mysql]==2.2.3' && \
    ${PIPENV_DIR} clean

# Set the file directory
VOLUME /code /data ${AIRFLOW_HOME}
WORKDIR ${VIRTUAL_HOME}

# Set environment variables
ENV ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV SHELL=/bin/bash

# Open ports for Airflow
EXPOSE 8080

# Run a shell script
CMD ["/home/airflow/.local/bin/pipenv", "shell"]
