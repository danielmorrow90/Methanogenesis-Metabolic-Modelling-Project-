#!/bin/bash
#SBATCH --job-name="denoise"
#SBATCH --output=denoise.out
#SBATCH --error=denoise.err
#SBATCH -A p32400
#SBATCH -p normal
#SBATCH -t 12:00:00
#SBATCH -N 1
#SBATCH --mem=10G
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=danielmorrow2025@u.northwestern.edu

module purge all
module load qiime2/2023.2


# run dada2 to identify ASVs
qiime dada2 denoise-paired --verbose \
--p-trunc-len-f 220--p-trunc-len-r 175 \
--i-demultiplexed-seqs /projects/p32400/game/qiime_io/reads_trimmed.qza \
--o-representative-sequences /projects/p32400/game/qiime_io/rep_seqs_dada2.qza \
--o-table /projects/p32400/game/qiime_io/table_dada2.qza \
--o-denoising-stats /projects/p32400/game/qiime_io/stats_dada2.qza

## p trunc len f and r should be determined based on your data quality

# make visualization files
qiime metadata tabulate \
--m-input-file /projects/p32400/game/qiime_io/stats_dada2.qza \
--o-visualization /projects/p32400/game/qiime_io/stats_dada2.qzv

qiime feature-table tabulate-seqs \
--i-data /projects/p32400/game/qiime_io/rep_seqs_dada2.qza \
--o-visualization /projects/p32400/game/qiime_io/rep_seqs_dada2.qzv