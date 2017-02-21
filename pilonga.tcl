#!/usr/bin/tclsh
# -*- coding: utf-8 -*-
#
# Licensed under the GNU General Public License, version 2.
# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

global gDestDir gEbuildFile
set gDestDir "~/Desktop/pilonga"

global gpwd

set gpwd [pwd]

source lang/lang.tcl
source "debug.tcl"
#general utility functions...
source util.tcl
#evaluates arguments given at command prompt...
source arg.tcl
source pardus_packages.tcl
#utility functions for bash script
source bash.tcl
#resource downloading from www.gentoo-portage.com
source gentoo-portage.tcl
#ebuild parsing scripts
source ebuild.tcl
source ebuild2pisi.tcl
#creating action.py and pspec.xml
source pisi_action.tcl
source pisi_pspec.tcl
#dependency utilities
source dependency.tcl

set Last_Dir ""

cd "$gDestDir"
file mkdir "$gDestDir"

#This Part gets ebuild file with direct path with argument option -ef ...
if { $ARG_EbuildFile != "" } {
    set gEbuildFile $ARG_EbuildFile
    ::ebuild2pisi::Parse
    cd "$gDestDir"
    file mkdir "./$geName/"
    cd "./$geName/"
    ::pisi_pspec::Create; ::pisi_action::Create
    ::dependency::Check
    ::dependency::Report
    ::gentoo-portage::DownloadPatch
    set Last_Dir [pwd]
}

CreateComponentXML

#This part gets ebuild file from gentoo-portage...
foreach { ProgName } $ARG_ProgName {
    if { ![::gentoo-portage::DownloadEbuild $ProgName] } continue
    ::ebuild2pisi::Parse
    if {$xSourcePath == ""} {
        PutMessageRed $MSG_Missing_Mandatory_Field_SourcePath
        continue
    }
    ::pisi_pspec::Create; ::pisi_action::Create
    ::dependency::Check
    ::dependency::Report
    ::gentoo-portage::DownloadPatch
    set Last_Dir [pwd]
    cd ..
}

#open window
if {$ARG_NoWindow == 0 && $Last_Dir != ""} {
    if {$ARG_ProgName != "" || $ARG_EbuildFile != ""} {
        catch {eval exec "kstart --alldesktops konqueror $Last_Dir  > /dev/null 2>&1 &"}
    }
}