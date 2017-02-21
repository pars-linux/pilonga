# -*- coding: utf-8 -*-
#
# Licensed under the GNU General Public License, version 2.
# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

global gPreFunctionArgList
set gPreFunctionArgList {use 1 use_enable 1 use_enable 2 use_with 1 use_with 2 get_libdir 0 
tc-getAR 0 tc-getCC 0 tc-getCXX 0 tc-getLD 0 tc-getNM 0 tc-getRANLIB 0 tc-getF77 0 tc-getGCJ 0 test_flag 1}



proc IsAvailable {flist} {
    global gPreFunctionArgList
    set flength2 [expr "[llength $flist]-1"]
    set fname2 [lindex $flist 0]
    foreach {fname flength} $gPreFunctionArgList {
        if {$fname==$fname2 && $flength==$flength2} {return 1}
    }
    return 0
}

proc RunMe {flist} {
    global gPreFunctionArgList
    global gRet
    set gRet 1
    if {![IsAvailable $flist]} return ""
    set flength2 [expr "[llength $flist]-1"]
    set fname2 [lindex $flist 0]
    foreach {fname flength} $gPreFunctionArgList {
        if {$fname==$fname2 && $flength==$flength2} {return [eval "PreDefined_$flist"]}
    }
    return ""
}

proc use {x1} {
    global xbashvar gIUSEexception
    set IUSE [::bash::GetValue "IUSE"]
    if {[lsearch -exact $IUSE $x1] == -1} {
        return 0
    } else {
        if {[lsearch -exact $gIUSEexception $x1] == -1} {
            return 1
        } else {
            return 0
        }
    }
}

proc PreDefined_use {x1} {
    global gRet
    if {[use $x1]} {
        set gRet 1
    } else {
        set gRet 0
    }
}

proc PreDefined_test_flag {x1} {
    set gRet 1
    return "$x1"
}

proc PreDefined_use_enable {x1 {x2 ""}} {
    global xbashvar
    if {$x2 == ""} {set x2 $x1}
    set Action [regsub "^!" $x1 "" x1]
    if {$Action == [use $x1]} {
        return "--disable-$x2"
    } else {
        return "--enable-$x2"
    }
}

proc PreDefined_use_with {x1 {x2 ""}} {
    global xbashvar
    if {$x2 == ""} {set x2 $x1}
    set Action [regsub "^!" $x1 "" x1]
    if {$Action == [use $x1]} {
        return "--without-$x2"
    } else {
        return "--with-$x2"
    }
}

proc PreDefined_get_libdir {} {
    return "lib"
}

proc PreDefined_tc-getAR {} { return "[::func::FS AR]" }
proc PreDefined_tc-getCC {} { return "[::func::FS CC]" }
proc PreDefined_tc-getCXX {} { return "[::func::FS CXX]" }
proc PreDefined_tc-getLD {} { return "[::func::FS LD]" }
proc PreDefined_tc-getNM {} { return "[::func::FS NM]" }
proc PreDefined_tc-getRANLIB {} { return "[::func::FS RANLIB]" }
proc PreDefined_tc-getF77 {} { return "[::func::FS F77]" }
proc PreDefined_tc-getGCJ {} { return "[::func::FS GCJ]" }
