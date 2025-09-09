# Pipeline Example

In this page we will going throuh an example of pipeline using the data available from our study avilable [here](https://journals.asm.org/doi/10.1128/spectrum.01673-25) 

## Download the data

```
wget -O mock_data.tar.gz https://github.com/DeCeccoLAB/QIIME2-MultiRegion-Microbiome-Pipeline/raw/refs/heads/main/mock_example/input_data/mock_data.tar.gz?download=

tar -xvzf mock_data.tar.gz

cd mock_data

```
Now that you downloaded the file from this repository the content will appear like this 

2 folders named `db` and `fastq` that contains the reference databases used in our original paper and the raw data that we will use for this tutorial
2 files `meta` that contains the metadata and `script.sh` this script will generate a folder for each region an their respective manifest files.

```
├── db
│   ├── gg_13_5_taxonomy.qza
│   ├── ref-seqs_gg_13_5_V2-9.qza
│   └── sepp-refs-gg-13-8.qza
├── fastq
│   ├── PA60.V2.FR.fastq.gz
│   ├── PA60.V3.FR.fastq.gz
│   ├── PA60.V4.FR.fastq.gz
│   ├── PA60.V67.FR.fastq.gz
│   ├── PA60.V8.FR.fastq.gz
│   ├── PA60.V9.FR.fastq.gz
│   ├── PF91.V2.FR.fastq.gz
│   ├── PF91.V3.FR.fastq.gz
│   ├── PF91.V4.FR.fastq.gz
│   ├── PF91.V67.FR.fastq.gz
│   ├── PF91.V8.FR.fastq.gz
│   ├── PF91.V9.FR.fastq.gz
│   ├── PF92.V2.FR.fastq.gz
│   ├── PF92.V3.FR.fastq.gz
│   ├── PF92.V4.FR.fastq.gz
│   ├── PF92.V67.FR.fastq.gz
│   ├── PF92.V8.FR.fastq.gz
│   ├── PF92.V9.FR.fastq.gz
│   ├── PF93.V2.FR.fastq.gz
│   ├── PF93.V3.FR.fastq.gz
│   ├── PF93.V4.FR.fastq.gz
│   ├── PF93.V67.FR.fastq.gz
│   ├── PF93.V8.FR.fastq.gz
│   ├── PF93.V9.FR.fastq.gz
│   ├── PF94.V2.FR.fastq.gz
│   ├── PF94.V3.FR.fastq.gz
│   ├── PF94.V4.FR.fastq.gz
│   ├── PF94.V67.FR.fastq.gz
│   ├── PF94.V8.FR.fastq.gz
│   └── PF94.V9.FR.fastq.gz
├── meta.txt
└── script.sh
```



## step 1: Data Import
Here we show how to import the different fastqs for each region, as previosly described a manifest file should be prepared and once the manifest file for each region is ready you can import the data as follows.
Since the manifest requires absolute file path we provide the data already imported, however the manifest is crucial for the multi-amplicon pipeline since 6 fastq of different region will be merged later to the same sample_id, here is an example for the V2 region import

|  sample-id | absolute-filepath |
| ------------- | ------------- |
|sample-id	|absolute-filepath|
|PF91.V2-9	|/path/to/fastq/PF91.V2.FR.fastq.gz|
|PF92.V2-9	|/path/to/fastq/PF92.V2.FR.fastq.gz|
|PF93.V2-9	|/path/to/fastq/PF93.V2.FR.fastq.gz|
|PF94.V2-9	|/path/to/fastq/PF94.V2.FR.fastq.gz|
|PA60.V2-9	|/path/to/fastq/PA60.V2.FR.fastq.gz|

create the manifest and put a manifest file in each folder, navigate and import the data for each region

```
bash script.sh
```
this command will create 6 folders and generate the manifest files for this example

now we can proceed with the import, first ensure you have activated the QIIME2 environment 
```
conda activate qiime2-2023.7
```
Now in the same directory we can proceed with the import:
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
This chuck of code will wimport sequentially all the fastqs into their respective directories, and you will get these messages if the import runs succefully

* >Imported ./V2/manifest.txt as SingleEndFastqManifestPhred33V2 to ./V2/single-end-demuxV2.qza
* >Imported ./V3/manifest.txt as SingleEndFastqManifestPhred33V2 to ./V3/single-end-demuxV3.qza
* >Imported ./V4/manifest.txt as SingleEndFastqManifestPhred33V2 to ./V4/single-end-demuxV4.qza
* >Imported ./V67/manifest.txt as SingleEndFastqManifestPhred33V2 to ./V67/single-end-demuxV67.qza
* >Imported ./V8/manifest.txt as SingleEndFastqManifestPhred33V2 to ./V8/single-end-demuxV8.qza
* >Imported ./V9/manifest.txt as SingleEndFastqManifestPhred33V2 to ./V9/single-end-demuxV9.qza


## Step2: QC
Now before proceeding we should inspect the imported sequences to estimate the legth that we want to keep during the demoising step, as stated in the original workflow this can be done using 
the `demux summarize` command

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
This command will generate a `.qzv` that can be inspected into [QIIME View](https://view.qiime2.org/)
Moving to the tab of the interactive plot, we will chose the length by wich the reads quality at the 25th percentile is equal or above 25 in the V2 example is 27
![plot](https://github.com/DeCeccoLAB/QIIME2-MultiRegion-Microbiome-Pipeline/blob/main/mock_example/input_data/Screenshot%202025-09-09%20095820.jpg?raw=true)

## Step3: Denoising 

After the visualt inspection of all the `.qzv` we will parse to dada2 the lenght that we want, we suggest to create a directory for each run of dada2 since later we will inspect the denoised stats to check if the leght chosen kept al least 60-80% of our original sequences

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
--p-trunc-len 200 \
--p-n-threads 18 \
--o-table ./V9/dada2-0-170/table-dada2-pyroV9.qza \
--o-representative-sequences ./V9/dada2-0-170/rep-seqs-dada2-pyroV9.qza \
--o-denoising-stats ./V9/dada2-0-170/stats-dada2V9.qza
```
A the end of the denoising process we will obtain 3 files in each V-directory
```
Saved FeatureTable[Frequency] to: ./V2/dada2-0-200/table-dada2-pyroV2.qza
Saved FeatureData[Sequence] to: ./V2/dada2-0-200/rep-seqs-dada2-pyroV2.qza
Saved SampleData[DADA2Stats] to: ./V2/dada2-0-200/stats-dada2V2.qza
.
.
.
```
### Denoising-QC
To check if our denosing did a good job in keeping most of our reads we need to inspect the denoising stats

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
The metadata tabulate will generate a .qzv file containing the donoising stats to be inspected with QIIME view.
Here is the example of the denoised stats of the V2 fastqs:
![plot](https://github.com/DeCeccoLAB/QIIME2-MultiRegion-Microbiome-Pipeline/blob/main/mock_example/input_data/Screenshot%202025-09-09%20142509.jpg?raw=true)
> Note: As observed in our original work, the V9 region did not gave any sequence after the denoising, probabily due to the mock composition or the low sequencing depth, but we will keep the file as is and continue with the example

## Step4: Data merging

```
cp ./V*/dada*/table-dada2-pyro*.qza ./
cp ./V*/dada*/rep-seqs-dada2-pyro*.qza ./
```
```
 qiime feature-table merge \
--i-tables table-dada2-pyroV{2,3,4,67,8,9}.qza \
--p-overlap-method sum  \
--o-merged-table merged-tableV2-9.qza

qiime feature-table merge-seqs \
--i-data rep-seqs-dada2-pyroV{2,3,4,67,8,9}.qza \
--o-merged-data rep-seqsV2-9.qza
```

the code will automatically merge all the sequences and tables to generate a unique table, since this workflow is used to generate a multi-aplicon profile we need to provide an option to tell QIIME to merge different tables coming from the same sample using the option `--p-overlap-method sum `

* >Saved FeatureTable[Frequency] to: merged-tableV2-9.qza
* >Saved FeatureData[Sequence] to: rep-seqsV2-9.qza

## Step5: Tree generation

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

Now we need to filter out the sequences that were not inserted into the rooted tree
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
This command will output three files:
* > Saved FeatureTable[Frequency] to: ./phylogeny/filtered_table.qza
* >Saved FeatureTable[Frequency] to: ./phylogeny/removed_table.qza
* >Saved FeatureData[Sequence] to: ./phylogeny/filtered-seqs.qza

Now we can inspect the filtered table by running `feature-table summarize`
```
qiime feature-table summarize \
  --i-table ./phylogeny/filtered_table.qza \
  --o-visualization ./phylogeny/filtered-table.qzv \
  --m-sample-metadata-file ./meta.txt
```
## Step5: Taxonomy classification

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

## Step6: Outputs and R-import
Now that we completed the taxonomy classification we can regroup the important files to be imported into R for downstream analyses:

```
mkdir phyloseq
cp taxonomy99/classification.qza phyloseq/
cp phylogeny/filtered_table.qza phyloseq/
cp phylogeny/insertion-tree.qza phyloseq/
cp meta.txt  phyloseq
```

At the end we will obtain these files:

./phyloseq/
├── classification.qza
├── filtered_table.qza
├── insertion-tree.qza
└── meta.txt

* `classification.qza` The taxonomy classification obatined using `VSEARCH` using local-to-global alignment mode
* `filtered_table.qza` The ASV table containing all the ASV that were succefully inserted into the rooted tree
* `insertion-tree.qza` The inserted tree obtained using `SEPP`
* `meta.txt` (Optional) The metadata file that can be imported along with the other files
