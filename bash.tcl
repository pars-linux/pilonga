# -*- coding: utf-8 -*-
#
# Licensed under the GNU General Public License, version 2.
# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

# Functions related to bash script languae (ebuild files are written with bash language). mostly used in ebuild.tcl

global geName geVersion geSuffix geSuffixVer geRevision
global gCommandLineList gFunctionSepList gPkgZipName
global xFunctionDefinitions

source predefined_functions.tcl
source String.tcl

namespace eval ::bash {

    proc GetGentooVariables {} {
        global xbashvar gEbuildFile
        global geName geVersion geSuffix geSuffixVer geRevision

        set geName ""
        set geVersion ""
        set Suffix ""
        set geSuffix ""
        set geSuffixVer ""
        set Revision ""
        set geRevision ""

        regexp "^.*/(\[^/]*)$" $gEbuildFile xx gEbuildFile
        set  Rest $gEbuildFile
        regexp "^(.*)(-(r\[0-9]*)).ebuild$" $Rest dummy Rest Revision geRevision
        regexp "^(.*)(_(alpha|beta|pre|rc|p)(\[0-9]*)?)?$" $Rest dummy Rest Suffix geSuffix geSuffixVer
        regexp "^(.*)-(\[0-9].*)$" $Rest dummy geName geVersion

        #variables you can utilize but never set
        set xbashvar [linsert $xbashvar end P "$geName-$geVersion$Suffix" \
                                            PN "$geName" \
                                            PV "$geVersion$Suffix" \
                                            PR "$geRevision" \
                                            PVR "$geVersion$Suffix$Revision" \
                                            PF "$geName-$geVersion$Suffix$Revision" \
                                            S "$geName-$geVersion$Suffix" \
                                            T "/tmp" \
                                            GAMES_BINDIR "usr/bin" \
                                            ROOT [::func::FS installDIR] \
                                            D ""  DISTDIR "" FILESDIR "" WORKDIR "" INHERITED "" \
                                            INSDESTTREE "" DESTTREE "/usr" "~diropts~" 0755 "~exeopts~" 0755 \
                                            "~insopts~" 0644 "~libopts~" 0644]
    }

    # Clean Bash Variables...
    proc cleanBashVar {a} {
        regsub -all "\\$\{\[^\{\}]+\}" $a "" a
        regsub -all "\[\{\}/]" $a "" a
        regsub -all "," $a " " a
        return $a
    }

    # Clean Bash Variables...
    proc cleanBashVar2 {a} {
        regsub -all "\\$\{\[^\{\}]+\}" $a "" a
        regsub -all "," $a " " a
        return $a
    }

    proc Parse_PkgZipName {line} {
        #get bash variables
        set ZipName -1
        if {[regexp "^\[ \t]*SRC_URI=(.*)$" $line]} {
            set line [lindex [::String::BashLine2TclList $line] 0]
            regexp "/(\[^\/]+)\.tar\.?.?.?.?.?(\[ \t]|$)" $line xx ZipName
            regsub "\\$"  $ZipName "\\\\$" ZipName
        }
        return $ZipName
    }

    proc Parse_Inherit {line} {
        #get bash variables
        set thelist -1
        regexp "^\[ \t]*inherit\[ \t]*(.*)$" $line xx thelist
        return $thelist
    }

    #Get bash variable value
    proc GetValue {var} {
        global xbashvar xbashlocalvar
        foreach {var1 value} $xbashlocalvar { if {$var == $var1} {return $value} }
        foreach {var1 value} $xbashvar { if {$var == $var1} {return $value} }
        return ""
    }

    proc SetVar {VarName Value} {
        global xbashvar
        if {$Value == ""} return
        set ind [lsearch -exact $xbashvar $VarName]
        if {$ind == -1} {
            set xbashvar [linsert $xbashvar end $VarName $Value]
        } else {
            set xbashvar [lreplace $xbashvar [expr $ind+1] [expr $ind+1] $Value]
        }
    }

    proc ParseVariable {{str ""}} {
        global xbashvar xbashlocalvar gPkgZipName gline gDebug_NewVariable
        #get bash variables
        set my_gline $gline
        if {$str != ""} {set my_gline $str}
        if {[regexp "^\[ \t]*\[A-Za-z0-9\_\-]+=" $my_gline]} {
            if {$str == ""} { 
                set line2 [lindex [::String::BashLine2TclList $my_gline] 0] 
            } else {
                set line2 $my_gline
            }
            regsub -all "\\\\\{" $line2 "\{" line2
            regsub -all "\\\\\}" $line2 "\}" line2
            if {[regexp "^(\[A-Za-z0-9\_\-]+)=(.*)$" $line2 dummy Variable Value]} {
                if {$Variable == "S"} {regsub "^\\$\\{?WORKDIR\\}?/$gPkgZipName/" $Value "" Value}
                if {$Variable == "S"} {regsub "^\\$\\{?WORKDIR\\}?/$gPkgZipName" $Value "" Value}
                if {$Variable == "S"} {regsub "^\\$\\{?WORKDIR\\}?/" $Value "" Value}
                if {$Variable == "S"} {regsub "^\\$\\{?WORKDIR\\}?" $Value "" Value}
                regexp "^\'(.*)\'$" $Value xx Value

                set Value [::bash::PutBashVarValue $Value]

                if {$Variable == "SRC_URI"} {
                    set Value2 $Value
                    while {[regsub -all "(^|\[ \t])\[^ \t]+/" $Value2 "\\1" Value2]} {}
                    set ind [lsearch -exact $xbashvar "A"]
                    if {$gDebug_NewVariable} {puts "A <-> $Value2"}
                    if {$ind == -1} {
                        set xbashvar [linsert $xbashvar end "A" $Value2]
                    } else {
                        set xbashvar [lreplace $xbashvar [expr $ind+1] [expr $ind+1] $Value2]
                    }
                }

                #Unknown Value
                if {[regexp "\\$\\(.*" $Value]} {
                    if {[string length $Value] > 25} {
                        ::cache::Add "# Unknown Variable: $Variable = $Value"
                        set Value "~~unknown~~"
                    }
                }
                #local function variables
                set ind [lsearch -exact $xbashlocalvar $Variable]
                if {$ind != -1} {
                    set xbashlocalvar [lreplace $xbashlocalvar [expr $ind+1] [expr $ind+1] $Value]
                    if {$gDebug_NewVariable} {puts "LOC: $Variable <--> $Value"}
                    return
                }
                set ind [lsearch -exact $xbashvar $Variable]
                if {$gDebug_NewVariable} {puts "$Variable <-> $Value"}
                if {$ind == -1} {set xbashvar [linsert $xbashvar end $Variable $Value]; return}
                set xbashvar [lreplace $xbashvar [expr $ind+1] [expr $ind+1] $Value]
            }
        }
    }

    proc ParseFunctionDefinition {} {
        global xFunctionDefinitions gline gDebug_ShowFunctionDef
        set Body ""
        if {[regexp "^\[ \t]*(\[^ \t]+)\[ \t]*\\(\\)\[ \t]*\{\[ \t]*$" $gline dummy FunctionName]} {
            while { [::ebuild::GetNewLine] >= 0 } {
                if {[regexp "^\[ \t]*$" $gline]} continue
                if {[regexp "^\[ \t]*\}" $gline]} break
                set Body [linsert $Body end $gline]
            }
            if {$gDebug_ShowFunctionDef} { puts "\[33mFunction <$FunctionName> :\[0m $Body" }
            set xFunctionDefinitions [linsert $xFunctionDefinitions end $FunctionName $Body]
        }
    }

    #Support output rediretion and piping..
    proc CheckFunctionSeperators {line} {
        global gCommandLineList gFunctionSepList gFuncInd
        set gCommandLineList [::String::BashLine2TclList $line]
        set gFunctionSepList [lsearch -all -regexp $gCommandLineList "(^\\|\\|$|^\\&\\&$|^;$)"]
        set gFuncInd 0
    }

    proc GetNextFunction {} {
        #line string list
        global gCommandLineList
        #function end points
        global gFunctionSepList 
        #current function point
        global gFuncInd
        global gRet

        ::cache::StatusGet
        set sep ""

        if {$gFuncInd == 0} {
            set a 0
        } else {
            if {[lindex $gFunctionSepList [expr $gFuncInd-1]] == ""} {return "~~-1~~"}
            set a [expr "[lindex $gFunctionSepList [expr $gFuncInd-1]]+1"]
            set sep [lindex $gCommandLineList [lindex $gFunctionSepList [expr $gFuncInd-1]]]
        }
        set b [expr "[lindex $gFunctionSepList $gFuncInd]-1"]
        if {[lindex $gFunctionSepList $gFuncInd] == ""} {set b "end"}
        set gFuncInd [expr "1+$gFuncInd"]

        ::cache::StatusUpdate

        if {$sep == "\&\&" && $gRet == 0} {return "~~-1~~"}
        if {$sep == "\|\|" && $gRet == 1} {return "~~-1~~"}

        #skip unimportant functions..
        if {[regexp "^(die|ewarn|einfo|eerror|ebegin|eend|enewuser|enewgroup)$" [lindex $gCommandLineList $a]]} {
            return [GetNextFunction]
        }

        return [lrange $gCommandLineList $a $b]
    }

    #Puts bash variable's value
    proc PutBashVarValue {line} {
        global xbashvar xbashlocalvar
        set ddd $line

        set bashvarlist "$xbashvar $xbashlocalvar"

        regsub "^\\$\\{?S\\}?/" $line "" line
        regsub "^\\$\\{?S\\}?" $line "" line
        regsub "^\\$\\{?DISTDIR\\}?/" $line "" line
        regsub "^\\$\\{?DISTDIR\\}?" $line "" line
        regsub "^\\$\\{?FILESDIR\\}?/" $line "" line
        regsub "^\\$\\{?FILESDIR\\}?" $line "" line
        regsub "^\\$\\{?WORKDIR\\}?/" $line "" line
        regsub "^\\$\\{?WORKDIR\\}?" $line "" line

        foreach {var value} $bashvarlist {
            if {$value == "~~unknown~~"} continue
            #1) Simply put the value
            if {[regexp " " $value]} {
                regsub -all "=\\$\\{$var\\}" $line "=\"$value\"" line
            }
            regsub -all "\\$\\{$var\\}" $line "$value" line
            # PARAMETER SUBSTITUTION
            #2) Ignore Default values
            regsub -all "\\$\\{$var:?(-|=)\[^\\}\\{]+\\}" $line "$value" line
            #3) ${parameter+alt_value}
            while {1} {
                if {[regexp "^(.*)\\$\\{$var:?\\+(\[^\\}\\{]+)\\}(.*)$" $line xx x1 x2 x3]} {
                    set line "$x1$x2$x3"
                } else break
            }
            #4) ${var:pos:len}
            while {1} {
                if {[regexp "^(.*)\\$\\{$var:(\[^:a-zA-Z]+):(\[^:a-zA-Z]+)\\}(.*)$" $line xx x1 x2 x3 x4]} {
                    set line "$x1[string range $value $x2 [expr $x2+$x3-1]]$x4"
                } else break
            }
            #5) ${var:pos}
            while {1} {
                if {[regexp "^(.*)\\$\\{$var:(\[^:a-zA-Z]+)\\}(.*)$" $line xx x1 x2 x3]} {
                    set line "$x1[string range $value $x2 end]$x3"
                } else break
            }
            #6) ${var/pattern/replacement}
            while {1} {
                if {[regexp "^(.*)\\$\\{$var/(\[^/\\}\\{%]*)/(\[^/\\}\\{%]*)\\}(.*)$" $line xx x1 x2 x3 x4]} {
                    regsub {\-} $x2 {\\-} x2
                    regsub {\-} $x3 {\\-} x3
                    regsub $x2 $value $x3 value2
                    set line "$x1$value2$x4"
                } else break
            }
            #7) ${var//pattern/replacement}
            while {1} {
                if {[regexp "^(.*)\\$\\{$var//(\[^/\\}\\{%]*)/(\[^/\\}\\{%]*)\\}(.*)$" $line xx x1 x2 x3 x4]} {
                    regsub {\-} $x2 {\\-} x2
                    regsub {\-} $x3 {\\-} x3
                    regsub -all $x2 $value $x3 value2
                    set line "$x1$value2$x4"
                } else break
            }
            #8) $(Myfunctions)
            regsub -all "@" $line "~~ed~~" line
            regsub -all "#" $line "~~slash~~" line
            regsub -all "(^|\[^\\\\])\\$\\(" $line "\\1@" line
            regsub -all "(\[^\\\\])\\)" $line "\\1#" line
            while {1} {
                if {[regexp "^(.*)@(\[^@]+)#(.*)$" $line xx x1 x2 x3]} {
                    regsub -all "~~ed~~" $x2 "@" x2
                    regsub -all "~~slash~~" $x2 "#" x2
                    set xx [::ebuild2pisi::RunCodeBlock "\{[::String::BashLine2TclList $x2]\}"]
                    if {[::cache::GetUnknownCF]} {
                        set line "$x1\$\($x2\)$x3"
                    } else {
                        set line "$x1$xx$x3"
                    }
                } else break
            }
            regsub -all "@" $line "\$\(" line
            regsub -all "#" $line "\)" line
            regsub -all "~~ed~~" $line "@" line
            regsub -all "~~slash~~" $line "#" line
            #9) `Myfunctions`
            while {1} {
                if {[regexp "^(\[^`]*)`(\[^`]+)`(.*)$" $line xx x1 x2 x3]} {
                    set xx [::ebuild2pisi::RunCodeBlock "\{[::String::BashLine2TclList $x2]\}"]
                    if {[::cache::GetUnknownCF]} {
                        set line "$x1~~@qu~~$x2~~@qu~~$x3"
                    } else {
                        set line "$x1$xx$x3"
                    }
                } else break
            }
            regsub -all "~~@qu~~" $line "`" line
        }

        #Simply put values
        foreach {var value} $bashvarlist { regsub -all "\\$[set var](\[^A-Za-z0-9\_\-]|$)" $line "$value\\2" line }

        return $line
    }

    proc GetFunctionBody {FunctionName} {
        global xFunctionDefinitions
        foreach {FunctionName1 Body} $xFunctionDefinitions { if {$FunctionName == $FunctionName1} {return $Body} }
        return ""
    }

    proc IsFunctionDefined {FunctionName} {
        global xFunctionDefinitions
        if {$FunctionName == "epatch"} {return 0}
        foreach {FunctionName1 Body} $xFunctionDefinitions { if {$FunctionName == $FunctionName1} {return 1}}
        return 0
    }
}