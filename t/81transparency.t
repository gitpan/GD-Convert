#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: 81transparency.t,v 1.4 2002/02/27 23:04:02 eserte Exp $
# Author: Slaven Rezic
#

use strict;

use GD;
use GD::Convert;

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

BEGIN { plan tests => 4 }

my $images = 4;

my $mw0 = MainWindow->new;
my $mw = $mw0->Frame->pack;
my $c = $mw->Canvas(-width => $images*200, -height => 200,
		    -highlightthickness => 0)->pack;

my $im = new GD::Image 200,200;
my $white = $im->colorAllocate(255,255,255);
my $black = $im->colorAllocate(0,0,0);
my $red = $im->colorAllocate(255,0,0);
my $blue = $im->colorAllocate(0,0,255);
$im->rectangle(0,0,99,99,$black);
$im->arc(50,50,95,75,0,360,$blue);
$im->fill(50,50,$red);
$im->transparent($white);

$c->createLine(0,0,$c->cget(-width),$c->cget(-height),-width=>3,-fill=>"blue");
$c->createLine(0,$c->cget(-height),$c->cget(-width),0,-width=>3,-fill=>"blue");

my $gif = $im->gif_netpbm(-transparencyhack => 1);
if ($gif eq '') {
    skip(1,1); # probably no netpbm installed
} else {
    ok($gif =~ /GIF/, 1);
    if (eval 'require MIME::Base64; 1') {
	my $p4 = $mw->Photo(-data => MIME::Base64::encode_base64($gif));
	$c->createImage(0,0,-anchor=>"nw", -image => $p4);
    }
}

my $gif2 = $im->gif_imagemagick(-transparencyhack => 1);
if (!defined $gif2 || $gif2 eq '') {
    skip(1,1); # probably no imagemagick installed
} else {
    ok($gif2 =~ /GIF/, 1);
    if (eval 'require MIME::Base64; 1') {
	my $p5 = $mw->Photo(-data => MIME::Base64::encode_base64($gif2));
	$c->createImage(200,0,-anchor=>"nw", -image => $p5);
    }
}

my $xpm = $im->xpm;
ok($xpm =~ /XPM/, 1);
my $p6 = $mw->Photo(-data => $xpm);
$c->createImage(400,0,-anchor=>"nw", -image => $p6);

my $gif3 = $im->gif_imagemagick;
if (!defined $gif3 || $gif3 eq '') {
    skip(1,1); # probably no imagemagick installed
} else {
    ok($gif =~ /GIF/, 1);
    if (eval 'require MIME::Base64; 1') {
	my $p7 = $mw->Photo(-data => MIME::Base64::encode_base64($gif));
	$c->createImage(600,0,-anchor=>"nw", -image => $p7);
    }
}

$mw0->Button(-text => "OK", -command => sub { $mw0->destroy })->pack;

if ($ENV{BATCH}) { $mw0->after(1000, sub { $mw0->destroy }) }

MainLoop;

__END__
