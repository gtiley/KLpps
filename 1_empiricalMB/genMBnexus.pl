#!/usr/bin/perl -w
use strict;

my $pathToMRBAYES = "./";
my $youremail = "";

my @fastaFiles = glob("*.fasta");
foreach my $fasta (@fastaFiles)
{
    if ($fasta =~ m/(\S+)\.fasta/)
    {
	my $prefix = $1;
	my %seqs = ();
	my $tax = "";
	my $seq = "";
	my $ntax = 0;
	my $seqLength = 0;
	open FH1, '<', "$fasta";
	while (<FH1>)
	{
	    if (/^>(\S+)/)
	    {
		$tax = $1;
		$ntax++;
		$seq = "";
	    }
	    elsif (/(\S+)/)
	    {
		my $chunk = $1;
		$seq = $seq . $chunk;
		$seqs{$tax} = $seq;
		if ($seqLength < length($seq))
		{
		    $seqLength = length($seq);
		}
	    }
	}
	close FH1;
	open OUT1, '>', "$prefix.mb.nex";
	print OUT1 "#NEXUS\nbegin data;\ndimensions ntax=$ntax nchar=$seqLength;\nformat datatype=dna interleave=no gap=- missing=N;\nmatrix\n";
	foreach my $taxon (sort keys %seqs)
	{
	    print OUT1 "$taxon  $seqs{$taxon}\n";
	}
	print OUT1 ";\n";
	print OUT1 "lset nst=6 rates=gamma ngammacat=4;\n";
	print OUT1 "prset brlenspr=unconstrained:GammaDir(1.0,0.01,1.0,1.0) shapepr=exp(1.0) statefreqpr=dirichlet(1.0,1.0,1.0,1.0) revmatpr=Dirichlet(1.0,1.0,1.0,1.0,1.0,1.0) topologypr=uniform;\n";
	print OUT1 "mcmcp nruns=4 nchains=4 ngen=11111112 samplefreq=1000 burninfrac=.1 printfreq=100 savebrlens=YES starttree=random mcmcdiagn=YES diagnfreq=10000;\n";
	print OUT1 "mcmc file=$prefix;\n";
	print OUT1 "sumt relburnin=YES burninfrac=0.1;\n";
	print OUT1 "sump relburnin=YES burninfrac=0.1;\n";
	print OUT1 "end;";	
	close OUT1;
	open OUT2, '>', "$prefix.mb.sh";
	print OUT2 "\#!/bin/bash\n\#SBATCH --mail-user=$youremail\n\#SBATCH --mail-type=FAIL\n\#SBATCH --time=300:00:00\n\#SBATCH --mem-per-cpu=1000M\n\#SBATCH --nodes=1\n\#SBATCH --ntasks=1\n\#SBATCH --cpus-per-task=16\n";
	print OUT2 "[[ -d \$SLURM_SUBMIT_DIR ]] && cd \$SLURM_SUBMIT_DIR\n";
	print OUT2 "$pathToMRBAYES $prefix.mb.nex\n";
    }
}
exit;
