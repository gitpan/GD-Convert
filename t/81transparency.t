#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: 81transparency.t,v 1.9 2006/09/09 15:29:49 eserte Exp $
# Author: Slaven Rezic
#

use strict;

use GD;
use GD::Convert;

BEGIN {
    if (!eval q{
	use Test::More;
        use Tk;
	use Tk::Config;
	die "No DISPLAY" if $win_arch eq 'x' && !$ENV{DISPLAY};
	1;
    }) {
	print "1..0 # skip: no Test::More and/or Tk modules\n";
	exit;
    }
}

use Getopt::Long;

GetOptions("d!" => \$GD::Convert::DEBUG)
    or die "usage: $0 [-d]";

plan tests => 4;

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

 SKIP: {
     skip("No ppmtogif available, no gif_netpbm check", 1)
	 if !is_in_path("ppmtogif");
     
     my $gif = $im->gif_netpbm(-transparencyhack => 1);
     ok($gif =~ /GIF/, "Detected GIF file");
     if (eval 'require MIME::Base64; 1') {
	 my $p4 = $mw->Photo(-data => MIME::Base64::encode_base64($gif));
	 $c->createImage(0,0,-anchor=>"nw", -image => $p4);
     }
 }

 SKIP: {
     skip("No convert (ImageMagick) available, no gif_imagemagick check", 1)
	 if !is_in_path("convert");
     
     my $gif2 = $im->gif_imagemagick(-transparencyhack => 1);
     ok($gif2 =~ /GIF/, "Detected GIF file");
     if (eval 'require MIME::Base64; 1') {
	 my $p5 = $mw->Photo(-data => MIME::Base64::encode_base64($gif2));
	 $c->createImage(200,0,-anchor=>"nw", -image => $p5);
     }
 }

my $xpm = $im->xpm;
ok($xpm =~ /XPM/, "Detected XPM file");
my $p6 = $mw->Photo(-data => $xpm);
$c->createImage(400,0,-anchor=>"nw", -image => $p6);

 SKIP: {
     skip("No convert (ImageMagick) available, no gif_imagemagick check", 1)
	 if !is_in_path("convert");

     my $gif3 = $im->gif_imagemagick;
     ok($gif3 =~ /GIF/, "Detected GIF file");
     if (eval 'require MIME::Base64; 1') {
	 my $p7 = $mw->Photo(-data => MIME::Base64::encode_base64($gif3));
	 $c->createImage(600,0,-anchor=>"nw", -image => $p7);
     }
 }

$mw0->Button(-text => "OK", -command => sub { $mw0->destroy })->pack
    if $ENV{PERL_TEST_INTERACTIVE};

if (!$ENV{PERL_TEST_INTERACTIVE}) { $mw0->after(1000, sub { $mw0->destroy }) }

MainLoop;

# REPO BEGIN
# REPO NAME file_name_is_absolute /home/e/eserte/work/srezic-repository 
# REPO MD5 89d0fdf16d11771f0f6e82c7d0ebf3a8

=head2 file_name_is_absolute($file)

=for category File

Return true, if supplied file name is absolute. This is only necessary
for older perls where File::Spec is not part of the system.

=cut

BEGIN {
    if (eval { require File::Spec; defined &File::Spec::file_name_is_absolute }) {
	*file_name_is_absolute = \&File::Spec::file_name_is_absolute;
    } else {
	*file_name_is_absolute = sub {
	    my $file = shift;
	    my $r;
	    if ($^O eq 'MSWin32') {
		$r = ($file =~ m;^([a-z]:(/|\\)|\\\\|//);i);
	    } else {
		$r = ($file =~ m|^/|);
	    }
	    $r;
	};
    }
}
# REPO END

# REPO BEGIN
# REPO NAME is_in_path /home/e/eserte/work/srezic-repository 
# REPO MD5 81c0124cc2f424c6acc9713c27b9a484

=head2 is_in_path($prog)

=for category File

Return the pathname of $prog, if the program is in the PATH, or undef
otherwise.

DEPENDENCY: file_name_is_absolute

=cut

sub is_in_path {
    my($prog) = @_;
    return $prog if (file_name_is_absolute($prog) and -f $prog and -x $prog);
    require Config;
    my $sep = $Config::Config{'path_sep'} || ':';
    foreach (split(/$sep/o, $ENV{PATH})) {
	if ($^O eq 'MSWin32') {
	    # maybe use $ENV{PATHEXT} like maybe_command in ExtUtils/MM_Win32.pm?
	    return "$_\\$prog"
		if (-x "$_\\$prog.bat" ||
		    -x "$_\\$prog.com" ||
		    -x "$_\\$prog.exe" ||
		    -x "$_\\$prog.cmd");
	} else {
	    return "$_/$prog" if (-x "$_/$prog" && !-d "$_/$prog");
	}
    }
    undef;
}
# REPO END

__END__
