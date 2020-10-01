# Instructions on Building a Custom Image for DataHub/DSMLP

This guide is for advanced DSMLP users (both students and instructors) who want to add or modify applications on their working environment using a custom Docker container. 

## Introduction

A Docker **image** is a snapshot of packaged applications, dependencies and the underlying operating system. Users can use the same Docker image anywhere on any machine running the Docker platform while having the same software functionality and behavior. **DockerHub** is a public container registry you can download ("pull") and upload ("push") Docker images. Just like GitHub hosts git repositories, DockerHub hosts and distributes Docker images. In this guide, we will design a custom Docker image by modifying a **Dockerfile**, build the image and publish it on DockerHub. 

## Step 0: Prerequisites

- A new GitHub git repo using this as a template. Click "Use this template" at upper-right corner. You can also use an existing repo by adding a `Dockerfile` at the repo's root level.

- A Docker Hub account. Register at <https://hub.docker.com/>. You will need this for publishing your new image and configuring automated builds.

- A new public repo on DockerHub. You can name it whatever you want.

## Step 1: Customize the Dockerfile

- Choose the base container by uncommenting the corresponding line that set the `BASE_CONTAINER` argument
  - [An overview of standard Datahub/DSMLP containers maintained by UCSD EdTech Services](https://support.ucsd.edu/its?id=kb_article_view&sysparm_article=KB0032173&sys_kb_id=12459737dbe69810a4bc41db13961976)
  - `datascience-notebook` base image includes conda and basic python packages for data science (pandas, scipy, matplotlib) from [miniconda](https://docs.conda.io/en/latest/miniconda.html).
  - `scipy-ml` image has a wider range of packages including tensorflow, pytorch, including CUDA 10 support, generally used for GPU-accelerated workflows.
  - Note: Although `scipy-ml` has more functionality, the build process may take longer and result in a larger image.

- Use `USER root` to gain root privileges for installing system packages. This line is already typed out for you.

- Install system-level packages using `apt-get`
  - The example at line 19 installs a system utility called `htop`.

- Install conda packages
  - Use `RUN conda install --yes <package1> <package2>` to install all required conda packages in one go
  - (Optional) Use `RUN conda clean -tipy` to reduce image size
  - Recommended: Use conda to install least amount of packages required. Solving conda dependency graphs takes a much longer time than using pip.

- Install pip packages
  - Use `pip install --no-cache-dir <package>` for installing pip packages

- Leave the rest of the Dockerfile as is


## Step 2: Build the Image

In this step you will build the image using the Dockerfile you created. Here you have two options: 
1. Build the image locally and push (upload) it to DockerHub. This will require you have [Docker Desktop](https://www.docker.com/products/docker-desktop) installed on your local Windows PC/Mac or [Docker Engine](https://docs.docker.com/engine/install/) for Linux. 
2. Make use of the free [automated build](https://docs.docker.com/docker-hub/builds/#configure-automated-build-settings) service and DockerHub will build and distribute the image for you. If you are feeling confident, go straight to this option, but it is quite difficult to debug and pinpoint the build issue if there is one.

It is recommended to try both routes for easier debugging and shorter turnaround time on successful builds. If you don't want to install Docker on your local machine, you can always use a $50 DigitalOcean credit from the [GitHub Student Developer Pack](https://education.github.com/pack) and launch a Docker Droplet there.

### Option 1: Use Docker Desktop/Docker Engine
- After Docker is installed, launch a terminal and navigate to the git directory containing the Dockerfile.
- Type `docker build -t test .` and hit Enter. Docker will build the image according to the local Dockerfile. The resulting image will be labeled test. If the build fails, take note of the last command Docker ran and start debugging from there. Run the command again to rebuild after the Dockerfile is edited.
- Once the image is successfully built, use `docker run --rm -it test /bin/bash` to enter the image in a container. Test if it has all the functionality you want. Use `exit` to exit from the container. The container will be automatically deleted.
- (Optional if option 2 is also used) Log in to DockerHub on your local Docker instance. Retag the image by using `docker tag test <dockerhub-username>/<dockerhub-repo>`. And push the image `docker push <dockerhub-username>/<dockerhub-repo>`.
- Another method for modifying the image without modifying the image is by doing changes in a lasting container from `docker run -it test /bin/bash`, use CTRL+P-Q to detach from container, find the running container in `docker ps` and `docker commit CONTAINER_ID <dockerhub-username>/<dockerhub-repo>` followed by `docker push <dockerhub-username>/<dockerhub-repo>`.

### Option 2: Setup automated builds on DockerHub
- Commit and push local changes to GitHub
- Link GitHub account to DockerHub: [instructions](https://docs.docker.com/docker-hub/builds/link-source/#link-to-a-github-user-account)
- Set up automated builds: [instructions](https://docs.docker.com/docker-hub/builds/link-source/#link-to-a-github-user-account)
- Wait for the build to finish. It can take up to 2 hours for a complex build during business hours.

## Step 3: Launch a Pod on DSMLP
- Log in to dsmlp-login.ucsd.edu
- RUN `launch-scipy-ml.sh -i <dockerhub-username>/<dockerhub-repo>`
- Wait for the node to download the image. Download time depends on the image size.
- If it timeout/fails to launch, check `kubectl logs <pod-name>` or contact ETS service desk for help.


# Tips

- If you are repeatedly using the pod or sharing the custom image among a few other people within a day, use the same node to reduce spawn time (without download). You can do this by adding a `-n <node-number>` at the end of the launch command.
- To disable launching jupyter notebook upon entry, override the default executable by adding `CMD ["/bin/bash"]` as the last layer (as last line in `Dockerfile`). You can always launch the notebook again and manually port-forward on dsmlp-login. `kubectl port-forward pods/<POD_NAME> <DSMLP_PORT>:8888`

# Resources/Further Reading
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Cheat Sheet (pdf)](https://www.docker.com/sites/default/files/d8/2019-09/docker-cheat-sheet.pdf)
- [Original version of this guide](https://docs.google.com/document/d/1LPfqHvk2Itm_ckafrxRVxXQdr5BSozjsv_TURQDj9x8/edit)
