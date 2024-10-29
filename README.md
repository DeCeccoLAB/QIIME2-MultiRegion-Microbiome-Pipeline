# QIIME2023.7-Docker

This repository provides instructions for downloading, accessing, and using a Dockerized Ubuntu image with QIIME 2 v2023.7 and the Sidle plugin preinstalled.

To install docker on ubuntu machines please visit the [Docker website](https://docs.docker.com/engine/install/ubuntu/)

To know more about QIIME 2 please visit [QIIME 2](https://qiime2.org/)

This [site](https://docs.qiime2.org/2024.5/) is the official user documentation for QIIME 2, including installation instructions, tutorials, and other important information. 

CERCA ZENODO SE DEVI FARE UPLOAD DI GROSSI DATABASE: [ZENODO](https://zenodo.org/)

## Pull the Docker Image

To pull the Docker image from [Docker Hub](https://hub.docker.com/), use the following command:

`sudo docker pull armalica/qiime2:v1`

## Usage

Once the Docker image is installed, you can access it using the following command:

`sudo docker run --rm -it -v /path/to/input_files/:/tmp/mnt/ --entrypoint bash armalica/qiime2:v1`

The `-v` flag attaches the directory containing input files on the host machine to the `/tmp/mnt/` folder inside the Docker container.

## Activating the QIIME Environment Inside the Docker Container

Once inside the Docker container, activate the QIIME2 environment using the following command:

`conda activate qiime2-2023.7`

navigate in your analysis folder 

`cd /tmp/mnt/path/to/working/directory`

for convininence we will create several directories that will contain the itermidiate files for each V region

`mkdir ./V{2,3,4,67,8,9}` 

this command will create 6 new working folder 1 for each region

# Data import
For this ppipeline the deconvoluted fastq will be imported into QIIME2 environment using the manifest fastq method.

Note: this process will be repeated for each hypervarible(V) region 
```
 qiime tools import \
--type 'SampleData[SequencesWithQuality]' \
--input-path manifest.txt \ # a manifest file for each V region
--output-path single-end-demux.qza \
--input-format SingleEndFastqManifestPhred33V2
```
