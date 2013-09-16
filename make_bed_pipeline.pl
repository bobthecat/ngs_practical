#! /usr/bin/perl -w

# Extends from start coordinate to 200bp

# Coordinates in BED from sam2bed are given with respect to forward strand (start to end = sequence length)

use strict;

if ($#ARGV != 1){print "\nPlease give input and output file names.\n"; exit;}

open IN, "$ARGV[0]" || die "Can't open $ARGV[0]";
open OUT, ">$ARGV[1]" || die "Can't open $ARGV[1]";

my $length = 200;

while(<IN>)
{
chomp $_;
my ($chr, $start, $end, $ID, $score, $strand, @rest) = split /\t/;
my ($new_end, $new_start) = ("","");
chomp ($chr, $start, $end, $ID, $score, $strand);

	if ($strand eq "+")
	{
	$new_start = $start;
	$new_end = $start + $length;
	}
	else
	{
	$new_end = $end;
	$new_start = $end - $length;
	}

	#Correct coordinates extended past coordinate 0!
	if ($new_start =~ /^\-/)
	{
	$new_start = 1;
	$new_end = $length;
	}

my $rest1 = join("\t", @rest);	

print OUT "$chr\t$new_start\t$new_end\t$ID\t$score\t$strand\t$rest1\n";
				
}#close while		


close IN;
close OUT;
