# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /cvsroot/atomicl/portage/eclass/freedict.eclass,v 1.3 2005/07/23 02:08:18 sjlongland Exp $

# Author: Seemant Kulleen <seemant@gentoo.org>
# This eclass exists to ease the installation of freedict translation
# dictionaries.  The only variables which need to be defined in the actual
# ebuilds are FORLANG and TOLANG for the source and target languages,
# respectively.

inherit eutils

ECLASS="freedict"
INHERITED="$INHERITED $ECLASS"

IUSE=""

MY_P=${PN/freedict-/}

S=${WORKDIR}
DESCRIPTION="Freedict for language translation from ${FORLANG} to ${TOLANG}"
HOMEPAGE="http://www.freedict.de"
SRC_URI="http://freedict.sourceforge.net/download/linux/${MY_P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="x86 ~amd64 ppc ~sparc ~alpha ~mips ~hppa"

DEPEND="app-text/dictd"

freedict_src_install() {
	insinto /usr/$(get_libdir)/dict
	doins ${MY_P}.dict.dz
	doins ${MY_P}.index
}

EXPORT_FUNCTIONS src_install
