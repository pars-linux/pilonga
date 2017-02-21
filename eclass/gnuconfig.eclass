# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /cvsroot/atomicl/portage/eclass/gnuconfig.eclass,v 1.3 2005/07/23 02:08:18 sjlongland Exp $
#
# Author: Will Woods <wwoods@gentoo.org>
#
# This eclass is used to automatically update files that typically come with
# automake to the newest version available on the system. The most common use
# of this is to update config.guess and config.sub when configure dies from
# misguessing your canonical system name (CHOST). It can also be used to update
# other files that come with automake, e.g. depcomp, mkinstalldirs, etc.
#
# usage: gnuconfig_update [file1 file2 ...]
# if called without arguments, config.guess and config.sub will be updated.
# All files in the source tree ($S) with the given name(s) will be replaced
# with the newest available versions chosen from the list of locations in
# gnuconfig_findnewest(), below.
#
# gnuconfig_update should generally be called from src_unpack()

ECLASS=gnuconfig
INHERITED="$INHERITED $ECLASS"

DEPEND="sys-devel/gnuconfig"

DESCRIPTION="Based on the ${ECLASS} eclass"

# Wrapper function for gnuconfig_do_update. If no arguments are given, update
# config.sub and config.guess (old default behavior), otherwise update the
# named files.
gnuconfig_update() {
	local startdir	# declared here ... used in gnuconfig_do_update

	if [[ $1 == /* ]] ; then
		startdir=$1
		shift
	else
		startdir=${S}
	fi

	if [[ $# -gt 0 ]] ; then
		gnuconfig_do_update "$@"
	else
		gnuconfig_do_update config.sub config.guess
	fi

	return $?
}

# Copy the newest available version of specified files over any old ones in the
# source dir. This function shouldn't be called directly - use gnuconfig_update
#
# Note that since bash using dynamic scoping, startdir is available here from
# the gnuconfig_update function
gnuconfig_do_update() {
	local configsubs_dir target targetlist file

	[[ $# -eq 0 ]] && die "do not call gnuconfig_do_update; use gnuconfig_update"

	configsubs_dir=$(gnuconfig_findnewest)
	einfo "Using GNU config files from ${configsubs_dir}"
	for file in "$@" ; do
		if [[ ! -r ${configsubs_dir}/${file} ]] ; then
			eerror "Can't read ${configsubs_dir}/${file}, skipping.."
			continue
		fi
		targetlist=$(find "${startdir}" -name "${file}")
		if [[ -n ${targetlist} ]] ; then
			for target in ${targetlist} ; do
				einfo "  Updating ${target/$startdir\//}"
				cp -f "${configsubs_dir}/${file}" "${target}"
				eend $?
			done
		else
			ewarn "  No ${file} found in ${startdir}, skipping ..."
		fi
	done

	return 0
}

# this searches the standard locations for the newest config.{sub|guess}, and
# returns the directory where they can be found.
gnuconfig_findnewest() {
	local locations="
		/usr/share/gnuconfig/config.sub
		/usr/share/automake-1.9/config.sub
		/usr/share/automake-1.8/config.sub
		/usr/share/automake-1.7/config.sub
		/usr/share/automake-1.6/config.sub
		/usr/share/automake-1.5/config.sub
		/usr/share/automake-1.4/config.sub
		/usr/share/libtool/config.sub
	"
	grep -s '^timestamp' ${locations} | sort -n -t\' -k2 | tail -n 1 | sed 's,/config.sub:.*$,,'
}
