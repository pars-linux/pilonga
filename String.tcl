# -*- coding: utf-8 -*-
#
# Licensed under the GNU General Public License, version 2.
# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

# Functions to convert bash script line to TCL list

namespace eval ::String {
    #Converts bash script line to TCL List!!!
    proc BashLine2TclList {str} {
        regsub -all "~" $str "\\~" str
        regsub -all "\{" $str "~~@brace-o~~" str
        regsub -all "\{" $str "~~@brace-o~~" str
        regsub -all "\}" $str "~~@brace-c~~" str
        regsub -all "\\\\\"" $str "~~@marking~~" str
        while {[regexp "\'" $str]} {
            if {[regexp "(^|^.*\[^\\\\])\'(\[^']*\[^\\\\])?\'(.*)$" $str xx x1 x2 x3]} {
                regsub -all "\"" $x2 "~~@marking-p~~" x2
                regsub -all "\[ \t]" $x2 "~~@spaceortab~~" x2
                regsub -all ";" $x2 "~~@semicomma~~" x2
                regsub -all "\\&\\&" $x2 "~~@and~~" x2
                regsub -all "\\|\\|" $x2 "~~@or~~" x2
                regsub -all "\\\\" $x2 "~~@slash~~" x2
                regsub -all "\\)" $x2 "~~@op2~~" x2
                regsub -all "\\$\\(" $x2 "~~@op1~~" x2
                set str "$x1~~@qua~~$x2~~@qua~~$x3"
                continue
            }
            break
        }
        while {[regexp "\"" $str]} {
            if {[regexp "(^\[^\"]*\[ \t]|^)\"\"(\[ \t].*$|$)" $str xx x1 x2]} {
                set str "$x1~~@emptystr~~$x2"
            }
            if {[regexp "^(\[^\"]*)(\"\[^\"]*;\[^\"]*\")(.*)$" $str xx x1 x2 x3]} {
                regsub -all ";" $x2 "~~@semicomma~~" x2
                set str "$x1$x2$x3"
            }
            if {[regexp "^(\[^\"]*)(\"\[^\"]*\\&\\&\[^\"]*\")(.*)$" $str xx x1 x2 x3]} {
                regsub -all "\\&\\&" $x2 "~~@and~~" x2
                set str "$x1$x2$x3"
            }
            if {[regexp "^(\[^\"]*)(\"\[^\"]*\\|\\|\[^\"]*\")(.*)$" $str xx x1 x2 x3]} {
                regsub -all "\\|\\|" $x2 "~~@or~~" x2
                set str "$x1$x2$x3"
            }
            if {[regexp "^(\[^\"]*)(\"\[^\"]*\[ \t]\[^\"]*\")(.*)$" $str xx x1 x2 x3]} {
                regsub -all "\[ \t]" $x2 "~~@spaceortab~~" x2
                set str "$x1$x2$x3"
            }
            if {[regexp "^(\[^#]*) #" $str xx x1]} {
                set str "$x1"
            }
            if {[regexp "^(\[^\"]*)\"(\[^\"]*)\"(.*)$" $str xx x1 x2 x3]} {
                set str "$x1$x2$x3"
            }
            if {[regexp "^(\[^\"]*)\"(\[^\"]*)$" $str xx x1 x2]} {
                set str "$x1$x2"
            }
        }
        regsub -all "\\|\\|" $str " \|\| " str
        regsub -all "\\&\\&" $str " \& " str
        regsub -all ";" $str " ; " str
        regsub -all "(\[^ \t])\[ \t]+(\[^ \t])" $str "\\1 \\2" str
        regsub -all "^\[ \t]+(\[^ \t])" $str "\\1" str
        regsub -all "(\[^ \t])\[ \t]+$" $str "\\1" str
        regsub -all "\[ \t]\[ \t]" $str " " str
        regsub -all " " $str "\} \{" str
        regsub -all "~~@spaceortab~~" $str " " str
        regsub -all "~~@emptystr~~" $str "" str
        regsub -all "~~@marking~~" $str "\\\\\"" str
        regsub "^(.*)$" $str "{\\1}" str
        while {[regsub -all "({.*\\$\\(\[^\\)]*)} {(\[^\\)]*\\).*})" $str "\\1 \\2" str]} {continue}
        while {[regsub -all "( {\\\[\\\[\[^\]]*)} {(\[^\]]*\]\]} )" $str "\\1 \\2" str]} {continue}
        regsub -all "\\\\" $str "~~@slash~~" str
        set str2 ""
        foreach ind "$str" {
            regsub -all "~~@marking-p~~" $ind "\"" ind
            regsub -all "~~@brace-o~~" $ind "\\\\\{" ind
            regsub -all "~~@brace-c~~" $ind "\\\\\}" ind
            regsub -all "~~@semicomma~~" $ind ";" ind
            regsub -all "~~@and~~" $ind "\&\&" ind
            regsub -all "~~@or~~" $ind "\|\|" ind
            regsub -all "~~@slash~~" $ind "\\" ind
            regsub -all "~~@op2~~" $ind "\\)" ind
            regsub -all "~~@op1~~" $ind "\\$\\(" ind
            regsub -all "~~@qua~~" $ind "\'" ind
            regsub -all "\\\\~" $ind "~" ind
            set str2 [linsert $str2 end $ind]
        }
        return $str2
    }
}
