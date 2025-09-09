# Pipeline Example

In this page we will going throuh an example of pipeline using the data available from our study avilable [here](https://journals.asm.org/doi/10.1128/spectrum.01673-25) 

## Download the data

```
wget -O mock_data.tar.gz https://github.com/DeCeccoLAB/QIIME2-MultiRegion-Microbiome-Pipeline/raw/refs/heads/main/mock_example/input_data/mock_data.tar.gz?download=

tar -xvzf mock_data.tar.gz
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
│   ├── metaV2.txt
│   └── single-end-demux.qza
├── V3
│   ├── metaV3.txt
│   └── single-end-demux.qza
├── V4
│   ├── metaV4.txt
│   └── single-end-demux.qza
├── V67
│   ├── metaV67.txt
│   └── single-end-demux.qza
├── V8
│   ├── metaV4.txt
│   └── single-end-demux.qza
└── V9
    ├── metaV9.txt
    └── single-end-demux.qza
```
## Data Import

## QC

![plot](https://github.com/DeCeccoLAB/QIIME2-MultiRegion-Microbiome-Pipeline/blob/main/mock_example/input_data/Screenshot%202025-09-09%20095820.jpg?raw=true)
