#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: 30newfrom.t,v 1.2 2003/05/29 21:51:11 eserte Exp $
# Author: Slaven Rezic
#

use strict;

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

BEGIN { plan tests => 2 }

my $gd = GD::Image->new(100,100);
my $black = $gd->colorAllocate(0,0,0);
my $red   = $gd->colorAllocate(255,0,0);
$gd->line(0,0,100,100,$red);

my $ppm_data = $gd->ppm;

my $gd2 = GD::Image->newFromPpmData($ppm_data);
ok(!($gd->compare($gd2) & &GD::GD_CMP_IMAGE));

my $gif_data = $gd->gif;

my $gd3 = GD::Image->newFromGifData($gif_data);
ok(!($gd->compare($gd3) & &GD::GD_CMP_IMAGE));

__END__
