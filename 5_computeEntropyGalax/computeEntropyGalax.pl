#!/usr/bin/perl -w
use strict;

my $pathToGalax = "./";
my $pathToBoost = "./";
my $youremail = "./";

my @empPosProbFiles = glob("../1_empiricalMB/*.run1.t");
foreach my $eppf (@empPosProbFiles)
{
    if ($eppf =~ m/\.\.\/1_empiricalMB\/(\S+)\.run1\.t/)
    {
	my $prefix = $1;
	open OUT1 ,'>', "$prefix.treeList";
	print OUT1 "$eppf\n";
	my @simPosProbFiles = glob("\.\.\/4_runMB\/$prefix\.*.run1\.t");
	foreach my $sppf (@simPosProbFiles)
        {
	    print OUT1 "$sppf\n";
	}
	close OUT1;
	open OUT2, '>', "$prefix.galax.sh";
        print OUT2 "\#!/bin/bash\n\#SBATCH --mail-user=$youremail\n\#SBATCH --mail-type=FAIL\n\#SBATCH --time=72:00:00\n\#SBATCH --mem-per-cpu=1000M\n\#SBATCH --nodes=1\n\#SBATCH --ntasks=1\n\#SBATCH --cpus-per-task=1\n";
        print OUT2 "[[ -d \$SLURM_SUBMIT_DIR ]] && cd \$SLURM_SUBMIT_DIR\n";
        print OUT2 "export BOOST_ROOT=\"$pathToBoost\"\n";
	print OUT2 "export LD_LIBRARY_PATH=\"\$BOOST_ROOT/stage/lib\"\n";
	print OUT2 "$pathToGalax --listfile $prefix.treeList --skip 1113 --outgroup 1 --outfile $prefix\n";
	close OUT2;
    }
}
exit;
