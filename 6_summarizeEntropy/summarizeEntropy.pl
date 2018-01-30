#!/usr/bin/perl -w
use strict;

open OUT1,'>', "pValuesForEntropy.txt";
my @entropyFiles = glob("../5_computeEntropyGalax/*.txt");
foreach my $ef (@entropyFiles)
{
    if ($ef =~ m/\.\.\/5_computeEntropyGalax\/(\S+)\.txt/)
    {
	my $prefix = $1;
	my $entropy = 0;
	my $switch = 0;
	my @entropyDistribution = ();
	print "$prefix\n";
	open FH1, '<', "$ef";
	while (<FH1>)
	{
#treefile       unique     coverage            H           H*            I         Ipct            D         Dpct
	    if ($switch == 0)
	    {
		if (/treefile\s+unique\s+coverage\s+H\s+H\*\s+I\s+Ipct\s+D\s+Dpct/)
		{
		    $switch = 1;
		}
	    }
	    elsif ($switch == 1)
	    {
		if (/(\S+)\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)\s+\S+\s+\S+/)
		{
		    my $tf = $1;
		    my $pp = $2;
		    if ($tf =~ m/\.\.\/1_empiricalMB\/\S+/)
		    {
			$entropy = $pp;
		    }
		    elsif ($tf =~ m/\.\.\/4_runMB\/\S+/)
		    {   
                        push @entropyDistribution, $pp;
		    }
		    elsif ($tf =~ m/average/)
		    {
			$switch = 0;
		    }
		}
	    }
	}
	close FH1;
	print OUT1 "$prefix";
	my $higher = 0;
	my $lower = 0;
	my $total = 0;
	foreach my $ent (sort {$a <=> $b} @entropyDistribution)
	{
	    if ($ent <= $entropy)
            {
                $lower++;
            }
            if ($ent >= $entropy)
            {
                $higher++;
            }
            $total++;
            print OUT1 "\t$ent";
        }
	my $plower = $lower/$total;
	my $phigher = $higher/$total;
	my $ptwo = 0;
	if ($plower < $phigher)
	{
            $ptwo = $plower * 2;
	}
	elsif ($plower >= $phigher)
        {
            $ptwo = $phigher * 2;
	}
	print OUT1 "\t$entropy\t$plower\t$phigher\t$ptwo\n";
    }
}
close OUT1;
exit;
