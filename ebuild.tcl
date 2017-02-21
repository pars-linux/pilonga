# -*- coding: utf-8 -*-
#
# Licensed under the GNU General Public License, version 2.
# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

# Functions related to parsing the ebuild file...
global gfh gline

namespace eval ::ebuild {

    proc OpenEbuildFile {} {
        global gfh gEbuildFile
        set gfh [open $gEbuildFile "r+"]
    }

    proc CloseEbuildFile {} {
        global gfh
        close $gfh
    }

    proc GotoStartPos {} {
        global gfh
        seek $gfh 0 start
    }

    #TODO
    proc CopyAndOpenEclassFile {Eclass} {
        global gfh gpwd
        catch {file copy "$gpwd/eclass/$Eclass\.eclass" "$Eclass.eclass"}

        if {[catch {set gfh [open "$Eclass.eclass" "r+"]}]} {
           #puts warning message
           PutErrorMessage [format "[uplevel #0 {set MSG_eclass_not_found}]" "$Eclass\.eclass"]
           return 0
        }

        PutMessage [format "[uplevel #0 {set MSG_eclass_parsing}]" "$Eclass\.eclass"]
        return 1
    }

    proc CloseEclassFile {} {
        global gfh
        close $gfh
    }

    # Gets next bash command string!!
    proc GetNewLine {} {
        global gfh gline
        set gline ""
        while {1} {
            set Res [gets $gfh gline]
            set line $gline
            #pass the comments
            if {[regexp "^\[ \t]*#" $gline]} continue
            # Combine lines for DEPEND=..... RDEPEND=..... BOTH_DEPEND=..... SRC_URI=....
            if {[regexp "(^|\[^\\\\])\"" $gline]} {
                set line $gline
                regsub -all "\\\\\"" $line "~~marking2~~" line
                while {1} {
                    if {[regexp "(^|^\[^\']*\[^\\\\])\'(\[^']*\[^\\\\])?\'(.*)$" $line xx x1 x2 x3]} {
                        regsub -all "\"" $x2 "~~marking~~" x2
                        regsub -all "\\)" $x2 "~~op2~~" x2
                        regsub -all "\\$\\(" $x2 "~~op1~~" x2
                        set line "$x1~~qua~~$x2~~qua~~$x3"
                        continue
                    }
                    if {[regexp "^(.*)\\$\\((\[^\\)]*)\\)(.*)$" $line xx x1 x2 x3]} {
                        regsub -all "^\[ \t]*~~newline~~" $x2 "" x2
                        regsub -all "~~newline~~\[ \t]*$" $x2 "" x2
                        regsub -all "~~newline~~" $x2 ";" x2
                        regsub -all "#" $x2 "~~sharp~~" x2
                        set line "$x1~~op1~~$x2~~op2~~$x3"
                        continue
                    }
                    if {[regexp "(^|^\[^\"]*\[^\"\\\\])\"(\[^\"]*\[^\"\\\\])?\"(.*)$" $line xx x1 x2 x3]} {
                        regsub -all "#" $x2 "~~sharp~~" x2
                        set line "$x1~~marking~~$x2~~marking~~$x3"
                        continue
                    }
                    if {[regexp "^(\[^\"]*)\[ \t]*#.*$" $line]} {
                        regsub "^(\[^\"]*)\[ \t]*#.*$" $line "\\1" line
                    }
                    if {[regexp "(^|\[^\\\\])\"" $line]} {
                        set Res [gets $gfh gline]
                        if {[regsub "\\\\\[ \t]*$" $line "" line]} {
                            set line "$line $gline"
                        } else {
                            set line "$line ~~newline~~ $gline"
                        }
                        if {$Res >= 0} continue
                    }
                    break
                }
                regsub -all "~~sharp~~" $line "#" line
                regsub -all "~~newline~~" $line " " line
                regsub -all "~~marking~~" $line "\"" line
                regsub -all "~~op1~~" $line "\$\(" line
                regsub -all "~~op2~~" $line "\)" line
                regsub -all "~~qua~~" $line "\'" line
                set gline $line
            }
            regsub -all "~~marking2~~" $gline "\\\\\"" gline

            # Combine lines for  '\'
            if {[regexp "\\\\\[ \t]*$" $gline]} {
                regsub "\\\\\[ \t]*$" $gline "" gline
                regsub -all "\[ \t]+" $gline " " gline
                set line $gline
                while {1} {
                    set Res [gets $gfh gline]
                    set Res2 [regexp "\\\\\[ \t]*$" $gline]
                    if {[regexp "^\[ \t]*#" $gline]} continue
                    regsub "\\\\\[ \t]*$" $gline "" gline
                    regsub -all "\[ \t]+" $gline " " gline
                    set line "$line $gline"
                    regsub -all "\[ \t]\[ \t]" $line " " line
                    if {$Res < 0} {set gline $line; PrintgLine; return 1}
                    if {!$Res2} {set gline $line; PrintgLine; return 1}
                }
            }

            # Combine lines for "cat <<-END > ... END"
            if {[regexp "cat\[ \t].*<<.?.?END.*$" $gline]} {
                regsub "<<.?.?END.*$" $gline "\"~~Deleted Entry By Pilonga~~\"" gline
                while {1} {
                    set Res [gets $gfh line]
                    if {$Res < 0} {PrintgLine; return 1}
                    if {[regexp "END" $line]} {PrintgLine; return 1}
                }
            }

            if {$Res < 0 } {set gline ""; PrintgLine; return $Res}
            break
        }
        PrintgLine
        return $Res
    }
}