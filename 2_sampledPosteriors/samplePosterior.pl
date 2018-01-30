#!/usr/bin/perl -w
use strict;

my @fastaFiles = glob("../1_empiricalMB/*.fasta");
foreach my $fasta (@fastaFiles)
{
    print "$fasta\n";
    if ($fasta =~ m/\.\.\/1_empiricalMB\/(\S+)\.fasta/)
    {
	my $prefix = $1;
	my $paramFile = "../1_empiricalMB/$prefix.run1.p";
        my $treeFile = "../1_empiricalMB/$prefix.run1.t";
	my $nexusFile = "../1_empiricalMB/$prefix.mb.nex";
	my $burnin = 1000;
################
#Retrieve the number of sites for correct sequence simulation
#Burnin is fixed, but this could ideally be taken from the nexus files as well if different datasets have different chain lengths
################
	my $nsites = 0;
	open FH1, '<', "$nexusFile";
	while (<FH1>)
	{
	    if (/.+nchar=(\d+).+/)
	    {
		$nsites = $1;
	    }
	}
	close FH1;
################
#Store the necessary parameters for sequence simulation from the posterior samples to a single hash
################
	my %paramGenerations = ();
	my $n = 0;
	my $nParams = 0;
	open OUT1, '>', "$prefix.sampledParams";
	print OUT1 "NSITES\t$nsites\n";
	print OUT1 "Sample\tPost-Burnin_Generation\tr(A<->C)\tr(A<->G)\tr(A<->T)\tr(C<->G)\tr(C<->T)\tr(G<->T)\tpi(A)\tpi(C)\tpi(G)\tpi(T)\talpha\ttree\n";
	#Gen LnL LnPr TL r(A<->C) r(A<->G) r(A<->T) r(C<->G) r(C<->T) r(G<->T) pi(A) pi(C) pi(G) pi(T) alpha
	#0-6.848992e+032.436639e+012.200000e-011.666667e-011.666667e-011.666667e-011.666667e-011.666667e-011.666667e-012.500000e-012.500000e-012.500000e-012.500000e-011.000000e+00
	print "$paramFile\n";
	open FH1, '<', "$paramFile";
	while (<FH1>)
	{
	    if (/\d+\s+\S+\s+\S+\s+\S+\s+(\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+)/)
	    {
		my $parameterString = $1;
		my @params = split(/\s+/,$parameterString);
#		print "$parameterString\n";
		if ($n >= $burnin)
		{
		    for my $i (0..(scalar(@params)-1))
		    {
			push @{$paramGenerations{$i}}, $params[$i];
#			print "$params[$i]\n";
		    }
		}
		$n++;
		if ($nParams < scalar(@params))
		{
		    $nParams = (scalar(@params)-1);
		}
	    }
	}
	close FH1;
################
#Trees with branch length estimates from the posterior are stored in the .t files
#These are not indexed based on the generation number, but simply by the order they appear in the *.t file, which corresponds with *.p
#Tips have to be changed from the nexus index back to taxa names
################
	open FH1, '<', "$treeFile";
	my $getTaxa = 0;
	my %taxa = ();
	my $nTrees = 0;
	my @trees = ();
	#tree gen.0 = [&U] (((7:2.000000e-02,5:2.000000e-02):2.000000e-02,4:2.000000e-02):2.000000e-02,(2:2.000000e-02,(6:2.000000e-02,3:2.000000e-02):2.000000e-02):2.000000e-02,1:2.000000e-02);
        while (<FH1>)
        {
	    if ($getTaxa == 1)
	    {
		if (/(\d+)\s+(\S+)\,/)
		{
		    my $taxaNum = $1;
		    my $taxaName = $2;
		    $taxa{$taxaNum} = $taxaName;
		}
		elsif (/(\d+)\s+(\S+)\;/)
		{
		    my $taxaNum= $1;
		    my $taxaName = $2;
		    $taxa{$taxaNum} = $taxaName;
		    $getTaxa = 0;
		}
	    }
	    elsif ($getTaxa == 0)
	    {
		if (/translate/)
		{
		    $getTaxa = 1;
		}
		elsif (/tree\s+gen.\d+\s+=\s+\[\&U\]\s+(\S+)/)
		{
		    my $treeString = $1;  
		    if ($nTrees >= $burnin)
		    {
			foreach my $taxon (sort keys %taxa)
			{
			    $treeString =~ s/$taxon:/$taxa{$taxon}:/;
			}
                        push @trees, $treeString;
                    }
		    $nTrees++;
		}
	    }
        }
        close FH1;
################
#Randomly draw 100 trees with branch lengths and substitution model params from the post-burnin posterior for simulation
#Ideally beef up to 1000 samples, but the sample number is just fixed in the outer loop for now
################
	for my $i (0..99)
	{
	    my $rnum = int(rand(scalar(@{$paramGenerations{0}})));
	    print OUT1 "$i\t$rnum";
	    for my $j (0..$nParams)
	    {
		print OUT1 "\t$paramGenerations{$j}[$rnum]";
		splice(@{$paramGenerations{$j}},$rnum,1);
	    }
	    print OUT1 "\t$trees[$rnum]\n";
	    splice(@trees,$rnum,1);
	}
	close OUT1;
    }
}
exit;
