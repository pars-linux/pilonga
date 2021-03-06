# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /cvsroot/atomicl/portage/eclass/gnat.eclass,v 1.3 2005/07/23 02:08:18 sjlongland Exp $
#
# Author: David Holm <dholm@gentoo.org>
#
# This eclass contains some common settings for gnat based ada stuff
# It also strips some flags to bring C[XX]FLAGS in cpmpliance with gcc-2.8.1

ECLASS=gnat

inherit flag-o-matic

INHERITED="$INHERITED $ECLASS"

DEPEND="dev-lang/gnat"

DESCRIPTION="Based on the ${ECLASS} eclass"

gnat_filter_flags() {
	# We should probably check which GNAT is installed and
	# filter flags accordingly. This version is overly protective.

	filter-mfpmath sse 387

	filter-flags -mmmx -msse -mfpmath -frename-registers \
		-fprefetch-loop-arrays -falign-functions=4 -falign-jumps=4 \
		-falign-loops=4 -msse2 -frerun-loop-opt -maltivec -mabi=altivec \
		-fsigned-char -fno-strict-aliasing -pipe
}

pkg_setup() {
	export ADAC=${ADAC:-gnatgcc}
	export ADAMAKE=${ADAMAKE:-gnatmake}
	export ADABIND=${ADABIND:-gnatbind}

	gnat_filter_flags

	export ADACFLAGS=${ADACFLAGS:-${CFLAGS}}
	export ADACFLAGS=${ADACFLAGS//pentium-mmx/i586}
	export ADACFLAGS=${ADACFLAGS//pentium[234]/i686}
	export ADACFLAGS=${ADACFLAGS//k6-[23]/k6}
	export ADACFLAGS=${ADACFLAGS//athlon-tbird/i686}
	export ADACFLAGS=${ADACFLAGS//athlon-4/i686}
	export ADACFLAGS=${ADACFLAGS//athlon-[xm]p/i686}
	export ADACFLAGS=${ADACFLAGS//athlon/i686}
	export ADACFLAGS=${ADACFLAGS//-Os/-O2}

	export ADAMAKEFLAGS=${ADAMAKEFLAGS:-"-cargs ${ADACFLAGS} -margs"}
	export ADABINDFLAGS=${ADABINDFLAGS:-""}
}
