#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: 80tktest.t,v 1.12 2004/04/15 23:24:38 eserte Exp $
# Author: Slaven Rezic
#

use strict;

use GD;
use GD::Convert qw(gif=gif_netpbm);

BEGIN {
    if (!eval q{
	use Test;
        use Tk;
	use Tk::Config;
	die "No DISPLAY" if $win_arch eq 'x' && !$ENV{DISPLAY};
	1;
    }) {
	print "# tests only work with installed Test and Tk modules\n";
	print "1..1\n";
	print "ok 1\n";
	exit;
    }
}

BEGIN { plan tests => 10 }

my $mw0 = MainWindow->new;
my $wait = 0;
$mw0->Button(-text => "OK", -command => sub { $wait = 1 })->pack(-side => "bottom")
    if $ENV{PERL_TEST_INTERACTIVE};

for my $transparency (0 .. 1) {
    my $mw = $mw0->Frame->pack;
    my $im = new GD::Image 200,200;
    my $white = $im->colorAllocate(255,255,255);
    my $black = $im->colorAllocate(0,0,0);
    my $red = $im->colorAllocate(255,0,0);
    my $blue = $im->colorAllocate(0,0,255);
    $im->rectangle(0,0,99,99,$black);
    $im->arc(50,50,95,75,0,360,$blue);
    $im->fill(50,50,$red);
    if ($transparency) {
	$im->transparent($white);
	$im->string(gdMediumBoldFont, 10,100, "transparent background", $blue);
    } else {
	$im->string(gdMediumBoldFont, 10,100, "white background", $blue);
    }
    $im->string(gdMediumBoldFont, 10,110, "black rectangle", $blue);
    $im->string(gdMediumBoldFont, 10,120, "black oval with blue outline", $blue);

    #open(TEST, ">/tmp/80tktest.gd");print TEST $im->gd;close TEST;system("gdtopng /tmp/80tktest.gd /tmp/80tktest.png"); system("display /tmp/80tktest.png &");

    my $ppm = $im->ppm;
    ok(substr($ppm, 0, 2), "P6");
    my $ppm_file = "test.ppm";
    open(PPM, "> $ppm_file") or die "Can't write to $ppm_file: $!";
    binmode PPM;
    print PPM $ppm;
    close PPM;

    my $p = $mw->Photo(-file => $ppm_file);
    unlink $ppm_file;

    my $row = 0;
    my $col = 0;
    $mw->Label(-text => "ppm")->grid(-row=>$row+1,-column=>$col);
    $mw->Label(-image => $p)->grid(-row=>$row,-column=>$col++);

    my $xpm = $im->xpm;
    ok((split /\n/, $xpm)[0] =~ /XPM/, 1);
    my $p2 = $mw->Photo(-data => $xpm);
    $mw->Label(-text => "xpm photo")->grid(-row=>$row+1,-column=>$col);
    $mw->Label(-image => $p2)->grid(-row=>$row,-column=>$col++);

    my $p3 = $mw->Pixmap(-data => $xpm);
    $mw->Label(-text => "xpm pixmap")->grid(-row=>$row+1,-column=>$col);
    $mw->Label(-image => $p3)->grid(-row=>$row,-column=>$col++);

    my $gif = $im->gif_netpbm(-transparencyhack => $transparency);
    if (!defined $gif || $gif eq '') {
	skip(1,1); # probably no netpbm installed
    } else {
	ok($gif =~ /GIF/);
	if (eval 'require MIME::Base64; 1') {
	    my $p4 = $mw->Photo(-data => MIME::Base64::encode_base64($gif));
	    $mw->Label(-text => "gif (netpbm)")->grid(-row=>$row+1,-column=>$col);
	    $mw->Label(-image => $p4)->grid(-row=>$row,-column=>$col++);
	}
    }

    my $gif2 = $im->gif(-transparencyhack => $transparency);
    if (!defined $gif2 || $gif2 eq '') {
	skip(1,1); # probably no netpbm installed
    } else {
	ok($gif, $gif2);
    }

    my $gif3 = $im->gif_imagemagick(-transparencyhack => $transparency);
    if (!defined $gif3 || $gif3 eq '') {
	skip(1,1); # probably no imagemagick installed
    } else {
	ok($gif3 =~ /GIF/);
	if (eval 'require MIME::Base64; 1') {
	    my $p5 = $mw->Photo(-data => MIME::Base64::encode_base64($gif));
	    $mw->Label(-text => "gif (imagemagick)")->grid(-row=>$row+1,-column=>$col);
	    $mw->Label(-image => $p5)->grid(-row=>$row,-column=>$col++);
	}
    }

    $wait = 0;
    if (!$ENV{PERL_TEST_INTERACTIVE}) {
	$mw0->after(1000, sub { $wait = 1 });
    }
    $mw0->waitVariable(\$wait);
    $mw->destroy;
}

__END__
