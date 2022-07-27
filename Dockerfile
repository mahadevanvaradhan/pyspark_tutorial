# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG OWNER=jupyter
ARG BASE_CONTAINER=$OWNER/pyspark-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt-get update && \
    apt-get install build-essential curl file git -y

RUN apt-get install -y alsa-base alsa-utils


# RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"

RUN apt-get install espeak python3-pyaudio libasound-dev libportaudio2 libportaudiocpp0 portaudio19-dev -y
RUN pip install pyaudio 

# RSpark config
ENV R_LIBS_USER "${SPARK_HOME}/R/lib"
RUN fix-permissions "${R_LIBS_USER}"

# R pre-requisites
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    fonts-dejavu \
    gfortran \
    gcc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# R packages including IRKernel which gets installed globally.
RUN arch=$(uname -m) && \
    if [ "${arch}" == "aarch64" ]; then \
        # Prevent libmamba from sporadically hanging on arm64 under QEMU
        # <https://github.com/mamba-org/mamba/issues/1611>
        export G_SLICE=always-malloc; \
    fi && \
    mamba install --quiet --yes \
    'r-base' \
    'r-ggplot2' \
    'r-irkernel' \
    'r-rcurl' \
    'r-sparklyr' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Spylon-kernel
RUN mamba install --quiet --yes 'spylon-kernel' && \
    mamba clean --all -f -y && \
    python -m spylon_kernel install --sys-prefix && \
    rm -rf "/home/${NB_USER}/.local" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"



# USER devadmin

# Create app directory
WORKDIR /usr/local/myapp/

# Install app dependencies
COPY /src/ /usr/local/myapp/src/
COPY requirements.txt ./
# COPY /config/ /usr/local/myapp/config/

RUN pip install --upgrade pip


# RUN pip install --upgrade --no-cache-dir -r requirements.txt


RUN pip install pyspark && \
    pip install -U Flask && \
    pip install Flask-RESTful && \
    pip install Flask-JWT && \
    pip install flask-bcrypt && \
    pip install Flask-Migrate && \
    pip install flask_login && \
    pip install pandas && \
    pip install nltk && \
    pip install sqlalchemy && \
    pip install databases && \
    pip install asyncpg && \
    pip install psycopg2-binary && \
    # pip install psycopg2 && \
    pip install --upgrade werkzeug  && \
    pip install pyyaml  && \
    pip install pymysql && \
    pip install cryptography && \
    pip install simplejson  && \
    pip install six && \
    pip install matplotlib && \
    pip install seaborn && \
    pip install sklearn && \
    pip install pillow && \
    pip install surprise && \
    pip install lightgbm && \
    pip install eli5 && \
    pip install plotly && \
    pip install jupyterhub && \
    pip install wordcloud && \
    pip install xgboost && \
    pip install boto3 && \
    pip install redis && \
    pip install fastapi && \
    pip install uvicorn && \
    pip install sqlmodel && \
    pip install alembic && \
    pip install jose && \
    pip install pydub && \
    pip install opencv-python && \
    pip install asyncpg && \
    pip install librosa && \
    pip install transformers && \
    pip install SpeechRecognition && \
    pip install pyttsx3


EXPOSE 8880
# ENTRYPOINT ["python"]
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]

EXPOSE 5000 5050 8080 8888