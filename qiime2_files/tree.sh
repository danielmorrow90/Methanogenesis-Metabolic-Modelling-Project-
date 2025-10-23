#!/bin/bash
#SBATCH --job-name="tree"
#SBATCH --output=tree.out
#SBATCH --error=tree.err
#SBATCH -A p32400
#SBATCH -p normal
#SBATCH -t 12:00:00
#SBATCH -N 1
#SBATCH --mem=10G
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=danielmorrow2025@u.northwestern.edu

module purge all
module load qiime2/2023.2

# make phylogenetic tree
qiime phylogeny align-to-tree-mafft-fasttree \
--i-sequences /home/dem0941/september/rep_seqs_dada2.qza \
--o-alignment /home/dem0941/september/rep_seqs_dada2_aligned.qza \
--o-masked-alignment /home/dem0941/september/rep_seqs_dada2_aligned_masked.qza \
--o-tree /home/dem0941/september/unrooted_tree.qza \
--o-rooted-tree /home/dem0941/september/rooted_tree.qza