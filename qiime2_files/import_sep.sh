#!/bin/bash
#SBATCH --job-name="import"
#SBATCH --output=import.out
#SBATCH --error=import.err
#SBATCH -A p32400
#SBATCH -p normal
#SBATCH -t 00:30:00
#SBATCH -N 1
#SBATCH --mem=1G
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=danielmorrow2025@u.northwestern.edu

# activate QIIME2 
module purge all
module load qiime2/2023.2

# import reads into qiime-comatible format
qiime tools import \
--input-path /home/dem0941/september/microbiome.txt \
--output-path /home/dem0941/september/reads.qza \
--input-format PairedEndFastqManifestPhred33V2 \
--type SampleData[PairedEndSequencesWithQuality]

qiime demux summarize \
--i-data /home/dem0941/september/reads.qza \
--o-visualization /home/dem0941/september/readquality_raw.gzv

## using a space and backslash allows you to insert a linebreak without disrupting the function
## you can also have the command written as one line but this is harder to read