# QIIME2023.7-Docker

This repository provides instructions for downloading, accessing, and using a Dockerized Ubuntu image with QIIME 2 v2023.7 and the Sidle plugin preinstalled.

To install docker on ubuntu machines please visit the [Docker website](https://docs.docker.com/engine/install/ubuntu/)

To know more about QIIME 2 please visit [QIIME 2](https://qiime2.org/)

This [site](https://docs.qiime2.org/2024.5/) provides the official QIIME 2 user documentation, including installation instructions, tutorials, and other essential information. 

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

Navigate to your analysis folder.

`cd /tmp/mnt/path/to/working/directory`

For convenience, we will create several directories to store the intermediate files for each V region.

`mkdir ./V{2,3,4,67,8,9}` 

This command will create six new working folders, one for each region.

# Data import
In this pipeline, the deconvoluted FASTQ files will be imported into the QIIME2 environment using the manifest FASTQ method. The manifest file should be prepared as a .tsv file in the following format:

|  sample-id | absolute-filepath |
| ------------- | ------------- |
| sample-1  |  /tmp/mnt/path/to/file/sample-1.V#.FR.fastq | 
| sample-2  |  /tmp/mnt/path/to/file/sample-2.V#.FR.fastq | 

The metagenomicsPP plugin will generate six files for each deconvoluted FASTQ file corresponding to each V region. We will import the specific V region for every sample in our dataset. Replace `#` with the actual number of the region you wish to import.

Upload the manifest files in the corresponding V region folder, then for each folder:

`cd V#/`

Note: This process will be repeated for each hypervariable (V) region.
```
 qiime tools import \
--type 'SampleData[SequencesWithQuality]' \
--input-path manifestV#.txt \ # a manifest file for each V region
--output-path single-end-demuxV#.qza \
--input-format SingleEndFastqManifestPhred33V2
```
After importing, we can assess the read quality to identify the sequence length where the quality score is ≥ 25 at the 25th percentile of the quality score distribution, which is approximately 200 bp.
```
qiime demux summarize \
--i-data single-end-demuxV#.qza \
--o-visualization single-end-demuxV#.qzv
```

# DADA2 denoising
To keep track of our progress, we recommend creating a folder to store the subsequent files. Since the denoising process is sensitive to read length, choosing a length with poor-quality reads will result in a low yield of usable reads.

We will create a folder specifying the trimming lengths that DADA2 will use for the reads—in this example, 0 on the left side and 200 on the right:
```
mkdir dada2-0-200
cd dada2-0-200
```
As described in our paper and in the dada2 documentation, ion torrent data should be denoised with the `-pyro` option enabled to account for the different sequencing platform.
Since the metagenomics PP preprocess the fastq files we can avoid to trim on the left part of the reads `--p-trim-left 0` while on the right side we will truncate at the legth chose before ` --p-trunc-len 200 `
```
qiime dada2 denoise-pyro \
--i-demultiplexed-seqs ../single-end-demuxV#.qza \
  --p-trim-left 0 \
  --p-trunc-len 200 \
  --p-n-threads 4 \ # Change the number of threads to speed up the denoising process
  --o-table table-dada2-pyroV#.qza \
--o-representative-sequences rep-seqs-dada2-pyroV#.qza \
  --o-denoising-stats stats-dadaV#.qza
```
Now we can proceed to inspect the denoising stats, for a good deonoising run we should keep at least 70-80% of our original read counts

```
  qiime metadata tabulate \
  --m-input-file stats-dadaV#.qza \
  --o-visualization stats-dada2V#.qzv
qiime feature-table tabulate-seqs \
  --i-data rep-seqs-dada2-pyroV#.qza \
  --o-visualization rep-seqs-dada2-pyroV#.qzv
```
