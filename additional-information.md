# Additional Information

## Dockerfile Best Practices

### Additional Kernels

To install a new kernel that can be selected within a jupyter notebook, you can look into creating a second conda environment and use [nb_conda_kernels](https://github.com/Anaconda-Platform/nb_conda_kernels) to add it in. 

### Keep your images small

Concatentate `RUN` steps into a single `RUN` block

```bash
# Creates a separate image layer for every RUN block
RUN apt-get -y update
RUN apt-get install -y python

# Single RUN block results in a smaller image
RUN apt-get -y update && \
    apt-get install -y python
```

If you've converted all your `RUN` statements and find that your container is still prohibitively large, try breaking your container into a multi-stage build or have multiple containers for different purposes.

### Use Mamba instead of Conda when Conda is slow

Sometimes you may need to install a conda package. If you include a statement like below:

```bash
RUN conda install <package> -y
```

and you find that it an in-ordinate amount of time to install, you can try using [mamba](https://github.com/mamba-org/mamba). It works faster.

If that still doesn't work, you can try to manually install your software

### Remove unused files and software

If you need to reduce the size of your image, try removing files and/or software you may not need. You can also try starting from our smallest image `ucsd-ets/datahub-base-notebook` as your starting point [An overview of standard Datahub/DSMLP containers maintained by UCSD EdTech Services](https://github.com/ucsd-ets/datahub-docker-stack/wiki/Stable-Tag)

