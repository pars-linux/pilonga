# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /cvsroot/atomicl/portage/eclass/gnome.org.eclass,v 1.3 2005/07/23 02:08:18 sjlongland Exp $
#
# Authors:
# Spidler <spidler@gentoo.org>
# with help of carparski.
#
# Gnome ECLASS. mainly SRC_URI settings

ECLASS="gnome.org"
INHERITED="$INHERITED $ECLASS"

[ -z "${GNOME_TARBALL_SUFFIX}" ] && export GNOME_TARBALL_SUFFIX="bz2"
PVP=(${PV//[-\._]/ })
SRC_URI="mirror://gnome/sources/${PN}/${PVP[0]}.${PVP[1]}/${P}.tar.${GNOME_TARBALL_SUFFIX}"

