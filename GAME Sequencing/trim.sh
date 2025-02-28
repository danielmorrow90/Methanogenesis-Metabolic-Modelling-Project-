#!/bin/bash
#SBATCH --job-name="trim"
#SBATCH --output=trim.out
#SBATCH --error=trim.err
#SBATCH -A p32400
#SBATCH -p normal
#SBATCH -t 00:30:00
#SBATCH -N 1
#SBATCH --mem=5G
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=danielmorrow2025@u.northwestern.edu

module purge all
module load qiime2/2023.2

# trim primers
qiime cutadapt trim-paired \
--i-demultiplexed-sequences /projects/p32400/game/qiime_io/reads.qza \
--o-trimmed-sequences /projects/p32400/game/qiime_io/reads_trimmed.qza \
--p-front-f GTGYCAGCMGCCGCGGTAA \
--p-front-r CCGYCAATTYMTTTRAGTTT

# make .qzv file
qiime demux summarize \
--i-data /projects/p32400/game/qiime_io/reads_trimmed.qza  \
--o-visualization /projects/p32400/game/qiime_io/readquality_trimmed.qzv