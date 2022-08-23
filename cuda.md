# Building CUDA-enabled Images for DataHub/DSMLP

In this branch we will cover the starting steps of creating a GPU accelerated Docker Image for DSMLP. It's recommended to follow the steps in the "master" branch before continuing.

**Note**: our standard [scipy-ml-notebook](https://github.com/ucsd-ets/datahub-docker-stack/wiki/Stable-Tag) has CUDA installed with a compatible PyTorch and Tensorflow for use on DSMLP. Please use that image if that's all you require since installing a working CUDA environment is time consuming.

## DSMLP: Available GPUs

As of Fall 2020, there are 15 GPU nodes on the DSMLP cluster available for classroom use, and each node has 8 NVIDIA GPUs installed. These GPUs are dynamically assigned to a container on start-up when requested and will stay attached until that container is deleted, meaning a GPU will remain occupied even if it's actually not running anything.

The graphics driver will be installed automatically to the container on start-up. The current driver version is `418.88`. Because of this, the latest CUDA Tookit that is supported on DSMLP is version `10.1`, according to [NVIDIA](https://docs.nvidia.com/deploy/cuda-compatibility/index.html#binary-compatibility__table-toolkit-driver).

| GPU Model      | VRAM | Amount | Node                            |
|----------------|------|--------|---------------------------------|
| NVIDIA 1080 Ti | 11GB | 80     | n01 through n12 except n09, n10 |
| NVIDIA 2080 Ti | 11GB | 32     | n18, n21, n22, n24              |
| NVIDIA 1070 Ti | 8GB  | 7      | n10                             |

## Dockerfile: CUDA Tookit

Choosing the right version of CUDA is important because some legacy codebase relies on specific old versions of CUDA and their compatible software in order to run. We will use CUDA `10.1` for this example.

The following command let conda install CUDA Toolkit `11.2` along with a deep learning accelerator (cuDNN) and a device communication library (NCCL).

```
RUN conda install -y cudatoolkit=11.2 cudnn nccl
```

In the example Dockerfile, the above command is followed by `conda clean --all -f -y`, which cleans up the unnecessary cache. The two commands are executed sequentially with `&&` in between in order to reduce overall size in that layer.

## Dockerfile: Deep Learning Libraries

### TensorFlow

There are two major versions of tensorflow APIs and they cannot coexist in the same environment. Look into the Dockerfile for the commands. Using `tensorflow` will get the latest `2.*` version. 

### PyTorch

Installing PyTorch will require you to go on their [website](https://pytorch.org/get-started/locally/#start-locally), select the appropriate specifications for the system and paste in the command. Remember to add `--no-cache-dir` after `pip install` to reduce image size.

## Dockerfile: Additional Kernels

To install a new kernel that can be selected within a jupyter notebook, you can look into creating a second conda environment and use [nb_conda_kernels](https://github.com/Anaconda-Platform/nb_conda_kernels) to add it in. 

<!-- ## Dockerfile: Write Access to /opt/conda -->

# Resources/Further Reading
- [**DSMLP Knowledge Base Articles**](https://support.ucsd.edu/its?id=kb_category&kb_category=7defd803db49fb08bd30f6e9af961979&kb_id=e343172edb3c1f40bd30f6e9af961996)
- [CUDA Compatibility Table](https://docs.nvidia.com/deploy/cuda-compatibility/index.html#binary-compatibility__table-toolkit-driver)
- [cuDNN Support Matrix](https://docs.nvidia.com/deeplearning/cudnn/support-matrix/index.html)