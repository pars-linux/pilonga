# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /cvsroot/atomicl/portage/eclass/64-bit.eclass,v 1.3 2005/07/23 02:08:18 sjlongland Exp $

# Recognize 64-bit arches...
# Example:
#      64-bit && epatch ${P}-64bit.patch
# 
64-bit() {
	[[ ${PN} != "R" && ${PN} != "rxvt-unicode" ]] && die "DO NOT USE THIS ECLASS"

	case "${ARCH}" in 
		alpha|*64) return 0 ;;
		*)         return 1 ;;
	esac
}
