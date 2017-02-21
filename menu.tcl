#!/usr/bin/tclsh
# -*- coding: utf-8 -*-
#
# Licensed under the GNU General Public License, version 2.
# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
# Functions related to File downloading from www.gentoo-portage.com

global gIUSEexception

namespace eval ::menu {
    #Show Search Result..
    proc SellectSearchRes {filename} {
        global ARG_NoVersionList
        global gCategory gProgName

        set fh  [open  $filename "r+"]
        set SearchRes ""
        set found 0
        while {[gets $fh line]  >= 0 } {
            if {[regexp "<div *id=\"search_results\">" $line]} {
                while {[gets $fh line]  >= 0 } {
                    if {[regexp "<div>(.*)/(.*) * <div>(.*)</div></div>" $line Dummy gCategory gProgName Summary]} {
                        set SearchRes "$SearchRes {$gCategory} {$gProgName} {$Summary}"
                        set found 1
                    } else {
                        if {[regexp "<div>" $line]} break
                    }
                }
            }
            if { $found == 1 } break
        }
        close $fh
        file delete $filename
        if { $found == 0 } {
            PutErrorMessage [format "[uplevel #0 {set MSG_not_found}]" $filename]
            return 0
        }

        if {$ARG_NoVersionList} { return "[lindex $SearchRes 0] [lindex $SearchRes 1]" }
        set Ind 0
        set Ind2 1
        foreach {a b c} $SearchRes {
            incr Ind
            puts "    $Ind. $b \[36m(Category:$a, \[33mSummary:$c)\[39m"
        }
        puts [format "[uplevel #0 {set MSG_select_application}]" $Ind]
        gets stdin Ind2
        if {$Ind2 == "q"} exit
        if {$Ind2 < 1 || $Ind2 > $Ind} {set Ind2 1}
        set Ind2 [expr 3*($Ind2-1)]
        return "[lindex $SearchRes $Ind2] [lindex $SearchRes [incr Ind2]]"
    }
    #Show a choice list for Ebuild versions
    proc SellectEbuild {filename} {
        global ARG_NoVersionList

        set fh [open $filename "r+"]
        set found 0
        set Ebuilds ""
        set Describe ""
        while {[gets $fh line]  >= 0 } {
            #Get Program Explanation
            if {$Describe == ""} {regexp "<h5 style=\"margin-left: 5em;\" class=\"gray\">(.*)</h5>" $line Dummy Describe}
            #Get Version List
            regexp "<div style=\"width: 20em; float:left;\"><b>(.*)</b></div>" $line  Dummy Ebuild2
            if {[regexp "<a href=\"/AJAX/Ebuild/(\[0-9]*)\">" $line  Dummy Ebuild]} {
                set Ebuilds "$Ebuilds $Ebuild2 $Ebuild"
                set found 1
                #break
            }
        }
        close $fh
        file delete $filename
        puts $Describe

        if { $found == 0 } {
            uplevel #0 {PutErrorMessage $MSG_ebuild_file_not_found}
            return 0
        }

        if {$ARG_NoVersionList} { return "[lindex $Ebuilds 0] [lindex $Ebuilds 1]" }

        set Ind 0
        set Ind2 1
        foreach {a b} $Ebuilds {
            incr Ind
            puts "    $Ind. $a"
        }
        puts [format "[uplevel #0 {set MSG_select_application_version}]" $Ind]
        gets stdin Ind2
        if {$Ind2 == "q"} exit
        if {$Ind2 < 1 || $Ind2 > $Ind} {set Ind2 1}
        set Ind2 [expr 2*($Ind2-1)]

        return "[lindex $Ebuilds $Ind2] [lindex $Ebuilds [incr Ind2]]"
    }
    #Sellect IUSE
    proc SellectIUSEexception {} {
        global gIUSEexception
        puts ">> IUSE  :"
        puts [::bash::GetValue "IUSE"]
        puts ">> Insert IUSE exceptions:"
        gets stdin gIUSEexception
    }
}