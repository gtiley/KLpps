# KLpps
Posterior predictive simulation for genes trees with KL divergence as a summary statistic

There are 6 folders with a Perl script
To go from alignments in fasta format to p-values to evaluate model adequacy, just dump your fastas in 1_empiricalMB, then run the Perl script in each folder in the order as numbered

This assumes you have the following software compiled
Mr Bayes, Seq-Gen, Galax
- Galax depends on the boost library

You will want to supply the correct path to these programs/libraries by editing the scripts accordingly
Additionally, this pipline is designed to run on a cluster with a SLURM scheduler. You'll want to modify the directives to suit your needs too, or feel free to contact me.
