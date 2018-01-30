#!/usr/bin/perl -w
use strict;
################
#This script calls seqgen for sequence simulation
#Provide the path here - seqgen runs very quickly so this just uses a system call
my $pathToSeqGen = "./";
################

my @posteriorParamFiles = glob("../2_sampledPosteriors/*.sampledParams");
foreach my $posteriorFile (@posteriorParamFiles)
{
    if ($posteriorFile =~ m/\.\.\/2_sampledPosteriors\/(\S+)\.sampledParams/)
    {
	my $prefix = $1;
	my $nsites = 0;
	my @params = ();
	open FH1, '<', "$posteriorFile";
	while (<FH1>)
	{
	    if (/NSITES\s+(\d+)/)
	    {
		$nsites = $1;
	    }
	    elsif (/(\d+.+;)/)
	    {
		my $paramString = $1;
		@params = split(/\s+/,$paramString);
		open OUT1, '>', "$prefix.$params[0].tre";
		print OUT1 "$params[13]";
		close OUT1;
		system "$pathToSeqGen/seq-gen -l$nsites -n1 -mGTR -a$params[12] -r$params[2],$params[3],$params[4],$params[5],$params[6],$params[7] -f$params[8],$params[9],$params[10],$params[11] -of $prefix.$params[0].tre -q > $prefix.$params[0].fasta";
	    }
	}
    }
}
exit;
