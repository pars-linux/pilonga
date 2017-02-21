#!/usr/bin/tclsh
# -*- coding: utf-8 -*-
#
# Licensed under the GNU General Public License, version 2.
# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

# Functions related to File downloading from www.gentoo-portage.com

global gCategory gProgName gEbuild2 gEbuild

set gCategory ""
set gProgName ""
set gEbuild2 ""
set gEbuild ""

source menu.tcl

namespace eval ::gentoo-portage {
    #Downloads Ebuild file and search...
    proc DownloadEbuild {ProgramName} {
        if {$ProgramName == ""} {return 0}
        if {![::gentoo-portage::SearchInGentoo $ProgramName]} {return 0}
        if {![::gentoo-portage::GetPackageVersion]} {return 0}
        return [::gentoo-portage::DownloadEbuild_]
    }
    #Downloads Ebuild file...
    proc DownloadEbuild_ {} {
        global gCategory gProgName gEbuild2 gEbuild gEbuildFile
 
        catch {exec wget "http://gentoo-portage.com/AJAX/Ebuild/$gEbuild"}

        file delete "[set gEbuild2].ebuild"
        file rename $gEbuild "[set gEbuild2].ebuild"
        file mkdir "./$gProgName/"
        file delete "./$gProgName/[set gEbuild2].ebuild"
        file copy "[set gEbuild2].ebuild" "./$gProgName/[set gEbuild2].ebuild"
        file delete "[set gEbuild2].ebuild"

        PutMessage [format "[uplevel #0 {set MSG_saving}]" "[pwd]/$gProgName/[set gEbuild2].ebuild"]
        set gEbuildFile "[set gEbuild2].ebuild"
        cd "./$gProgName/"
        return 1
    }
    #Search In Gentoo...
    proc SearchInGentoo {ProgramName} {
        global gCategory gProgName

        if { $ProgramName == "" } {
            uplevel #0 {PutErrorMessage $MSG_program_name_not_entered}
            return 0
        }
        PutMessagePink [format "[uplevel #0 {set MSG_searching_in_gentoo_portage}]" $ProgramName]
        catch {exec wget "http://gentoo-portage.com/Search?search=$ProgramName"}
        if {[catch {glob "Search?search=$ProgramName"}]} {
            uplevel #0 {PutErrorMessage $MSG_unable_to_connect_gentoo_site}
            exit 1
        }

        if {![regexp "^(.*) (.*)$" [::menu::SellectSearchRes "Search?search=$ProgramName"] Dummy gCategory gProgName]} {
            return 0
        }

        return 1
    }
    #Get selected package's version from gentoo
    proc GetPackageVersion {} {
        global gCategory gProgName gEbuild2 gEbuild

        PutMessagePink [format "[uplevel #0 {set MSG_searching_in_gentoo_portage}]" $gProgName]

        catch {exec wget "--output-document=./_$gProgName" "http://gentoo-portage.com/$gCategory/$gProgName"}

        if {![regexp "^(.*) (.*)$" [::menu::SellectEbuild "_$gProgName"] Dummy gEbuild2 gEbuild]} {
            return 0
        }

        uplevel #0 {PutMessage $MSG_ebuild_file_found}
        return 1
    }
    #Downloads patch file...
    proc DownloadPatch {} {
        global gCategory gProgName
        global xPatch ARG_NoPatchDownload
        if {$ARG_NoPatchDownload} return
        if {$xPatch == ""} return
        file mkdir "./files/"
        cd "./files/"
        foreach {a} $xPatch {
            PutMessage [format "[uplevel #0 {set MSG_downloading}]" $a]
            file delete $a
            catch {exec wget  "http://sources.gentoo.org/viewcvs.py/*checkout*/gentoo-x86/$gCategory/$gProgName/files/$a"}
        }
        cd ..
    }
}