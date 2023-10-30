# Protean - Protein annotation pipeline

This is a Snakemake workflow for functional annotation of a protein FASTA using [eggNOG-mapper](https://github.com/eggnogdb/eggnog-mapper/wiki), [dbCAN2](https://bcb.unl.edu/dbCAN2/) and [KOFams](https://www.genome.jp/tools/kofamkoala/). It has been optimized for annotating large collections of proteins (>1 million). For characterizing functional pathways at a genome level there is a separate repo in https://github.com/alexmsalmeida/genofan.

## Installation

1. Install [conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html ) and [snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html)

2. Clone repository
```
git clone https://github.com/alexmsalmeida/protean.git
```

3. Download main database containing eggNOG, CAZy and KOFam annotations
```
wget http://ftp.ebi.ac.uk/pub/databases/metagenomics/genome_sets/protein_dbs.tar.gz
tar -xzvf protein_dbs.tar.gz
```

## How to run

1. Edit the configuration file [`config/config.yml`](config/config.yml).
    - `input_file`: Path to input protein FASTA file (.faa).
    - `output_dir`: Directory to save output results.
    - `db_dir`: Location of the database directory.
    - `nsplits`: Number of parallel splits to analyse (must be lower than the number of proteins in `input_file`)
    - `ncores`: Number of cores to use for the analyses.

2. (option 1) Run the pipeline locally (adjust `-j` based on the number of available cores)
```
snakemake --use-conda -k -j 4
```
2. (option 2) Run the pipeline on a cluster (e.g., SLURM)
```
snakemake --use-conda -k -j 100 --profile config/slurm --latency-wait 120
```

3. View the results in `{output_dir}/summary/`.
