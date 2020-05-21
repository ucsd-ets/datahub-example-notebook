# How to use

1. Create a new git repo using this as a template
2. Create a Docker Hub account
  1. Link the git repo to Docker hub
  2. Turn on automated builds in Docker Hub
2. Modify the Dockerfile
  1. Choose whether you use datascience or scipy-ml as the base image
  2. Add custom installations
3. Check in Dockerfile
3. Wait for image to build
4. Login to DSMLP using ieng6 or dsmlp-Login
5. launch-scipy-ml.sh -i my/image:latest

# Tips

Install Docker on your local computer to debug the build.

docker build .
