# QIIME 2 Multi-region Pipeline

This repository provides instructions for downloading, accessing, and using a Dockerized Ubuntu image with QIIME 2 v2023.7 and the Sidle plugin preinstalled. Additionally, the pipeline is specifically designed to process Ion Torrent sequencing data, enabling accurate and efficient microbial diversity profiling.

To install docker on ubuntu machines please visit the [Docker website](https://docs.docker.com/engine/install/ubuntu/)

To know more about QIIME 2 please visit [QIIME 2](https://qiime2.org/)

This [site](https://docs.qiime2.org/2024.5/) provides the official QIIME 2 user documentation, including installation instructions, tutorials, and other essential information. 


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
# Merging DADA2 Tables and Representative Sequences
After denoising each region separately, we need to merge them to use all regions collectively. QIIME 2 provides tools to merge both DADA2 tables and ASV sequences.

Now, let’s return to the working directory and gather all the files required for the merging process.

Note: Before proceeding, ensure you have a single DADA2 folder containing the files from the correct denoising run.
```
cd ../../
cp ./V*/dada*/table-dada2-pyro*.qza ./
cp ./V*/dada*/rep-seqs-dada2-pyro*.qza ./
```
These commands will copy the representative sequences and tables from each V folder into the main working directory.
We can now proceed with merging the files:
```
qiime feature-table merge \
 --i-tables table-dada2-pyroV{2,3,4,67,8,9}.qza \
 --p-overlap-method sum  \
 --o-merged-table merged-tableV2-9.qza

qiime feature-table merge-seqs \
 --i-data rep-seqs-dada2-pyroV{2,3,4,67,8,9}.qza \
 --o-merged-data rep-seqsV2-9.qza  
```
To replicate IR's results, ensure that all overlapping ASVs across regions are summed by using the `--p-overlap-method sum` option.

# Insert fragment sequences into reference phylogenies with SEPP
Now that we have our merged sequences and table we can proceed to generate the phylogenic tree using the fragment insertion algorithm SEPP.
The reference database used in our paper can be found in [QIIME 2 resources page](https://docs.qiime2.org/2023.7/data-resources/)

Let's create a folder to store our files
```
mkdir phylogeny
cd phylogeny
```
We can now proceed with the fragment insertion process. As noted by the original developers, this step may take considerable time depending on the number of samples analyzed. Since this algorithm requires 8 GB of RAM per core for parallelization, ensure you do not exceed this limit to avoid potential interruptions due to memory issues.

For example, if your workstation has 32 GB of RAM, it is safe to parallelize the process using up to 8 threads.

```
qiime fragment-insertion sepp \
  --i-representative-sequences ../rep-seqsV2-9.qza \
  --i-reference-database /tmp/mnt/path/to/sepp-refs-gg-13-8.qza \
  --o-tree insertion-tree.qza \
  --p-threads 8 \
  --o-placements insertion-placements.qza 
```
Now the sequences that were discarded during the insertion process should be filtered from the merged table and rep seqs

```
qiime fragment-insertion filter-features \
  --i-table ../merged-tableV2-9.qza \
  --i-tree insertion-tree.qza \
  --o-filtered-table filtered_table.qza \
  --o-removed-table removed_table.qza

qiime feature-table filter-seqs \
  --i-data ../rep-seqsV2-9.qza \
  --i-table filtered_table.qza \
  --o-filtered-data filtered-seqs.qza
```
Note: now that we filtered the sequences not recognized we have our final dataset, from now you can use all the other tools offered by QIIME 2 

# Taxonomic analysis
Next, we will classify our representative sequences using the VSEARCH algorithm. To leverage all regions effectively, we need to prepare a feature classifier trained on our regions of interest. For this, we will download the Greengenes database, prepare the reference sequences, and then proceed with classification

## Database preparation
First, download the taxonomy and sequence files from [Greengenes](https://greengenes.secondgenome.com/) and import them into QIIME 2:
In a different directory:
```
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path gg_13_5.fasta \
  --output-path gg_13_5.qza

qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path  gg_13_5_taxonomy.txt \
  --output-path ./gg_13_5_taxonomy.qza
```
Next, we can proceed to extract the reads using the primer set for the entire 16S gene. This process may take some time, so we recommend parallelizing it by adding more cores with the `--p-n-jobs option` The chosen primer targets the full 16S gene. Although the 16S metagenomics kit does not sequence the V1 region, we opted to include coverage for this region to capture the conserved area between V1 and V2.
```
qiime feature-classifier extract-reads \
  --i-sequences gg_13_5.qza \
  --p-f-primer AGRGTTYGATYMTGGCTCAG \
  --p-r-primer  RGYTACCTTGTTACGACTT \
  --p-min-length 1400 \
  --p-max-length 1600 \
  --p-n-jobs 12 \ 
  --o-reads gg_13_5V2-9/ref-seqs_gg_13_5_V2-9.qza
```
## VSEARCH Taxonomy classification
Now, we can return to our working directory and classify our filtered sequences using the extracted reads from the database:
```
qiime feature-classifier classify-consensus-vsearch \
  --i-query phylogeny/filtered-seqs.qza \
  --i-reference-reads /tmp/mnt/path/to/gg_13_5V2-9/ref-seqs_gg_13_5_V2-9.qza \
  --i-reference-taxonomy /tmp/mnt/path/to/gg_13_5_taxonomy.qza \
  --p-perc-identity 0.99 \
  --p-threads 10 \
  --output-dir ./taxonomy99
```
### OPTIONAL: Database Curation
Because `classify-consensus-vsearch` can be memory-intensive—especially for large datasets—our Docker image includes the [RESCRIPt](https://github.com/bokulich-lab/RESCRIPt) plugin by default. You can use RESCRIPt to:

- **Deduplicate reference sequences**  
- **Filter out unwanted sequences**, such as mitochondria or chloroplasts  
- **Remove sequences undefined at higher taxonomic levels**

These steps can significantly reduce the size of your database and help optimize classification performance.
```
qiime taxa filter-seqs \
   --i-sequences /tmp/mnt/path/to/gg_13_5V2-9/ref-seqs_gg_13_5_V2-9.qza \
   --i-taxonomy /tmp/mnt/path/to/gg_13_5_taxonomy.qza \
   --p-exclude "p__;,k__;" \
   --p-mode contains \
   --o-filtered-sequences /tmp/mnt/path/to/gg_13_5V2-9/filtereddb/ggV2-9-filtered-phylum-def-sequences.qza

 qiime rescript dereplicate \
    --i-sequences /tmp/mnt/path/to/gg_13_5V2-9/filtereddb/ggV2-9-filtered-phylum-def-sequences.qza \
    --i-taxa /tmp/mnt/path/to/gg_13_5_taxonomy.qza \
    --p-mode 'uniq' \
    --o-dereplicated-sequences tmp/mnt/path/to/gg_13_5V2-9/filtereddb/filtereddb/ggV2-9-filtered-phylum-def-sequences-uniq.qza \
    --o-dereplicated-taxa  tmp/mnt/path/to/gg_13_5V2-9/filtereddb/filtereddb/ggV2-9-filtered-phylum-def-tax-derep-uniq.qza
```
# Importing QIIME 2 data into RStudio
With all the necessary files prepared, we can now import the data into RStudio using the [qiime2R](https://github.com/jbisanz/qiime2R) package. 
Here is the list of required files for this tutorial. We will copy them into a new folder called Phyloseq99.

* `classification.qza`: Classification file generated with VSEARCH.
* `filtered_table.qza`: Filtered DADA2 table excluding unrecognized sequences from the sequence insertion process.
* `insertion-tree.qza`: Phylogenetic tree file generated with SEPP.
* `metadata.txt`: Sample metadata file.

```
mkdir phyloseq99
cp taxonomy99/classification.qza phyloseq99/
cp phylogeny/filtered_table.qza phyloseq99/
cp phylogeny/insertion-tree.qza phyloseq99/
cp metadata.txt  phyloseq99/
```
Once all required packages are installed, you can proceed to import the data into R using the following code:
```
library(qiime2R)
library(phyloseq)

physeq_V2-9<-qza_to_phyloseq(
  features="phyloseq99/filtered_table.qza",
  tree="phyloseq99/insertion-tree.qza", "phyloseq99/classification.qza",
  metadata = "phyloseq99/metadata.txt"
)
```
After importing, we can proceed with preprocessing. Using functions built into Phyloseq, we can filter out unassigned ASVs, for example.
```
taxa <- tax_table(physeq_V2-9)%>%as.data.frame()
taxa_keep<- rownames(taxa%>%subset(Kingdom!="Unassigned"))
physeq_V2-9_fil = prune_taxa(taxa_keep, physeq_V2-9)
```
