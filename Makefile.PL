#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: Makefile.PL,v 1.4 2003/02/07 11:39:33 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 2001 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: slaven@rezic.de
# WWW:  http://www.rezic.de/eserte/
#

use ExtUtils::MakeMaker;

WriteMakefile
  (
   'NAME'	   => 'GD::Convert',
   'VERSION_FROM'  => 'Convert.pm',
   'PREREQ_PM'     => { GD => 0 },

   'dist' => {'POSTOP'=>'-$(CHMOD) 644 $(DISTVNAME).tar$(SUFFIX)'},

   'ABSTRACT_FROM' => '',
   'AUTHOR'        => 'Slaven Rezic (slaven@rezic.de)',
  );

sub MY::postamble {
    if (defined $ENV{USER} && $ENV{USER} eq 'eserte') {
	<<'EOF';
release :: dist
	cpan-upload $(DISTVNAME).tar$(SUFFIX)

EOF
    }
}

__END__
