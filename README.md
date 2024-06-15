# QIIME2023.7-Docker

This repository provides instructions for downloading, accessing, and using a Dockerized Ubuntu image with QIIME2 v2023.7 and the Sidle plugin preinstalled.

## Pull the Docker Image

To pull the Docker image from Docker Hub, use the following command:

`docker pull armalica/qiime2:v1`

## Usage

Once the Docker image is installed, you can access it using the following command:

sudo docker run --rm -it -v /path/to/input_files/:/tmp/mnt/ --entrypoint bash armalica/qiime2:v1

The `-v` flag attaches the directory containing input files on the host machine to the `/tmp/mnt/` folder inside the Docker container.

## Activating the QIIME Environment Inside the Docker Container

Once inside the Docker container, activate the QIIME2 environment using the following command:

`conda activate qiime2-2023.7`
