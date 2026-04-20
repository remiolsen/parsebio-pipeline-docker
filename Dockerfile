FROM mambaorg/micromamba:2.5.0

ARG PIPELINE_VERSION=1.7.1
ARG IMAGE_VERSION=0.0.1

LABEL author="Remi-Andre Olsen" \
      description="Parsebio pipeline Docker image" \
      maintainer="remi-andre.olsen@scilifelab.se" \
      version="${IMAGE_VERSION}" \
      pipeline.version="${PIPELINE_VERSION}"

# Ugly hack. We put most of the dependencies in the environment.yaml and let mamba manage them.
COPY --chown=$MAMBA_USER:$MAMBA_USER ParseBiosciences-Pipeline.${PIPELINE_VERSION}.zip .
COPY --chown=$MAMBA_USER:$MAMBA_USER environment.yaml .

USER root
RUN apt-get update && apt-get install -y unzip sudo
USER $MAMBA_USER

RUN unzip ParseBiosciences-Pipeline.${PIPELINE_VERSION}.zip && \
    rm ParseBiosciences-Pipeline.${PIPELINE_VERSION}.zip && \
    micromamba create -n parse --file environment.yaml && \
    micromamba clean --all --yes

ENV ENV_NAME=parse
ENV PATH="/opt/conda/envs/parse/bin:${PATH}"
ARG MAMBA_DOCKERFILE_ACTIVATE=1

# This is an unhinged workaround to get the pipeline installed with the correct numpy version. The pipeline's setup.py and pyproject.toml specify numpy>=2.0, but this causes it to install numpy 2.4.4 and causes incompatibility issues.
RUN cd ParseBiosciences-Pipeline.${PIPELINE_VERSION} && eval "$(micromamba shell hook --shell bash)" && micromamba activate parse && \
    sed -i 's/numpy>=2.0/numpy==2.0/' setup.py && sed -i 's/numpy>=2.0/numpy==2.0/' pyproject.toml && pip install -v --no-cache-dir ./


USER root
RUN apt-get remove -y unzip && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*
USER $MAMBA_USER

RUN split-pipe --help