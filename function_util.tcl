# -*- coding: utf-8 -*-
#
# Licensed under the GNU General Public License, version 2.
# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

namespace eval ::func {

    proc FunctionAvailable {flist} {
        global gDebug_ShowFunctionLine
        if {$gDebug_ShowFunctionLine} { PutMessageLightBlue $flist }
        if {[IsAvailable $flist]} {return 1}
        if {[regexp "^(cd|mv|touch|export|local|unset|e?make|econf|mkdir|rm|insinto|into|exeinto|diropts|exeopts|insopts|libopts|docinto|dohard|doinfo|doins|doexe|dosym|newconfd|newinitd|doconfd|doinitd|dobin|dohtml|doman|newman|newdoc|newbin|dosbin|newins|newexe|dodir|\./configure|dodoc|dolib(\.a|\.so)?|newlib(\.a|\.so)?|sed|epatch|ln|chmod|.*=.*|if)$" [lindex $flist 0]]} { 
            return 1
        }
        return 0
    }

    #Run Bash Function
    proc RunFunction {flist} {
        global xPatch xbashlocalvar  xbashvar xsetup xbuild xinstall
        global gRet gline
        set gRet 1
        #puts "<[lindex $flist 0]>"
        switch -regexp ">[lindex $flist 0]" {
            "^>cd$" {
                  set d2 [ArgsNF $flist 1]
                  if {$d2 != "" && $d2 != "./" &&  $d2 != "/"} {
                      ::cache::Add "shelltools.cd([PAA $d2])"
                  }
            }
            "^>mv$" {
                  set d1 [ArgsNF $flist 1]
                  if {$d1 != "" && $d1 != "./" &&  $d1 != "/"} {
                      set d1 [PAA $d1]
                      set d2 [PAA [ArgsNF $flist 2]]
                      if {$d1 != $d2} {
                          ::cache::Add "pisitools.domove($d1,$d2)"
                      }
                  }
            }
            "^>touch$" {
                  ::cache::Add "shelltools.touch([PAA [ArgsNF $flist all ]])"
            }
            "^>export$" {
                  if {[regexp "^\{?(\[a-zA-Z0-9_-]+)=(.*)$" [ArgsNFWithoutGet $flist 1] dummy d1 d2]} {
                      regsub -all "^\"" $d2 "" d2; regsub -all "\"$" $d2 "" d2
                      ::cache::Add "shelltools.export([PAA $d1],[PAA [PVWG $d2]])"
                  }
            }
            "^>local$" {
                  #Get local variable
                  regsub "," $flist "" flist
                  if {[ArgsNFWithoutGet $flist 1] == ""} return
                  if {[regexp "^\{?(\[a-zA-Z0-9_-]+)=(.*)$" [ArgsNFWithoutGet $flist 1] dummy d1 d2]} {
                      regsub -all "^\"" $d2 "" d2; regsub -all "\"$" $d2 "" d2
                  } else {
                      set d1 [ArgsNFWithoutGet $flist 1]
                      set d2 ""
                  }
                  #Unknown Value
                  if {[regexp "\\$\\(.*" $d2]} { set d2 "~~unknown~~" }

                  set ind [lsearch -exact $xbashlocalvar $d1]
                  if {$ind == -1} {
                      set xbashlocalvar [linsert $xbashlocalvar end $d1 $d2]
                  } else {
                      incr ind
                      set xbashlocalvar [lreplace $xbashlocalvar $ind $ind $d2]
                  }
                  RunFunction [ArgNFDelete $flist 1]
            }
            "^>unset$" {
                  set ind [lsearch -exact $xbashvar [ArgsNF $flist 1]]
                  if {$ind != -1} { set xbashvar [lreplace $xbashvar $ind [expr $ind+1]] }
            }
            "^>e?make$" {
                  if {[ArgGetFlagValue $flist "C"] != ""} {RunFunction "cd [ArgGetFlagValue $flist C]"}
                  set flist [ArgDeleteFlagAndItsValue $flist "C f I l o W"]
                  if {[eval regexp "install" \{$flist\}]} {
                      if {[eval regexp \"DESTDIR=\" \{$flist\}]} {
                          set flist "[ArgDeleteReg $flist DESTDIR=]"
                          set flist "[ArgDeleteReg $flist install]"
                          set flist "$flist DESTDIR=~get.installDIR~"
                          ::cache::Add "autotools.rawInstall([LLE 26 [PAA [ArgsNF $flist all]]])"
                      } else {
                          ::cache::Add "autotools.Install()"
                      }
                  } else {
                      ::cache::Add "autotools.make([LLE 20 [PAA [ArgsNF $flist all]]])"
                      set xbuild $xbuild[::cache::Get]
                  }
            }
            "^>econf$" {
                  if {[eval regexp \"(--)(prefix|.*dir)=\" \{$flist\}]} {
                      ::cache::Add "autotools.rawConfigure([LLE 28 [PAA [CPM [Args $flist]]]])"
                  } else {
                      ::cache::Add "autotools.configure([LLE 25 [PAA [Args $flist]]])"
                  }
                  set xsetup $xsetup[::cache::Get]
            }
            "^>mkdir$" {
                  set flist [ArgDeleteFlagAndItsValue $flist "m"]
                  if {[set d2 [ArgsNF $flist 1]] != ""} {
                      foreach dir [OpenBashList $d2] {
                          ::cache::Add "shelltools.dodir([PAA $dir])"
                      }
                  }
            }
            "^>rm$" {
                  ::cache::Add "shelltools.remove([LLE 23 [PAA [OpenBashList [ArgsNF $flist all ]]]])"
            }
            "^>insinto$" {
                  ::bash::SetVar "INSDESTTREE" [ArgsNFWithoutGet $flist 1]
            }
            "^>exeinto$" {
                  ::bash::SetVar "EXEDESTTREE" [ArgsNFWithoutGet $flist 1]
            }
            "^>into$" {
                  ::bash::SetVar "DESTTREE" [ArgsNFWithoutGet $flist 1]
            }
            "^>diropts$" {
                  ::bash::SetVar "~diropts~" [ArgGetFlagValueC $flist m]
            }
            "^>exeopts$" {
                  ::bash::SetVar "~exeopts~" [ArgGetFlagValueC $flist m]
            }
            "^>insopts$" {
                  ::bash::SetVar "~insopts~" [ArgGetFlagValueC $flist m]
            }
            "^>libopts$" {
                  ::bash::SetVar "~libopts~" [ArgGetFlagValueC $flist m]
            }
            "^>docinto$" {} "^>dohard$" {} "^>doinfo$" {}
            "^>doins$" {
                  foreach dir [OpenBashList [ArgsNFWithoutGet $flist 1]] {
                      ::cache::Add "pisitools.insinto([PAA [::bash::GetValue INSDESTTREE]],[PAA $dir])"
                      if { [::bash::GetValue "~insopts~"] != "0644" } {
                          regsub -all "//" "[::func::FS installDIR]/[::bash::GetValue INSDESTTREE]/$dir" "/" d
                          ::cache::Add  "shelltools.chmod([PAA $d],[PAA [::bash::GetValue ~insopts~]])"
                      }
                  }
            }
            "^>doexe$" {
                  foreach dir [OpenBashList [ArgsNFWithoutGet $flist 1]] {
                      ::cache::Add "pisitools.doexe(\"$dir\",\"[::bash::GetValue EXEDESTTREE]\")"
                      if { [::bash::GetValue "~exeopts~"] != "0755" } {
                          regsub -all "//" "[::func::FS installDIR]/[::bash::GetValue EXEDESTTREE]/$dir" "/" d
                          ::cache::Add  "shelltools.chmod([PAA $d],[PAA [::bash::GetValue ~exeopts~]])"
                      }
                  }
            }
            "^>dosym$" {
                  set d1 [ArgsNF $flist 1]
                  if {$d1 != "" && $d1 != "./" &&  $d1 != "/"} {
                      set d1 [PAA $d1]
                      set d2 [PAA [ArgsNF $flist 2]]
                      if {$d1 != $d2} {
                          ::cache::Add "pisitools.dosym($d1,$d2)"
                      }
                  }
            }
            "^>newconfd$" {} "^>newinitd$" {} "^>doconfd$" {} "^>doinitd$" {}
            "^>dobin$" {
                  foreach dir [OpenBashList [ArgsNFWithoutGet $flist all]] {
                      ::cache::Add "pisitools.dobin([PAA $dir])"
                  }
            }
            "^>dohtml$" {
                  ::cache::Add "pisitools.dohtml([ArgsNFWithoutGetCommaSep $flist])"
            }
            "^>doman$" {
                  ::cache::Add "pisitools.doman([ArgsNFWithoutGetCommaSep $flist])"
            }
            "^>newman$" {} "^>newdoc$" {} "^>newbin$" {}
            "^>dosbin$" {
                  foreach dir [OpenBashList [ArgsNFWithoutGet $flist all]] {
                      ::cache::Add "pisitools.dosbin([PAA $dir])"
                  }
            }
            "^>newins$" {
                  ::cache::Add "pisitools.insinto([PAA [::bash::GetValue INSDESTTREE]],[PAA [ArgsNFWithoutGet $flist 1]], [PAA [ArgsNFWithoutGet $flist 2]])"
            }
            "^>newexe$" {
                      ::cache::Add "pisitools.domove([PAA [ArgsNFWithoutGet $flist 1]],[PAA [ArgsNFWithoutGet $flist 2]])"
                      RunFunction "doexe [ArgsNFWithoutGet $flist 2]"
            }
            "^>dodir$" {
                  set d1 [ArgsNF $flist 1]
                  if {$d1 != "" && $d1 != "./" &&  $d1 != "/" && \
                      ![regexp "^/(usr|s?bin|lib|local)?(/(lib|usr|local))?/?$" $d1]} {
                      if { [::bash::GetValue "~diropts~"] != "0755" } {
                          ::cache::Add  "shelltools.chmod([PAA [ArgsNFWithoutGet $flist 1]],[PAA [::bash::GetValue ~diropts~]])"
                      }
                      ::cache::Add "pisitools.dodir([PAA [ArgsNFWithoutGet $flist 1]])"
                  }
            }
            "^>\./configure$" {
                  ::cache::Add "autotools.rawConfigure([PAA [Args $flist]])"
            }
            "^>dodoc$" {
                  ::cache::Add "pisitools.dodoc([ArgsNFWithoutGetCommaSep $flist])"
            }
            "^>dolib(\.a|\.so)?$" {
                  foreach dir [OpenBashList [ArgsNFWithoutGet $flist all]] {
                      if { [::bash::GetValue "~libopts~"] != "0644" } {
                          ::cache::Add  "shelltools.chmod(\"%s$dir\" % get.installDIR(),\"[::bash::GetValue ~libopts~]\")"
                      }
                      regsub -all "//" "[::bash::GetValue DESTTREE]/lib" "/" destination
                      if {$destination != "/usr/lib" } { 
                          set destination ",\"$destination\""
                      } else {
                          set destination ""
                      }
                      regsub "\\." [lindex $flist 0] "_" fname
                      ::cache::Add "pisitools.$fname\(\"$dir\"$destination)"
                  }
            }
            "^>newlib(\.a|\.so)?$" {
                  regsub "^new" [lindex $flist 0] "do" fname
                  ::cache::Add "pisitools.domove([PAA [ArgsNFWithoutGet $flist 1]],[PAA [ArgsNFWithoutGet $flist 2]])"
                  RunFunction "$fname [ArgsNFWithoutGet $flist 2]"
            }
            "^>sed$" {
                  set escripts [ArgGetAllFlagValue $flist "e"]
                  set flist [ArgDeleteAllFlagAndItsValue $flist "e f l"]
                  foreach my_script $escripts {
                      if {[regexp "s,(.*\[^\\\\]),(.*),g" $my_script xx x1 x2]} {
                          ::cache::Add "pisitools.dosed([PAA [ArgsNF $flist 1]],\"$x1\",\"$x2\")"
                      }
                  }
            }
            "^>epatch$" {
                  ::bash::SetVar PATCHES "[::bash::GetValue PATCHES] [ArgsNFWithoutGet $flist 1]"
            }
            "^>ln$" {
                  ::cache::Add "pisitools.dosym([PAA [ArgsNF $flist 1]],[PAA [ArgsNF $flist 2]])"
            }
            "^>chmod$" {
                  ::cache::Add  "shelltools.chmod([PAA [ArgsNF $flist 2]],\"[ArgsNFWithoutGet $flist 1]\")"
            }
            "^>.*=.*$" {
                  ::bash::ParseVariable [lindex $flist 0]
            }
            "^>if$" {
                  RunFunction [lrange $flist 1 end]
            }
            "^!$" {
                  RunFunction [lrange $flist 1 end]
                  if {$gRet} {
                      set gRet 0
                  } else {
                      set gRet 1
                  }
            }
            default {
                  #predefined functions <predefined_functions.tcl>
                  return [RunMe $flist]
            }
        }
        return ""
    }

    proc Args {functionlist} {
        set Ret [lrange $functionlist 1 end]
        set Ret [TCLlist2StringList $Ret]
        set Ret [PutVariablesWithGet $Ret]
        regsub "//" $Ret "/" Ret
        return $Ret
    }

    proc ArgsNF {functionlist n} {
        set Ret [lrange $functionlist 1 end]
        set Ret [FilterFlags $Ret]
        if {$n != "all"} { set Ret [lindex "[lindex $functionlist 0] $Ret" $n] }
        set Ret [TCLlist2StringList $Ret]
        set Ret [PutVariablesWithGet $Ret]
        regsub "//" $Ret "/" Ret
        return  $Ret
    }

    proc ArgsNFWithoutGet {functionlist n} {
        set Ret [lrange $functionlist 1 end]
        set Ret [FilterFlags $Ret]
        if {$n != "all"} { set Ret [lindex "[lindex $functionlist 0] $Ret" $n] }
        set Ret [TCLlist2StringList $Ret]
        set Ret [::bash::PutBashVarValue $Ret]
        regsub "//" $Ret "/" Ret
        return  $Ret
    }

    proc ArgsNFWithoutGetCommaSep {functionlist} {
        set Ret [lrange $functionlist 1 end]
        set Ret [FilterFlags $Ret]
        set Ret [::bash::PutBashVarValue [TCLlist2StringList $Ret]]
        set Ret [OpenBashList $Ret]
        regsub "//" $Ret "/" Ret
        regsub -all "\"? \"?" $Ret "\",\"" Ret
        regsub -all "^\"?" $Ret "\"" Ret; regsub -all "\"$" $Ret "" Ret; regsub -all "$" $Ret "\"" Ret;
        return $Ret
    }

    proc ArgGetFlagValue {flist flag} {
        set Ind 0
        while {1} {
            if {[lindex $flist $Ind] == ""} {return ""}
            if {[lindex $flist $Ind] == "-$flag"} {
                set Ind [expr "$Ind+1"]
                return [lindex $flist $Ind]
            }
            set Ind [expr "$Ind+1"]
        }
    }

    proc ArgGetFlagValueC {flist flag} {
        set Ind 0
        while {1} {
            if {[lindex $flist $Ind] == ""} {return ""}
            if {[regexp "(-$flag)(.*)" [lindex $flist $Ind] xx x1 Ret]} {
                return $Ret
            }
            set Ind [expr "$Ind+1"]
        }
    }

    proc ArgDeleteFlagAndItsValue {flist FlagList} {
        foreach flag $FlagList {
            set Ind 0
            while {1} {
                if {[lindex $flist $Ind] == ""} {break}
                if {[lindex $flist $Ind] == "-$flag"} {
                    set flist [lreplace $flist $Ind [expr "$Ind+1"] ]
                    break
                }
                incr Ind
            }
        }
        return $flist
    }

    proc ArgDeleteReg {flist RegExp} {
        set Ind 0
        while {1} {
            if {[lindex $flist $Ind] == ""} {break}
            if {[regexp $RegExp [lindex $flist $Ind]]} {
                set flist [lreplace $flist $Ind $Ind]
                break
            }
            incr Ind
        }
        return $flist
    }

    proc ArgNFDelete {flist Num} {
        set mylist ""
        set flist [FilterFlags $flist]
        catch {[set mylist [lreplace $flist $Num $Num]]}
        if {[ArgsNFWithoutGet $mylist 1] == ""} return
        return $mylist
    }

    proc ArgGetAllFlagValue {flist flag} {
        set Ind 0
        set MyList ""
        while {1} {
            if {[lindex $flist $Ind] == ""} {return $MyList}
            if {[lindex $flist $Ind] == "-$flag"} {
                set Ind [expr "$Ind+1"]
                set MyList "$MyList [lindex $flist $Ind]"
            }
            set Ind [expr "$Ind+1"]
        }
    }

    proc ArgDeleteAllFlagAndItsValue {flist FlagList} {
        foreach flag $FlagList {
            set Ind 0
            while {1} {
                if {[lindex $flist $Ind] == ""} {break}
                if {[lindex $flist $Ind] == "-$flag"} {
                    set flist [lreplace $flist $Ind [expr "$Ind+1"] ]
                    continue
                }
                set Ind [expr "$Ind+1"]
            }
        }
        return $flist
    }

    proc FilterFlags {functionlist} {
        set Ind 0
        set MyList ""
        while {1} {
            if {[lindex $functionlist $Ind] == ""} {return $MyList}
            if {[regexp "^\[^-]" [lindex $functionlist $Ind]]} {
                set MyList [linsert $MyList end [lindex $functionlist $Ind]]
            }
            set Ind [expr "$Ind+1"]
        }
        return $MyList
    }

    proc LLE {Ind str} {
        set qua "\""
        regexp "^(.)" $str xx qua
        regsub "^($qua)? +(\[^ ])" $str "\\1\\2" str
        set x1 $str
        set x2 ""
        regexp "($qua)(.*\[^\\\\])($qua)(.*)$" $str xx xxx x1 xxx x2
        set Len [string length $x1]
        if {$Len < 40} {return $str}
        set MyInd [string range "                                         " 1 $Ind]
        while {[regsub -all "  " $x1 " " x1]} {}
        regsub -all " " $x1 " \\\\\n$MyInd" x1
        while {[regsub -all "(\\$\\(\[^\\)]*) \\\\\n$MyInd ?(\[^\\)]*\\))" $x1 "\\1 \\2" x1]} {}
        return "$qua$x1$qua$x2"
    }

    proc OpenBashList {mylist} {
        set Ret ""
        foreach str $mylist {
            set Ret "$Ret [OpenBashList_ $str]"
        }
        regsub "^ +(\[^ ])" $Ret "\\1" Ret
        regsub "(\[^ ]) +$" $Ret "\\1" Ret
        return $Ret
    }

    proc OpenBashList_ {str} {
        set oldstr $str
        set str [regsub "(^| )(\[^ ]*)\{(\[^,\}]*),(\[^,\}]*)\}(.*)$" $str "\\1\\2\\3\\5 \\1\\2\\4\\5"]
        set str [regsub "(^| )(\[^ ]*)\{(\[^,\}]*),(\[^\}]*\})(.*)$" $str "\\1\\2\\3\\5 \\1\\2\{\\4\\5"]
        if {$str != $oldstr} {return [OpenBashList_ $str]}
        return $str
    }

    proc TCLlist2StringList {TCLlist} {
        set Ret ""
        foreach Str $TCLlist {
            set Ret "$Ret $Str"
        }
        regsub "^ " $Ret "" Ret
        regsub -all "\\\\\{" $Ret "\{" Ret
        regsub -all "\\\\\}" $Ret "\}" Ret
        return $Ret
    }

    proc CPM {pList} {
        if {![SearchList $pList "^--localstatedir"]} {
            set pList "--localstatedir=[FS localstateDIR] $pList"
        }
        if {![SearchList $pList "^--sysconfdir"]} {
            set pList "--sysconfdir=[FS confDIR] $pList"
        }
        if {![SearchList $pList " --datadir"]} {
            set pList "--datadir=[FS dataDIR] $pList"
        }
        if {![SearchList $pList "^--infodir"]} {
            set pList "--infodir=[FS infoDIR] $pList"
        }
        if {![SearchList $pList "^--mandir"]} {
            set pList "--mandir=[FS manDIR] $pList"
        }
        if {![SearchList $pList "^--build"]} {
            set pList "--build=[FS HOST] $pList"
        }
        if {![SearchList $pList "^--prefix"]} {
            set pList "--prefix=[FS defaultprefixDIR] $pList"
        }
        return $pList
    }

    proc SearchList {functionlist Regexp} {
        set Ind 0
        while {1} {
            if {[lindex $functionlist $Ind] == ""} {return 0}
            if {[regexp $Regexp [lindex $functionlist $Ind]]} {
                return 1
            }
            set Ind [expr "$Ind+1"]
        }
        return 0
    }

    proc PVWG {a} {
        return [PutVariablesWithGet $a]
    }

    proc PutVariablesWithGet {a} {
        global geName
        regsub -all "\\$\{(MY_)?P\}" $a "$geName-[FS srcVERSION]" a
        regsub -all "\\$\{(MY_)?PV\}" $a "[FS srcVERSION]" a
        set a [::bash::PutBashVarValue $a]
        regsub -all "\\$\{CFLAGS\}" $a "[FS CFLAGS]" a
        regsub -all "\\$\{LDFLAGS\}" $a "[FS LDFLAGS]" a
        regsub -all "\\$\{CPPFLAGS\}" $a "[FS CXXFLAGS]" a
        regsub -all "\\$\{HOST\}" $a "[FS HOST]" a
        regsub -all "\\$\{HOST\}" $a "[FS CHOST]" a
        return $a
    }

    proc FS {Str} {
        set Str2 "$Str\------------------------"
        regexp "^(......................)" $Str2 xx Str
        return "~get.$Str~"
    }

    #Put Action API functions
    proc PAA {Str} {
        set REStr "~get.(srcVERSION|CFLAGS|LDFLAGS|CXXFLAGS|HOST|CHOST|AR|CC|CXX|LD|NM|RANLIB|F77|GCJ|defaultprefixDIR|manDIR|infoDIR|dataDIR|confDIR|localstateDIR|installDIR)-*~"
        if {[regsub -all "$REStr" $Str "%s" Str2]} {
            set Str3 ""
            while {[regexp "^(.*)[set REStr](.*)$" $Str dummy Str d xx]} {
                if {$Str3 != ""} {set Str3 "get.$d\(\), [set Str3]"}
                if {$Str3 == ""} {set Str3 "get.$d\(\)"}
            }
            if {$Str2 == "%s"} {return "$Str3"}
            return "\"$Str2\" % $Str3"
        }

        if {[regexp "\"" $Str]} {return "\'$Str\'"}

        return "\"$Str\""
    }
}