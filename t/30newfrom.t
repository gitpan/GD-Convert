#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: 30newfrom.t,v 1.3 2003/05/29 22:17:34 eserte Exp $
# Author: Slaven Rezic
#

use strict;
use FindBin;

use GD;
use GD::Convert qw(gif=any newFromGif=any newFromGifData=any);

$GD::Convert::DEBUG = 0;

BEGIN {
    if (!eval q{
	use Test;
	1;
    }) {
	print "1..0 # skip: no Test module\n";
	exit;
    }
}

BEGIN { plan tests => 8 }

my $gd = GD::Image->new(100,100);
my $black = $gd->colorAllocate(0,0,0);
my $red   = $gd->colorAllocate(255,0,0);
$gd->line(0,0,100,100,$red);

######################################################################
# PPM tests

my $ppm_data = $gd->ppm;

{
    my $gd2 = GD::Image->newFromPpmData($ppm_data);
    ok(!($gd->compare($gd2) & &GD::GD_CMP_IMAGE));
}

my $ppm_file = "$FindBin::RealBin/test.ppm";
open(OUT, ">$ppm_file") or die "Can't write $ppm_file: $!";
binmode OUT;
print OUT $ppm_data;
close OUT;

{
    my $gd2 = GD::Image->newFromPpm($ppm_file);
    ok(!($gd->compare($gd2) & &GD::GD_CMP_IMAGE));
}

{
    open(IN, $ppm_file) or die "Can't read $ppm_file: $!";
    binmode IN;
    my $gd2 = GD::Image->newFromPpm(\*IN);
    close IN;
    ok(!($gd->compare($gd2) & &GD::GD_CMP_IMAGE));
}

{
    require IO::File;
    my $fh = IO::File->new;
    $fh->open("< $ppm_file") or die "Can't read $ppm_file: $!";
    # $fh->binmode; XXX?
    my $gd2 = GD::Image->newFromPpm($fh);
    $fh->close;
    ok(!($gd->compare($gd2) & &GD::GD_CMP_IMAGE));
}

unlink $ppm_file;

######################################################################
# GIF tests

my $gif_data = $gd->gif;

my $gd3 = GD::Image->newFromGifData($gif_data);
ok(!($gd->compare($gd3) & &GD::GD_CMP_IMAGE));

my $gif_file = "$FindBin::RealBin/test.gif";
open(OUT, ">$gif_file") or die "Can't write $gif_file: $!";
binmode OUT;
print OUT $gif_data;
close OUT;

{
    my $gd2 = GD::Image->newFromGif($gif_file);
    ok(!($gd->compare($gd2) & &GD::GD_CMP_IMAGE));
}

{
    open(IN, $gif_file) or die "Can't read $gif_file: $!";
    binmode IN;
    my $gd2 = GD::Image->newFromGif(\*IN);
    close IN;
    ok(!($gd->compare($gd2) & &GD::GD_CMP_IMAGE));
}

{
    require IO::File;
    my $fh = IO::File->new;
    $fh->open("< $gif_file") or die "Can't read $gif_file: $!";
    # $fh->binmode; XXX?
    my $gd2 = GD::Image->newFromGif($fh);
    $fh->close;
    ok(!($gd->compare($gd2) & &GD::GD_CMP_IMAGE));
}

unlink $gif_file;

__END__
