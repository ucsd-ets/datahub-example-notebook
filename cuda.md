# Building CUDA-enabled Images for DataHub/DSMLP

In this branch we will cover the starting steps of creating a GPU accelerated Docker Image for DSMLP. It's recommended to follow the steps in the "master" branch before continuing.

**Note**: our standard [scipy-ml-notebook](https://github.com/ucsd-ets/datahub-docker-stack/wiki/Stable-Tag) has CUDA installed with a compatible PyTorch and Tensorflow for use on DSMLP. Please use that image if that's all you require since installing a working CUDA environment is time consuming.

## DSMLP: Available GPUs

As of Fall 2020, there are 15 GPU nodes on the DSMLP cluster available for classroom use, and each node has 8 NVIDIA GPUs installed. These GPUs are dynamically assigned to a container on start-up when requested and will stay attached until that container is deleted, meaning a GPU will remain occupied even if it's actually not running anything.


| GPU Model      | VRAM | Amount | Node                            |
|----------------|------|--------|---------------------------------|
| NVIDIA 1080 Ti | 11GB | 80     | n01 through n12 except n09, n10 |
| NVIDIA 2080 Ti | 11GB | 32     | n18, n21, n22, n24              |
| NVIDIA 1070 Ti | 8GB  | 7      | n10                             |


## Install CUDA, PyTorch, and TensorFlow

*Note: The Datahub/DSMLP cannot guarantee that versions of Python libraries that use particular CUDA versions will work on the platform as CUDA versions must be synced to specific [Linux x86_64 Driver Versions](https://docs.nvidia.com/deploy/cuda-compatibility/index.html#binary-compatibility__table-toolkit-driver)*

The graphics driver will be installed automatically on the container on start-up. It can be challenging to get CUDA compatibility working in a custom environment. You can find the latest CUDA Toolkit supported on DSMLP by checking how we install it within our [scipy-ml-notebook](https://github.com/ucsd-ets/datahub-docker-stack/blob/main/images/scipy-ml-notebook/Dockerfile) container. The version of CUDA in this Dockerfile is the latest version of CUDA the DSMLP supports, and versions > what's defined may not work on the platform.

Please see the [scipy-ml-notebook](https://github.com/ucsd-ets/datahub-docker-stack/blob/main/images/scipy-ml-notebook/Dockerfile) Dockerfile for supported TensorFlow and Pytorch versions.

<!-- ## Dockerfile: Write Access to /opt/conda -->

# Resources/Further Reading
- [**DSMLP Knowledge Base Articles**](https://support.ucsd.edu/its?id=kb_category&kb_category=7defd803db49fb08bd30f6e9af961979&kb_id=e343172edb3c1f40bd30f6e9af961996)
- [CUDA Compatibility Table](https://docs.nvidia.com/deploy/cuda-compatibility/index.html#binary-compatibility__table-toolkit-driver)
- [cuDNN Support Matrix](https://docs.nvidia.com/deeplearning/cudnn/support-matrix/index.html)