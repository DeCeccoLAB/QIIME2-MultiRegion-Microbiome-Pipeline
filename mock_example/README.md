# Tutorial: A Complete End-to-End Example


This document provides a step-by-step tutorial for the QIIME2 Multi-Region Pipeline. We will use a small subset of the mock community data from our [publication](https://journals.asm.org/doi/10.1128/spectrum.01673-25) to walk through every command, from raw data import to the final artifacts ready for downstream analysis in R.

First, let's create a dedicated directory for this tutorial.  

```
mkdir mock_example
cd mock_example
```

## Download the data

We will download the example dataset, which includes the FASTQ files, reference databases, and metadata.

```
wget -O mock_data.tar.gz https://github.com/DeCeccoLAB/QIIME2-MultiRegion-Microbiome-Pipeline/raw/refs/heads/main/mock_example/input_data/mock_data.tar.gz?download=

tar -xvzf mock_data.tar.gz
```
### Choose Your Environment
This tutorial requires a working QIIME2 (v2023.7) environment. You have two options:

### A) Use Our Docker Container (Recommended)
If you have Docker installed, you can use our pre-configured container. This guarantees the correct software versions and avoids installation issues.

```
# This command starts the container and maps your current directory (mock_example)
# to the /tmp/mnt directory inside the container.
sudo docker run --rm -it -v "$(pwd)":/tmp/mnt/ --entrypoint bash armalica/qiime2:v1

# Once inside the container, navigate to your data
cd /tmp/mnt/mock_data

# Activate the environment
conda activate qiime2-2023.7
```
### B) Use Your Local QIIME2 Environment
If you have already installed QIIME2 v2023.7 (e.g., via Conda), simply activate it and navigate into the data directory.
```
# Activate your local Conda environment
conda activate qiime2-2023.7

# Navigate into the tutorial data folder
cd ./mock_data/
```

### Exploring the Tutorial Data

The directory you are now in (`mock_data`) contains the following files and folders, which are essential for the pipeline:
```
├── db # Pre-formatted reference databases (Greengenes)
├── fastq # Raw, deconvoluted FASTQ files for 5 mock samples across 6 regions
├── meta.txt # Sample metadata file
└── script.sh  # A helper script to create manifest files
```



## Step 1: Import Raw Data into QIIME2

The first step in any QIIME2 analysis is to import the raw FASTQ data into a QIIME2 artifact (`.qza` file). For this multi-amplicon workflow, it is crucial that reads from different regions are initially imported separately but are linked to a common sample ID in the manifest file.

**Example Manifest for V2 Region:**
Notice how each sample ID is consistently named `SampleID.V2-9`. This ensures that when we merge the data later, QIIME2 understands that `PF91.V2.fastq.gz` and `PF91.V4.fastq.gz` belong to the same sample.

|  sample-id | absolute-filepath |
| ------------- | ------------- |
|sample-id	|absolute-filepath|
|PF91.V2-9	|/path/to/fastq/PF91.V2.FR.fastq.gz|
|PF92.V2-9	|/path/to/fastq/PF92.V2.FR.fastq.gz|
|...|.....|


To simplify this tutorial, we provide a helper script (`script.sh`) that will automatically generate the required subdirectories (`V2`, `V3`, etc.) and the corresponding manifest files.

```
bash script.sh
```
Now, we can proceed with importing the data for each of the six hypervariable regions.

```
### V2 Import
qiime tools import \
--type 'SampleData[SequencesWithQuality]' \
--input-path ./V2/manifest.txt \
--output-path ./V2/single-end-demuxV2.qza \
--input-format SingleEndFastqManifestPhred33V2
### V3 Import
qiime tools import \
--type 'SampleData[SequencesWithQuality]' \
--input-path ./V3/manifest.txt \
--output-path ./V3/single-end-demuxV3.qza \
--input-format SingleEndFastqManifestPhred33V2
### V4 Import
qiime tools import \
--type 'SampleData[SequencesWithQuality]' \
--input-path ./V4/manifest.txt \
--output-path ./V4/single-end-demuxV4.qza \
--input-format SingleEndFastqManifestPhred33V2
### V6-7 import
qiime tools import \
--type 'SampleData[SequencesWithQuality]' \
--input-path ./V67/manifest.txt \
--output-path ./V67/single-end-demuxV67.qza \
--input-format SingleEndFastqManifestPhred33V2
### V8 Import
qiime tools import \
--type 'SampleData[SequencesWithQuality]' \
--input-path ./V8/manifest.txt \
--output-path ./V8/single-end-demuxV8.qza \
--input-format SingleEndFastqManifestPhred33V2
### V9 Import
qiime tools import \
--type 'SampleData[SequencesWithQuality]' \
--input-path ./V9/manifest.txt \
--output-path ./V9/single-end-demuxV9.qza \
--input-format SingleEndFastqManifestPhred33V2
```
**Success!** You will see a confirmation message for each successful import, like this:
`Imported ./V2/manifest.txt as SingleEndFastqManifestPhred33V2 to ./V2/single-end-demuxV2.qza`


## Step 2: Quality Control and Visualization
Before denoising, we must inspect the quality of our sequencing reads. This is the most critical decision-making step, as it determines the parameters for DADA2.
```
### V2 
qiime demux summarize \
--i-data ./V2/single-end-demuxV2.qza \
--o-visualization ./V2/single-end-demuxV2.qzv
### V3 
qiime demux summarize \
--i-data ./V3/single-end-demuxV3.qza \
--o-visualization ./V3/single-end-demuxV3.qzv
### V4 
qiime demux summarize \
--i-data ./V4/single-end-demuxV4.qza \
--o-visualization ./V4/single-end-demuxV4.qzv
### V6-7 
qiime demux summarize \
--i-data ./V67/single-end-demuxV67.qza \
--o-visualization ./V67/single-end-demuxV67.qzv
### V8 
qiime demux summarize \
--i-data ./V8/single-end-demuxV8.qza \
--o-visualization ./V8/single-end-demuxV8.qzv
### V9 
qiime demux summarize \
--i-data ./V9/single-end-demuxV9.qza \
--o-visualization ./V9/single-end-demuxV9.qzv

```

These commands generate QIIME2 visualization files `(.qzv)` for each region. You can view them by dragging and dropping the files onto view.qiime2.org.
Navigate to the "Interactive Quality Plot" tab. The goal is to choose a truncation length `(--p-trunc-len)` where the read quality remains high. A good rule of thumb is to truncate reads where the 25th percentile (the bottom of the box plot) drops below a Phred score of 25.

![plot](https://github.com/DeCeccoLAB/QIIME2-MultiRegion-Microbiome-Pipeline/blob/main/mock_example/input_data/Screenshot%202025-09-09%20095820.jpg)

## Step 3: Denoising with DADA2

Based on our quality inspection, we can now run DADA2 to correct sequencing errors and generate Amplicon Sequence Variants (ASVs). We use `denoise-pyro` because its error model is specifically optimized for Ion Torrent data.

First, let's create output directories for our denoised results.
```
### V2
mkdir ./V2/dada2-0-200
### V3
mkdir ./V3/dada2-0-178
### V4
mkdir ./V4/dada2-0-220
### V6-7
mkdir ./V67/dada2-0-200
### V8
mkdir ./V8/dada2-0-200
### V9
mkdir ./V9/dada2-0-170
```
Now, run the denoising commands with the truncation lengths we selected.

```
### V2
qiime dada2 denoise-pyro \
--i-demultiplexed-seqs ./V2/single-end-demuxV2.qza \
--p-trim-left 0 \
--p-trunc-len 200 \
--p-n-threads 18 \
--o-table ./V2/dada2-0-200/table-dada2-pyroV2.qza \
--o-representative-sequences ./V2/dada2-0-200/rep-seqs-dada2-pyroV2.qza \
--o-denoising-stats ./V2/dada2-0-200/stats-dada2V2.qza
### V3
qiime dada2 denoise-pyro \
--i-demultiplexed-seqs ./V3/single-end-demuxV3.qza \
--p-trim-left 0 \
--p-trunc-len 178 \
--p-n-threads 18 \
--o-table ./V3/dada2-0-178/table-dada2-pyroV3.qza \
--o-representative-sequences ./V3/dada2-0-178/rep-seqs-dada2-pyroV3.qza \
--o-denoising-stats ./V3/dada2-0-178/stats-dada2V3.qza
### V4
qiime dada2 denoise-pyro \
--i-demultiplexed-seqs ./V4/single-end-demuxV4.qza \
--p-trim-left 0 \
--p-trunc-len 220 \
--p-n-threads 18 \
--o-table ./V4/dada2-0-220/table-dada2-pyroV4.qza \
--o-representative-sequences ./V4/dada2-0-220/rep-seqs-dada2-pyroV4.qza \
--o-denoising-stats ./V4/dada2-0-220/stats-dada2V4.qza
### V6-7
qiime dada2 denoise-pyro \
--i-demultiplexed-seqs ./V67/single-end-demuxV67.qza \
--p-trim-left 0 \
--p-trunc-len 200 \
--p-n-threads 18 \
--o-table ./V67/dada2-0-200/table-dada2-pyroV67.qza \
--o-representative-sequences ./V67/dada2-0-200/rep-seqs-dada2-pyroV67.qza \
--o-denoising-stats ./V67/dada2-0-200/stats-dada2V67.qza
### V8
qiime dada2 denoise-pyro \
--i-demultiplexed-seqs ./V8/single-end-demuxV8.qza \
--p-trim-left 0 \
--p-trunc-len 200 \
--p-n-threads 18 \
--o-table ./V8/dada2-0-200/table-dada2-pyroV8.qza \
--o-representative-sequences  ./V8/dada2-0-200/rep-seqs-dada2-pyroV8.qza \
--o-denoising-stats  ./V8/dada2-0-200/stats-dada2V8.qza
### V9
qiime dada2 denoise-pyro \
--i-demultiplexed-seqs ./V9/single-end-demuxV9.qza \
--p-trim-left 0 \
--p-trunc-len 170 \
--p-n-threads 18 \
--o-table ./V9/dada2-0-170/table-dada2-pyroV9.qza \
--o-representative-sequences ./V9/dada2-0-170/rep-seqs-dada2-pyroV9.qza \
--o-denoising-stats ./V9/dada2-0-170/stats-dada2V9.qza
```

### Verify Denoising Success
It's good practice to check how many reads were retained through the denoising process. We are aiming to keep at least 60-80% of our input reads.

```
### V2
qiime metadata tabulate \
  --m-input-file ./V2/dada2-0-200/stats-dada2V2.qza \
  --o-visualization ./V2/dada2-0-200/stats-dada2V2.qzv
### V3
qiime metadata tabulate \
  --m-input-file ./V3/dada2-0-178/stats-dada2V3.qza \
  --o-visualization ./V3/dada2-0-178/stats-dada2V3.qzv
### V4
qiime metadata tabulate \
  --m-input-file ./V4/dada2-0-220/stats-dada2V4.qza \
  --o-visualization ./V4/dada2-0-220/stats-dada2V4.qzv
### V6-7
qiime metadata tabulate \
  --m-input-file ./V67/dada2-0-200/stats-dada2V67.qza \
  --o-visualization ./V67/dada2-0-200/stats-dada2V67.qzv
### V8
qiime metadata tabulate \
  --m-input-file ./V8/dada2-0-200/stats-dada2V8.qza \
  --o-visualization ./V8/dada2-0-200/stats-dada2V8.qzv
### V9
qiime metadata tabulate \
  --m-input-file ./V9/dada2-0-170/stats-dada2V9.qza \
  --o-visualization ./V9/dada2-0-170/stats-dada2V9.qzv

```
You can view these .qzv files to see the percentage of reads remaining after filtering and denoising.

Here is the example of the denoised stats of the V2 fastqs:
![plot](https://github.com/DeCeccoLAB/QIIME2-MultiRegion-Microbiome-Pipeline/blob/main/mock_example/input_data/Screenshot%202025-09-09%20142509.jpg)
> Note: As observed in our original work, the V9 region yielded no sequences after denoising in this mock community, likely due to its specific composition. We will proceed with the empty V9 files to demonstrate the robustness of the merging step.

## Step 4: Merge Regional Data

Now we combine the results from all six regions into a single, comprehensive dataset.
First, let's copy the necessary files into our main working directory for convenience.

```
cp ./V*/dada*/table-dada2-pyro*.qza ./
cp ./V*/dada*/rep-seqs-dada2-pyro*.qza ./
```
Next, merge the ASV tables and representative sequences.
```
 qiime feature-table merge \
--i-tables table-dada2-pyroV{2,3,4,67,8,9}.qza \
--p-overlap-method sum  \
--o-merged-table merged-tableV2-9.qza

qiime feature-table merge-seqs \
--i-data rep-seqs-dada2-pyroV{2,3,4,67,8,9}.qza \
--o-merged-data rep-seqsV2-9.qza
```

> Key Parameter: The `--p-overlap-method sum` option is critical. If the same ASV was detected in multiple regions for a given sample, this command sums their abundances together, providing a total count for that ASV in that sample.

## Step 5: Generate a Phylogenetic Tree

To perform phylogenetic diversity analyses, we need to build a tree containing our ASVs. We use SEPP (SATé-enabled Phylogenetic Placement) to insert our short ASV sequences into a trusted reference phylogeny (Greengenes).

```
mkdir phylogeny

qiime fragment-insertion sepp \
  --i-representative-sequences ./rep-seqsV2-9.qza \
  --i-reference-database ./db/sepp-refs-gg-13-8.qza \
  --o-tree ./phylogeny/insertion-tree.qza \
  --p-threads 30 \
  --o-placements ./phylogeny/insertion-placements.qza
```
The insertion placement will generate 2 files: 

* > Saved Phylogeny[Rooted] to: ./phylogeny/insertion-tree.qza
* > Saved Placements to: ./phylogeny/insertion-placements.qza
  
Not all ASVs can be successfully placed on the tree. We must filter our ASV table and sequences to ensure they perfectly match the tips in our newly generated tree.
```
qiime fragment-insertion filter-features \
  --i-table ./merged-tableV2-9.qza \
  --i-tree ./phylogeny/insertion-tree.qza \
  --o-filtered-table ./phylogeny/filtered_table.qza \
  --o-removed-table ./phylogeny/removed_table.qza

qiime feature-table filter-seqs \
--i-data ./rep-seqsV2-9.qza \
--i-table ./phylogeny/filtered_table.qza \
--o-filtered-data ./phylogeny/filtered-seqs.qza
```
Finally, let's summarize our filtered table to see the final feature counts.
```
qiime feature-table summarize \
  --i-table ./phylogeny/filtered_table.qza \
  --o-visualization ./phylogeny/filtered-table.qzv \
  --m-sample-metadata-file ./meta.txt
```
## Step 6: Assign Taxonomy

The final bioinformatics step is to assign a taxonomic lineage to each of our ASVs. We use a VSEARCH-based consensus classifier with a 'local-to-global' alignment strategy against the Greengenes database.
```
qiime feature-classifier classify-consensus-vsearch \
--i-query ./phylogeny/filtered-seqs.qza \
--i-reference-reads ./db/ref-seqs_gg_13_5_V2-9.qza \
--i-reference-taxonomy ./db/gg_13_5_taxonomy.qza \
--p-perc-identity 0.99 \
--p-threads 10 \
--output-dir ./taxonomy99
```

this step will generate 2 files inside the directory `./taxonomy99`
* > Saved FeatureData[Taxonomy] to: ./taxonomy99/classification.qza
* > Saved FeatureData[BLAST6] to: ./taxonomy99/search_results.qza

## Step 7: Finalize Outputs for R
Congratulations! The QIIME2 portion of the pipeline is complete. We now have a set of artifacts that can be imported into R (e.g., using the `qiime2R` package) to create a phyloseq object for downstream statistical analysis and visualization.
Let's organize the final, essential files into a single directory.

```
mkdir phyloseq
cp taxonomy99/classification.qza phyloseq/
cp phylogeny/filtered_table.qza phyloseq/
cp phylogeny/insertion-tree.qza phyloseq/
cp meta.txt  phyloseq
```
The phyloseq directory now contains everything you need:

```
./phyloseq/
├── classification.qza
├── filtered_table.qza
├── insertion-tree.qza
└── meta.txt
```

* `classification.qza`: The taxonomic lineage for each ASV.
* `filtered_table.qza`: The final ASV abundance table.
* `insertion-tree.qza`:  The rooted phylogenetic tree containing all ASVs.
* `meta.txt`: Your sample metadata file (optional but recommended).
