#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: 80tktest.t,v 1.5 2001/11/28 23:02:15 eserte Exp $
# Author: Slaven Rezic
#

use strict;

use GD;
use GD::Convert qw(gif=gif_netpbm);

BEGIN {
    if (!eval q{
	use Test;
        use Tk;
	1;
    }) {
	print "# tests only work with installed Test and Tk modules\n";
	print "1..1\n";
	print "ok 1\n";
	exit;
    }
}

BEGIN { plan tests => 5 }

my $mw = MainWindow->new;

my $im = new GD::Image 200,200;
my $white = $im->colorAllocate(255,255,255);
my $black = $im->colorAllocate(0,0,0);
my $red = $im->colorAllocate(255,0,0);
my $blue = $im->colorAllocate(0,0,255);
$im->rectangle(0,0,99,99,$black);
$im->arc(50,50,95,75,0,360,$blue);
$im->fill(50,50,$red);

my $ppm = $im->ppm;
ok(substr($ppm, 0, 2), "P6");
my $ppm_file = "test.ppm";
open(PPM, "> $ppm_file") or die "Can't write to $ppm_file: $!";
binmode PPM;
print PPM $ppm;
close PPM;

my $p = $mw->Photo(-file => $ppm_file);
unlink $ppm_file;

$mw->Label(-image => $p)->pack(-side => "left");

my $xpm = $im->xpm;
ok((split /\n/, $xpm)[0] =~ /XPM/, 1);
my $p2 = $mw->Photo(-data => $xpm);
$mw->Label(-image => $p2)->pack(-side => "left");

my $p3 = $mw->Pixmap(-data => $xpm);
$mw->Label(-image => $p3)->pack(-side => "left");

my $gif = $im->gif_netpbm;
ok($gif =~ /GIF/, 1);
if (eval 'require MIME::Base64; 1') {
    my $p4 = $mw->Photo(-data => MIME::Base64::encode_base64($gif));
    $mw->Label(-image => $p4)->pack(-side => "left");
}

my $gif2 = $im->gif;
ok($gif, $gif2);

my $gif3 = $im->gif_imagemagick;
ok($gif3 =~ /GIF/, 1);
if (eval 'require MIME::Base64; 1') {
    my $p5 = $mw->Photo(-data => MIME::Base64::encode_base64($gif));
    $mw->Label(-image => $p5)->pack(-side => "left");
}

if ($ENV{BATCH}) { $mw->after(1000, sub { $mw->destroy }) }

MainLoop;

__END__
