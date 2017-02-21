# -*- coding: utf-8 -*-
#
# Licensed under the GNU General Public License, version 2.
# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

proc PutMessageLightBlue {msg} {
    puts "\[36m* $msg\[0m"
}

proc PutMessagePink {msg} {
    puts "\[35m* $msg\[0m"
}

proc PutMessageBlue {msg} {
    puts "\[34m* $msg\[0m"
}

proc PutMessageBrown {msg} {
    puts "\[33m* $msg\[0m"
}

#normal print function...
proc PutMessage {msg} {
    puts "\[32m* $msg\[0m"
}

#printing error...
proc PutErrorMessage {msg} {
    puts "\[31m$msg\[0m"
}

#printing error...
proc PutMessageRed {msg} {
    puts "\[31m$msg\[0m"
}

#Check if package is available...
proc IsPackageAvailable {a} {
    global xPackages
    if {[lsearch $xPackages $a] != -1} {return 1}
    return 0
}
#Create component.xml file
proc CreateComponentXML {} {
    if {[catch {glob component.xml}]} {
        set fh [open "component.xml" "w"]
        puts $fh "<PISI>
  <Name>Pilonga</Name>
  <LocalName xml:lang=\"tr\">Pilonga paketleri</LocalName>
  <Summary xml:lang=\"tr\">Pilonga paketleri</Summary>
  <Description xml:lang=\"tr\">...</Description>
</PISI>"
        close $fh
    }
}