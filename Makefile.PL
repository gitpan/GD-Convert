#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: Makefile.PL,v 1.1 2001/11/22 22:14:11 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 2001 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: slaven.rezic@berlin.de
# WWW:  http://www.rezic.de/eserte/
#

use ExtUtils::MakeMaker;

WriteMakefile
  (
   'NAME'	   => 'GD::Convert',
   'VERSION_FROM'  => 'Convert.pm',
   'PREREQ_PM'     => { GD => undef },

   'dist' => {'POSTOP'=>'-$(CHMOD) 644 $(DISTVNAME).tar$(SUFFIX)'},

   'ABSTRACT_FROM' => '',
   'AUTHOR'        => 'Slaven Rezic (eserte@onlineoffice.de)',
  );

__END__
