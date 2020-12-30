# 1) choose base container
# generally use the most recent tag

# data science notebook
# https://hub.docker.com/repository/docker/ucsdets/datascience-notebook/tags
FROM jupyter/scipy-notebook:d113a601dbb8

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

# CUDA Toolkit
RUN conda install -y cudatoolkit=10.1 cudnn nccl && \
    conda clean --all -f -y

# Tensorflow 2.*
RUN pip install --no-cache-dir --upgrade-strategy only-if-needed \
    tensorflow jupyter-tensorboard

# Tensorflow 1.15
# RUN pip install --no-cache-dir tensorflow-gpu==1.15

# Pytorch 1.7.*
# Copy-paste command from https://pytorch.org/get-started/locally/#start-locally
# Use the options stable, linux, pip, python and appropriate CUDA version
RUN pip install --no-cache-dir \
    torch==1.7.1+cu101 torchvision==0.8.2+cu101 torchaudio==0.7.2 \
    -f https://download.pytorch.org/whl/torch_stable.html

# #  Add startup script
USER root
COPY /run_jupyter.sh /
RUN chmod 755 /run_jupyter.sh

# # 4) change back to notebook user
USER $NB_UID

# # Override command to disable running jupyter notebook at launch
# # CMD ["/bin/bash"]