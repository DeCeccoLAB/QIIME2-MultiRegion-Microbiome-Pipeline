# Pipeline Example

In this page we will going throuh an example of pipeline using the data available from our study avilable [here](https://journals.asm.org/doi/10.1128/spectrum.01673-25) 

## Download the data

```
wget -O mock_data.tar.gz https://github.com/DeCeccoLAB/QIIME2-MultiRegion-Microbiome-Pipeline/raw/refs/heads/main/mock_example/input_data/mock_data.tar.gz?download=

tar -xvzf mock_data.tar.gz

cd mock_data

```


```
├── db
│   ├── gg_13_5_taxonomy.qza
│   ├── ref-seqs_gg_13_5_V2-9.qza
│   └── sepp-refs-gg-13-8.qza
├── fastq
│   ├── all the fastq files
.  
.
.
├── V2
│   └── single-end-demuxV2.qza
├── V3
│   └── single-end-demuxV3.qza
├── V4
│   └── single-end-demuxV4.qza
├── V67
│   └── single-end-demuxV67.qza
├── V8
│   └── single-end-demuxV8.qza
└── V9
    └── single-end-demuxV9.qza
```
## Data Import
Here we show how to import the different fastqs for each region, as previosly describe a manifest file should be prepared and once the manifest file for each region is ready you can import the data as follows.
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


## QC
Now before proceeding we should inspect the imported sequences to estimate the legth that we want to keep during the demoising step, as stated in the original workflow this can be done using 
the `demux summarize` command

```
qiime demux summarize \
--i-data single-end-demux.qza \
--o-visualization single-end-demux.qzv
```
This command will generate a `.qzv` that can be inspected into [QIIME View](https://view.qiime2.org/)
Moving to the tab of the interactive plot, we will chose the length by wich the reads quality at the 25
![plot](https://github.com/DeCeccoLAB/QIIME2-MultiRegion-Microbiome-Pipeline/blob/main/mock_example/input_data/Screenshot%202025-09-09%20095820.jpg?raw=true)
