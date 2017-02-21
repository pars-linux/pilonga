# -*- coding: utf-8 -*-
#
# Licensed under the GNU General Public License, version 2.
# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

# Functions related to parsing the ebuild file...
global gCachePisi gCachePisiEnable gFunctionCache gFunctionNameProfil

global gCacheUnknownCF

set gCachePisi ""
set gCachePisiEnable 1
set gFunctionCache ""
set gFunctionNameProfil ""
set gCacheUnknownCF 0

namespace eval ::cache {

    #pisi file cache
    proc Add {line} {
        global gCachePisi gCachePisiEnable gDebug_PrintCache
        if {!$gCachePisiEnable} return
        if {$gDebug_PrintCache} {puts "PISI>  $line"}
        set gCachePisi "$gCachePisi    $line\n"
        regsub -all "\n+" $gCachePisi "\n" gCachePisi
        regsub -all "^\n" $gCachePisi "" gCachePisi
    }

    proc Get {} {
        global gCachePisi gCachePisiEnable
        if {!$gCachePisiEnable} {return ""}
        set Cache $gCachePisi
        set gCachePisi ""
        return $Cache
    }

    proc Enable {} {
        global gCachePisiEnable
        set gCachePisiEnable 1
    }

    proc Disable {} {
        global gCachePisiEnable
        set gCachePisiEnable 0
    }

    #function codeblock cache
    proc SetUnknownCF {} {
        global gCacheUnknownCF
        set gCacheUnknownCF 1
    }
    proc ResetUnknownCF {} {
        global gCacheUnknownCF
        set gCacheUnknownCF 0
    }
    proc GetUnknownCF {} {
        global gCacheUnknownCF
        return $gCacheUnknownCF
    }

    #Function, shell, bash line status...
    proc StatusUpdate {} {
        global gFunctionCache
        global gCommandLineList gFunctionSepList gFuncInd
        set gFunctionCache [lreplace $gFunctionCache 0 2 $gCommandLineList $gFunctionSepList $gFuncInd]
    }
    proc StatusGet {} {
        global gFunctionCache
        global gCommandLineList gFunctionSepList gFuncInd
        set gCommandLineList [lindex $gFunctionCache 0]
        set gFunctionSepList [lindex $gFunctionCache 1]
        set gFuncInd [lindex $gFunctionCache 2]
    }
    proc StatusPut {} {
        global gFunctionCache
        global gCommandLineList gFunctionSepList gFuncInd
        set gFunctionCache [linsert $gFunctionCache 0 $gCommandLineList $gFunctionSepList $gFuncInd]
    }
    proc StatusPush {} {
        global gFunctionCache
        global gCommandLineList gFunctionSepList gFuncInd
        set gFunctionCache [lreplace $gFunctionCache 0 2]
    }
}

namespace eval ::profil {
    #Function Name List...
    proc FuncNameListPrint {} {
        global gFunctionNameProfil gDebug_Profil
        PutMessageLightBlue "=> $gFunctionNameProfil"
    }
    proc FuncNamePut {Name} {
        global gFunctionNameProfil
        set gFunctionNameProfil [linsert $gFunctionNameProfil end [lindex $Name 0] "=>"]
    }
    proc FuncNamePush {} {
        global gFunctionNameProfil
        set gFunctionNameProfil [lreplace [lreplace $gFunctionNameProfil end end] end end]
    }
}