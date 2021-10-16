# Instructions on Building a Custom Image for DataHub/DSMLP

This guide is for advanced DSMLP users (both students and instructors) who want to add or modify applications on their working environment using a custom Docker container.

For CUDA-enabled images, switch to the `cuda` branch for more information.

## Introduction

A Docker **image** is a snapshot of packaged applications, dependencies and the underlying operating system. Users can use the same Docker image anywhere on any machine running the Docker platform while having the same software functionality and behavior. **Docker Hub** is a public container registry you can download ("pull") and upload ("push") Docker images. Just like GitHub hosts git repositories, Docker Hub hosts and distributes Docker images. In this guide, we will build a custom Docker image by modifying a **Dockerfile**, building the image on a desired platform, and publishing it on Docker Hub.

Building and maintaining a Docker image follows three essential steps: build, share and deploy/test. It's likely for you to go through these steps several times until it achieves what you want. You can find an official tutorial from [docs.docker.com](https://docs.docker.com/get-started/) that demonstrates a general case, but this document is tailored specifically for DSMLP users.

### New changes June 2021

Docker Hub has modified its free plan, [removing](https://www.docker.com/blog/changes-to-docker-hub-autobuilds/) the Autobuilds feature that many users rely on for building images on Docker Hub's infrastructure, for free. The contents of this guide will reflect on that change and no longer recommend Docker Hub as a *build* platform.

## Step 0: Prerequisites

- A new **public** GitHub git repo using this as a template. Click "Use this template" at upper-right corner. You can also use an existing **public** repo by adding a `Dockerfile` at the repo's root level. The public visibility is to stay on the free plan that GitHub offers, which comes in to play later.

- A Docker Hub account. Register at <https://hub.docker.com/>. You will need this for publishing your new image ~~and configuring automated builds~~.

- A new **public** repository on Docker Hub. The name for it doesn't have to be the same as your GitHub repo.

- Create an Access Token on Docker Hub account. Follow this [documentation]. Name it "For Github Actions" and save the generated token locally.

## Step 1: Customize the Dockerfile

### Step 1.1 Base Imagee

- Choose the base container by uncommenting the corresponding line that sets the `BASE_CONTAINER` argument
  - [An overview of standard Datahub/DSMLP containers maintained by UCSD EdTech Services](https://support.ucsd.edu/its?id=kb_article_view&sysparm_article=KB0032173&sys_kb_id=12459737dbe69810a4bc41db13961976)
  - The `datahub-base-notebook` image contains Jupyter and common data science tools from Python and R. Derived from [`jupyter/datascience-notebook`](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-datascience-notebook).
  - The `datascience-notebook` image has a few more packages installed using pip.
  - The `scipy-ml` image has a wider range of packages including tensorflow, pytorch, including CUDA 11 support, generally used for GPU-accelerated workflows.

- **Note**: Although `scipy-ml` has more features, building an image on top of it will take longer. It's better to apply a minimal set of required tools to the `base-notebook` than for saving image size and reduce image build time.

### Step 1.2 System Packages

- Use `USER root` to gain root privileges for installing system packages. This line is already typed out for you.

- Install system-level packages using `apt-get`
  - The example at line 19 installs a system utility called `htop`.
  - Specify more packages as extra arguments: `apt-get -y install htop ping`

### Step 1.3 Python Libraries

- Note: It is recommended to use `pip` instead of `conda` as much as possible. `pip` is more forgiving in resolving package conflicts, and generally much faster.

- Install conda packages
  - Use `RUN conda install --yes <package1> <package2>` to install all required conda packages in one go
  - (Optional) Use `RUN conda clean -tipy` to reduce image size

- Install pip packages
  - Only use pip after conda.
  - Use `pip install --no-cache-dir <package>`
  - Alternatively, you can provide a `requirements.txt` file in the project root and use `pip install --no-cache-dir -r requirements.txt` to reference it. List each package as a single line.

- Leave the rest of the Dockerfile as is


## Step 2: Build the Image

In this step you will build the image using the Dockerfile you created. Here you have two options: 

1. Install the Docker Client and build the image locally and push (upload) it to Docker Hub. This will require you have [Docker Desktop](https://www.docker.com/products/docker-desktop) installed on your local Windows PC/Mac or [Docker Engine](https://docs.docker.com/engine/install/) on Linux. You can also use a remote Linux server with Docker installed for building Docker Images and testing them. The commands will be the same, but if you don't have docker locally, you cannot develop locally, only on DSMLP. For development on Windows, I strongly recommend you to install the [WSL 2 engine](https://docs.microsoft.com/en-us/windows/wsl/install) for a better experience.

2. ~~Make use of the free [automated build](https://docs.docker.com/docker-hub/builds/#configure-automated-build-settings) service and Docker Hub will build and distribute the image for you. If you are feeling confident, go straight to this option, but it is quite difficult to debug and pinpoint the build issue if there is one.~~ Removed since no longer free

2. Setup a [GitHub Actions](https://github.com/features/actions) configuration file inside your project. A template is provided and require minimum modification.

It is recommended to use both routes for easier debugging and shorter turnaround time on successful builds. Option 2 is much easier but to understand the basics, please go through Option 1 beforehand. Installing Docker on your local setup is sometimes a headache, however you can take advantage of the $100 DigitalOcean credit from the [GitHub Student Developer Pack](https://education.github.com/pack) and launch a Docker Droplet there. Or use any remote Linux box you can find for free. Check out the resources in the Appendix.

### Option 1: Use Docker Desktop/Docker Engine

After Docker is installed, launch a terminal and navigate to the your git directory containing the Dockerfile.

Make sure to double check the name of your GitHub/DockerHub account and the names of the GitHub repo and Docker Hub repo. The full image name, for when you pull the image from somewhere else, will be `<dockerhub-username>/<dockerhub-repo-name>`, with an optional `:<tag>` that immediately follows it. When the tag isn't supplied, it will use `:latest` as default. We will reference this full name as `<image-fullname>` for the commands that follow.

#### Step 2.1.1 Build

Type "`docker build -t <image-fullname> .`" and hit \<Enter\>, notice the "period/dot" at the end of the command, which denotes the current directory. Docker will then build the image in the current directory's context. The resulting image will be labeled `<image-fullname>`. Monitor the build process for errors.

#### Step 2.1.2 Debug

If the build fails, take note of the last command Docker that was run and start debugging from there. Run the build command again after editing the Dockerfile. Sometimes, it is better to launch the intermediate docker image that follows a step and launch the image from there and try a few commands. To do this, use the command in Step 2.1.3 Test Run.

This will help you find the name of the intermediate image. If `Step 4` fails, look through the output and finds the image from `Step 3`, in the following example output, we will use the image `51a4d2ec5e16` to debug.

```
Step 3/14 : USER root           # Step count and command
 ---> Running in 4e32937f1e93   # temporary container
 ---> 51a4d2ec5e16              # result image (use this to debug)
```

Some commmon errors/mistakes here include:

1. not supplying the default yes `-y` option to the install command, causing it to timeout.

2. If the error message says it finds `/r/n` in one of your files, change the end of line sequence to from CRLF to LF. You can do this in an editor or use the utility `dos2unix`. This typically happens on Windows machines.

#### Step 2.1.3 Test Run

- Once the image is successfully built, use `docker run --rm -it <image-fullname> /bin/bash` to enter the image. `-it` denotes interactive mode, and `--rm` tells docker to remove the container after exit. Check if it has all the functionality you want. Use `exit` to exit from the container. If something is wrong, go back to the build step and start over.

#### Step 2.1.4 Push

- Log in to Docker Hub on the Docker Client. This can be done using the GUI or by using the command `docker login <username>`.

- push the image `docker push <image-fullname>`, the tag will default to `latest`. If you want to push a different tag, add `:<tag>` at the end of the full name.

- If you are using a remote pay-as-you-go Linux VM such as DigitalOcean, don't forget to remove the instance to save cost!

### ~~Option 2: Setup automated builds on Docker Hub~~

### Option 2: Use Github Actions

After going through the previous option, you should be familiar with the entire workflow of building, testing, and pushing the Docker image. Now we can use Github Actions to automatically do these things for us, for free!

1. Make a new file `.github/workflows/docker.yml` along with the directories that contains it. Notice here the `.github` will be a hidden directory, which can be hidden graphically on Windows if you don't have that setting enabled.

2. Here we will use the same file in this repo as a template for yours. This is a YAML configuration file with the syntax used for Github Workflows. In `jobs.docker.steps.[1]`, fill in your `<image-fullname>` from earlier and your Docker Hub username.

3. Leave the rest of the content as is. You will find that it contains all the necessary steps in Option 1. If you are feeling confident, add more steps to augment the workflow.

4. **Important**: Go to your Github repo's settings, under "Secrets", make a "New Repository Secret". Use the name "`DOCKERHUB_PASSWORD`" and fill in the token saved from the prerequisites. When this action is run, the secret is passed in and will be hidden in the workflow logs, which are public.

5. Commit and push the changes to GitHub. In the "Actions" tab, there will be a new workflow and under there, you can check the progress and output.

6. The triggers for this workflow are narrowly defined. It will only run if any of `["requirements.txt", "Dockerfile", ".github/workflows/main.yml"]` is changed in the `main` or `master` branch. Feel free to modify this behavior.

For more information, check out the syntax for Github Actions and relevant documentation, [here](https://docs.github.com/en/actions/learn-github-actions/workflow-syntax-for-github-actions).

## Step 3: Launch a Pod on DSMLP

- SSH to `dsmlp-login.ucsd.edu`

- RUN `launch-scipy-ml.sh -i <image-fullname> -P Always` . The `-P Always` flag will force the docker host to sync, as it pulls the latest version of the image manifest. Note: a docker image name follows the format `<user>/<image>:<tag>`. The `:<tag>` part will be assumed to be `:latest` if you don't supply it to the launch script. Use tags like `v1` or `test` in the build step to have control over different versions of the same docker image.

- Wait for the node to download the image. Download time depends on the image size.

- If it timeout/fails to launch, check `kubectl logs <pod-name>` or contact ETS service desk for help.

# Tips

- If you are repeatedly using the pod or sharing the custom image among a few other people within a day, use the same node to reduce spawn time (without download). You can do this by adding a `-n <node-number>` at the end of the launch command.

- To disable launching jupyter notebook upon entry, override the default executable by adding `CMD ["/bin/bash"]` as the last layer (as last line in `Dockerfile`). You can always launch the notebook again and manually port-forward on dsmlp-login. `kubectl port-forward pods/<POD_NAME> <DSMLP_PORT>:8888`

# Resources/Further Reading

- [**DSMLP Knowledge Base Articles**](https://support.ucsd.edu/its?id=kb_category&kb_category=7defd803db49fb08bd30f6e9af961979&kb_id=e343172edb3c1f40bd30f6e9af961996)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Cheat Sheet (pdf)](https://www.docker.com/sites/default/files/d8/2019-09/docker-cheat-sheet.pdf)
- [Original version of this guide](https://docs.google.com/document/d/1LPfqHvk2Itm_ckafrxRVxXQdr5BSozjsv_TURQDj9x8/edit)

# Appendix

- [DigitalOcean Docker Droplet](https://marketplace.digitalocean.com/apps/docker), this will give you a Linux VM with Docker installed ready to go. Start with any configuration with at least 8GB of memory and up it if working with a large image.
- [GitHub Student Developer Pack](https://education.github.com/pack)
