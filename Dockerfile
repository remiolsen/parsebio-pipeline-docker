FROM continuumio/miniconda3:latest

ARG PIPELINE_VERSION=1.7.1
ARG IMAGE_VERSION=0.0.1

LABEL author="Remi-Andre Olsen" \
      description="Parsebio pipeline Docker image" \
      maintainer="remi-andre.olsen@scilifelab.se" \
      version="${IMAGE_VERSION}" \
      pipeline.version="${PIPELINE_VERSION}"

# Ugly hack. We put most of the dependencies in the environment.yaml and let mamba manage them.
COPY ParseBiosciences-Pipeline.${PIPELINE_VERSION}.zip .
COPY environment.yaml .

RUN apt-get update && apt-get install -y unzip && \
    unzip ParseBiosciences-Pipeline.${PIPELINE_VERSION}.zip && \
    rm ParseBiosciences-Pipeline.${PIPELINE_VERSION}.zip && \
    conda env create -n spipe --file environment.yaml && \
    conda clean --all --yes && \
    apt-get remove -y unzip && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV ENV_NAME=spipe
ENV PATH="/opt/conda/envs/spipe/bin:${PATH}"

# This is an unhinged workaround to get the pipeline installed with the correct numpy version. The pipeline's setup.py and pyproject.toml specify numpy>=2.0, but this causes it to install numpy 2.4.4 and causes incompatibility issues.
RUN cd ParseBiosciences-Pipeline.${PIPELINE_VERSION} && \
    sed -i 's/numpy>=2.0/numpy==2.0/' setup.py && sed -i 's/numpy>=2.0/numpy==2.0/' pyproject.toml && \
    conda run -n spipe pip install -v --no-cache-dir ./

RUN split-pipe --help