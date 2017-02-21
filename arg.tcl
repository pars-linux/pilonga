# -*- coding: utf-8 -*-
#
# Licensed under the GNU General Public License, version 2.
# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

global ARG_Help ARG_Version ARG_DestDir ARG_EbuildFile ARG_NoWindow ARG_ProgName ARG_NoPatchDownload
global ARG_NoDependencyCheck ARG_NoVersionList

source help.tcl

namespace eval ::arg {
    #checks option '-h' and shows help...
    proc GetOptions {} {
        global argv
        global ARG_Help ARG_Version ARG_DestDir ARG_EbuildFile ARG_NoWindow ARG_ProgName ARG_NoPatchDownload ARG_OpenDirectory
        global ARG_NoDependencyCheck ARG_NoVersionList
        global gDestDir

        global gDebug_ShowFunctionLine gDebug_ShowLineByLine gDebug_NewVariable 
        global gDebug_ShowFunctionDef gDebug_PrintLocalVar

        set ARG_Help       0
        set ARG_Version    0
        set ARG_DestDir    ""
        set ARG_EbuildFile ""
        set ARG_NoWindow   0
        set ARG_ProgName   ""
        set ARG_NoPatchDownload 0
        set ARG_NoDependencyCheck 0
        set ARG_NoVersionList 0
        set Name ""
        set Email ""

        foreach {arg} $argv {
            if {$ARG_DestDir == 1} {set gDestDir $arg;  set ARG_DestDir ""; continue}
            if {$ARG_EbuildFile == 1} {set ARG_EbuildFile $arg; continue}
            if {$arg == "-h" ||  $arg == "--help"} {set ARG_Help 1; continue}
            if {$arg == "--version"} {set ARG_Version 1; continue}
            if {$arg == "-d" ||  $arg == "--destdir"} {set ARG_DestDir 1; continue}
            if {$arg == "-f" ||  $arg == "--ebuild-file"} {set ARG_EbuildFile 1; continue}
            if {$arg == "-nw" ||  $arg == "--no-window"} {set ARG_NoWindow 1; continue}
            if {$arg == "-np" ||  $arg == "--no-patch-download"} {set ARG_NoPatchDownload 1; continue}
            if {$arg == "-nd" ||  $arg == "--no-dependency-check"} {set ARG_NoDependencyCheck 1; continue}
            if {$arg == "-nm" ||  $arg == "--no-menu"} {set ARG_NoVersionList 1; continue}

            #debug flags
            if {$arg == "-D1"} {set gDebug_ShowFunctionLine 1; continue}
            if {$arg == "-D2"} {set gDebug_ShowLineByLine 1; continue}
            if {$arg == "-D3"} {set gDebug_NewVariable 1; continue}
            if {$arg == "-D4"} {set gDebug_ShowFunctionDef 1; continue}
            if {$arg == "-D5"} {set gDebug_PrintLocalVar 1; continue}

            if {[regexp "^-" $arg]} {
                PutErrorMessage [format "[uplevel #0 {set MSG_invalid_option}]" $arg]
                uplevel #0 {puts $MSG_use_pilonga_help_command_for_general_help}
                exit 1
            }
            set ARG_ProgName "$ARG_ProgName $arg"
        }

        if {$argv == ""} {
            set ARG_Help 1
            uplevel #0 {puts $MSG_usage}
            ::help::ShowHelp
            return 0
        }

        ::help::ShowHelp

        return 1
    }
}

if { [::arg::GetOptions] == 0 } exit
