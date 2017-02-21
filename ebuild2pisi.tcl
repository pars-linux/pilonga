# -*- coding: utf-8 -*-
#
# Licensed under the GNU General Public License, version 2.
# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

# Functions related to parsing the ebuild file...

global xDescription xHomepage xDependency xRDependency xLicense xSourcePath xPatch xsetup xbuild xinstall xdodoc xkde xconfopt xbashvar xbashlocalvar xWorkDir

# Bash Function Return Value....
global gRet gByPassIf gByPassElse gIfNum

set gByPassIf 0
set gByPassElse 0
set gIfNum 0
set gRet 1

source cache.tcl
source function_util.tcl

namespace eval ::ebuild2pisi {
    #Parse Ebuild to Actions.py
    proc Parse {} {
        global xsetup xbuild xinstall xkde xconfopt xbashvar xbashlocalvar xWorkDir
        global xDescription xHomepage xDependency xRDependency xLicense xSourcePath xPatch
        global gline gCommandLineList xFunctionDefinitions gPkgZipName gEbuildFile

        set gPkgZipName ""; set Inherit ""; set xbashvar ""; set xbashlocalvar ""

        ::ebuild::OpenEbuildFile
        while { [::ebuild::GetNewLine] >= 0 } {
            ::bash::ParseVariable
            if {[::bash::Parse_Inherit $gline] != -1} {set Inherit [::bash::Parse_Inherit $gline]}
            if {[::bash::Parse_PkgZipName $gline] != -1} {set gPkgZipName [::bash::Parse_PkgZipName $gline]}
        }
        ::ebuild::CloseEbuildFile

        ::menu::SellectIUSEexception

        # set initial values
        set xsetup "";set xbuild "";set xinstall "";set xkde "";set xconfopt "";set xWorkDir "";set xbashvar ""
        set xFunctionDefinitions "";set xDescription "";set xHomepage "";set xDependency "";set xRDependency ""
        set xLicense "";set xSourcePath "";set xPatch "";set xbashvar "";set xbashlocalvar ""

        ::bash::GetGentooVariables

        file mkdir "eclass"
        cd "eclass"

        #Interpret eclass files
        foreach Eclass $Inherit {
            if {[::ebuild::CopyAndOpenEclassFile $Eclass]} {
                while { [::ebuild::GetNewLine] >= 0 } {
                    #get Variable Assignments
                    ::bash::ParseVariable
                    #get function definitions
                    ::bash::ParseFunctionDefinition
                }
                ::ebuild::CloseEclassFile
            }
        }

        cd ".."

        #Intepret ebuild file
        PutMessage [format "[uplevel #0 {set MSG_eclass_parsing}]" "$gEbuildFile"]
        ::ebuild::OpenEbuildFile
        while { [::ebuild::GetNewLine] >= 0 } {
            #get Variable Assignments
            ::bash::ParseVariable
            #get function definitions
            ::bash::ParseFunctionDefinition
        }
        ::ebuild::CloseEbuildFile

        RunFunctionDefinition "pkg_setup"
        ::cache::Disable
        RunFunctionDefinition "pkg_nofetch"
        RunFunctionDefinition "src_unpack"
        ::cache::Enable
        RunFunctionDefinition "src_compile"
        RunFunctionDefinition "src_install"
        #RunFunctionDefinition "src_test"
        #RunFunctionDefinition "pkg_preinst"
        #RunFunctionDefinition "pkg_postinst"
        #RunFunctionDefinition "pkg_prerm"
        #RunFunctionDefinition "pkg_postrm"
        RunFunctionDefinition "pkg_config"
        set xinstall [::cache::Get]

        set Dodoc [::bash::GetValue DOCS]
        if {$Dodoc != "" } {
            regsub -all " " $Dodoc "\",\"" Dodoc
            regsub -all "\"" $Dodoc "" Dodoc
            set xinstall "$xinstall    pisitools.dodoc(\"$Dodoc\")\n"
        }

        if {$xconfopt != ""} {set xsetup "    autotools.configure($xconfopt)\n$xsetup"}

        set xWorkDir [::bash::GetValue "S"]
        regsub "/?$" $xWorkDir "/" xWorkDir
        if {$xWorkDir == "/"} {set xWorkDir ""}

        regsub -all "( |^)\[^ ]*/" [::bash::GetValue "PATCHES"] "\\1" xPatch

        set xDescription [::bash::GetValue DESCRIPTION]
        set xHomepage [::bash::GetValue HOMEPAGE]
        set xLicense [::bash::GetValue LICENSE]
        set xSourcePath [::bash::GetValue SRC_URI]
        if { $xSourcePath != "" } {
            foreach a $xSourcePath { if {[regexp "\.tar\." $a]} break }
            set xSourcePath $a
            regsub "^mirror:" $xSourcePath "mirrors:" xSourcePath
        }
        set xRDependency [::dependency::GetDependencies "[::bash::GetValue RDEPEND] [::bash::GetValue BOTH_DEPEND]"]
        set xDependency [::dependency::GetDependencies "[::bash::GetValue DEPEND] [::bash::GetValue BOTH_DEPEND]"]
    }

    proc RunCodeBlock {Body} {
        global xbashlocalvar gline gByPassIf gRet
        set gRet 1
        if {$Body == ""} {return ""}
        set MyOutput ""
        ::cache::ResetUnknownCF
        foreach {gline} $Body {
            # CheckFunctionSeperators : function seperators && || ; ...
            ::bash::CheckFunctionSeperators $gline
            ::cache::StatusPut
            while {[set flist [::bash::GetNextFunction]] != "~~-1~~"} {

                if {[lindex $flist 0] == "return"} {
                    if {[lindex $flist 1] != "0"} {set gRet 0}
                    ::cache::StatusPush
                    return $MyOutput
                }

                if {[ByPassIf $flist]} continue
                if {[ByPassElse $flist]} continue

                #Pilonga defined functions..
                if {[::func::FunctionAvailable $flist]} {
                    set MyOutput "[::func::RunFunction $flist]$MyOutput"
                    continue
                }

                #Ebuild defined functions..
                if {[::bash::IsFunctionDefined [lindex $flist 0]]} {
                    set my_local $xbashlocalvar
                    #prevent recursive callings
                    set fname [::bash::GetValue 0]
                    set fname2 [lindex $flist 0]
                    if {$fname == $fname2} continue
                    set MyOutput "[::ebuild2pisi::RunFunctionDefinition $flist]$MyOutput"
                    set xbashlocalvar $my_local
                    continue
                }

                ::cache::SetUnknownCF
            }
            ::cache::StatusPush
        }
        return $MyOutput
    }

    proc RunFunctionDefinition {FunctionList} {
        global xbashlocalvar gRet
        set gRet 1
        set MyOutput ""

        ::profil::FuncNamePut $FunctionList
        ::profil::FuncNameListPrint

        SetInitialLocalVariables $FunctionList
        set Body [::bash::GetFunctionBody [lindex $FunctionList 0]]
        set MyOutput [::ebuild2pisi::RunCodeBlock $Body]
        PrintLocalVar [lindex $FunctionList 0]
        set xbashlocalvar ""

        ::profil::FuncNamePush
        ::profil::FuncNameListPrint

        return $MyOutput
    }

    proc SetInitialLocalVariables {FunctionList} {
        global xbashlocalvar
        set Num 0
        set xbashlocalvar ""
        foreach Param $FunctionList {
            set xbashlocalvar [linsert $xbashlocalvar end $Num $Param]
            incr Num
        }
        set Num [llength $FunctionList]
        set xbashlocalvar [linsert $xbashlocalvar end "\\*" [lrange $FunctionList 1 end] "@" [lrange $FunctionList 1 end] "#" $Num]
    }

    proc ByPassIf {flist} {
        global gRet gByPassIf gIfNum
        if {[lindex $flist 0] == "then" && $gRet == 0 && $gByPassIf == 0} {
            set gByPassIf 1
            return 1
        }
        if {$gByPassIf == 0} {return 0}
        if {[lindex $flist 0] == "if"} {incr gIfNum}
        if {[lindex $flist 0] == "fi"} {incr gIfNum -1}
        if {[lindex $flist 0] == "else" && $gIfNum == 0} {set gByPassIf 0}
        if {$gIfNum == "-1"} {
            set gByPassIf 0
            set gIfNum 0
            return 0
        }
        return 1
    }

    proc ByPassElse {flist} {
        global gByPassElse gIfNum
        if {[lindex $flist 0] == "else" && $gByPassElse == 0} {
            set gByPassElse 1
            return 1
        }
        if {$gByPassElse == 0} {return 0}
        if {[lindex $flist 0] == "if"} {incr gIfNum}
        if {[lindex $flist 0] == "fi"} {incr gIfNum -1}
        if {$gIfNum == "-1"} {
            set gByPassElse 0
            set gIfNum 0
            return 0
        }
        return 1
    }
}