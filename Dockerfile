ARG BASE_CONTAINER=quay.io/jupyter/scipy-notebook:hub-5.4.6
# Based on docker-stacks images at https://github.com/jupyter/docker-stacks/blob/main/images/scipy-notebook/Dockerfile
# Ubuntu 24.04 LTS (noble)

FROM $BASE_CONTAINER

LABEL maintainer="Wing-Ho Ko <wingho@uw.edu>"

USER root

# Copy apt packages list
COPY --chown=$NB_UID:$NB_GID apt.txt /home/jovyan/

RUN apt-get update --fix-missing > /dev/null \
        && apt-get upgrade --yes \
        && if test -f "/home/jovyan/apt.txt" ; then \
            xargs -a /home/jovyan/apt.txt apt-get install --yes; \
        fi \
        && apt-get clean > /dev/null \
        && rm -rf /var/lib/apt/lists/*

# Install termscp
RUN TERMSCP_INSTALL_DIR=/usr/local/bin \
	curl --proto '=https' --tlsv1.2 -sSLf https://termscp.rs/install.sh | sh -s -- --yes \
	&& rm -rf install.sh

# Install micromamba
RUN curl -fsSL https://micro.mamba.pm/api/micromamba/linux-64/latest \
    | bzip2 -d | tar x --to-stdout bin/micromamba > /usr/local/bin/micromamba \
    && chmod +x /usr/local/bin/micromamba

ENV MAMBA_ROOT_PREFIX=/opt/conda

# Install Node
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Add wrapper for gitpuller
COPY --chmod=755 safe_gitpuller.sh /usr/local/bin/safe_gitpuller

USER $NB_UID

# Install Conda packages in batches to relieve memory pressure
COPY --chown=$NB_UID:$NB_GID conda-packages.txt /home/jovyan/

RUN set -ex \
    && micromamba install --quiet --yes --freeze-installed --file /home/jovyan/conda-packages.txt \
    && micromamba clean --all -f -y

RUN jupyter lab build -y \
  && jupyter lab clean -y \
  && jupyter labextension disable "@jupyterlab/apputils-extension:announcements" \
  && rm -rf "/home/${NB_USER}/.cache/yarn" \
  && rm -rf "/home/${NB_USER}/.node-gyp" \
  && npm cache clean --force 2>/dev/null || true \
  && fix-permissions "${CONDA_DIR}" \
  && fix-permissions "/home/${NB_USER}"

# Install Python packages
COPY --chown=$NB_UID:$NB_GID pip-packages.txt /home/jovyan/
RUN pip install -r pip-packages.txt \
  && jupyter server extension enable nbgitpuller --sys-prefix \
  && pip cache purge

# set variables
ENV PATH="/home/jovyan/.local/bin:${PATH}"
ENV BAT_THEME="ansi"

# Disable JupyterLab A11y checker, but leave installed
RUN jupyter labextension disable jupyterlab-a11y-checker
