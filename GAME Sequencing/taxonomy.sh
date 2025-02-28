#!/bin/bash
#SBATCH --job-name="taxonomy"
#SBATCH --output=taxonomy.out
#SBATCH --error=taxonomy.err
#SBATCH -A p32400
#SBATCH -p normal
#SBATCH -t 24:00:00
#SBATCH -N 1
#SBATCH --mem=10G
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=danielmorrow2025@u.northwestern.edu

module purge all
module load qiime2/2023.2

# classify sequences from previous step
## keep the classifier filepath the same
qiime feature-classifier classify-sklearn \
--i-classifier /projects/p32400/game/qiime_io/midas_5.1_classifier.qza \
--i-reads /projects/p32400/game/qiime_io/rep_seqs_dada2.qza \
--o-classification /projects/p32400/game/qiime_io/taxonomy.qza

qiime metadata tabulate \
--m-input-file /projects/p32400/game/qiime_io/taxonomy.qza \
--o-visualization /projects/p32400/game/qiime_io/taxonomy.qzv