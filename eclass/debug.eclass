# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /cvsroot/atomicl/portage/eclass/debug.eclass,v 1.3 2005/07/23 02:08:18 sjlongland Exp $
#
# Author: Spider
#
# A general DEBUG eclass to ease inclusion of debugging information
# and to remove "bad" flags from CFLAGS

# Debug ECLASS
ECLASS="debug"
INHERITED="$INHERITED $ECLASS"
IUSE="debug"

if useq debug; then
	# Do _NOT_ strip symbols in the build! Need both lines for Portage 1.8.9+
	DEBUG="yes"
	RESTRICT="$RESTRICT nostrip"
	# Remove omit-frame-pointer as some useless folks define that all over the place. they should be shot with a 16 gauge slingshot at least :)
	# force debug information
	export CFLAGS="${CFLAGS/-fomit-frame-pointer/} -g"
	export CXXFLAGS="${CXXFLAGS/-fomit-frame-pointer/} -g"
	# einfo "CFLAGS and CXXFLAGS redefined"
fi
