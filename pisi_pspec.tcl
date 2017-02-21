# -*- coding: utf-8 -*-
#
# Licensed under the GNU General Public License, version 2.
# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

#Creating pspec.xml and action.py

namespace eval ::pisi_pspec {
    #create pspec
    proc Create {} {
        global geName geVersion geSuffix geSuffixVer geRevision xDescription xHomepage xDependency xRDependency xLicense xSourcePath xPatch

        set Suffix ""
        if {$geSuffix != ""} {set Suffix "-$geSuffix"}

        PutMessage [format "[uplevel #0 {set MSG_saving}]" "[pwd]/pspec.xml"]

        set ZipType ""
        set d1 "gz"
        regexp "tar.(..?.?.?)$" $xSourcePath Dummy d1
        set ZipType "tar$d1"

        set fh [open "pspec.xml" "w"]

        puts $fh "<?xml version=\"1.0\" ?>
<!DOCTYPE PISI
      SYSTEM \"http://www.pardus.org.tr/projeler/pisi/pisi-spec.dtd\">
<PISI>
    <Source>
        <Name>$geName</Name>
        <Homepage>$xHomepage</Homepage>
        <Packager>
            <Name>Pilonga</Name>
            <Email>pilonga@pilonga.com</Email>
        </Packager>
        <License>$xLicense</License>
        <IsA>[::pisi_pspec::PutIsA]</IsA>
        <Summary>$xDescription</Summary>
        <Description>$xDescription</Description>
        <Archive sha1sum=\"\" type=\"$ZipType\">$xSourcePath</Archive>"
        if {$xDependency != ""} {
            puts $fh "        <BuildDependencies>"
            foreach {Name Version} $xDependency {
                if { $Version == "-" } {
                    puts $fh "            <Dependency>$Name</Dependency>"
                } else {
                    puts $fh "            <Dependency versionFrom=\"$Version\">$Name</Dependency>"
                }
            }
            puts $fh "        </BuildDependencies>"
        }
        if {$xPatch != ""} {
            puts $fh "        <Patches>"
            foreach {Patch} $xPatch { puts $fh "            <Patch level=\"1\">$Patch</Patch>" }
            puts $fh "        </Patches>"
        }
        puts $fh "    </Source>

    <Package>
        <Name>$geName</Name>"
        if {$xRDependency != ""} {
            puts $fh "        <RuntimeDependencies>"
            foreach {Name Version} $xRDependency { 
                if { $Version == "-" } {
                    puts $fh "            <Dependency>$Name</Dependency>"
                } else {
                    puts $fh "            <Dependency versionFrom=\"$Version\">$Name</Dependency>"
                }
            }
            puts $fh "        </RuntimeDependencies>"
        }
        puts $fh "        <Files>
            <Path fileType=\"executable\">/usr/bin</Path>
            <Path fileType=\"library\">/usr/lib</Path>
            <Path fileType=\"data\">/usr/share</Path>
        </Files>
    </Package>

    <History>
        <Update release=\"1\">
            <Date>[clock format [clock seconds] -format %Y-%m-%d]</Date>
            <Version>$geVersion$Suffix</Version>
            <Comment>First release.</Comment>
            <Name>Pilonga</Name>
            <Email>pilonga@pilonga.com</Email>
        </Update>
    </History>
</PISI>"
        close $fh
        uplevel #0 {PutMessage "[format $MSG_saving pspec.xml]"}
    }

    proc PutIsA {} {
        global xDescription

        if {[regexp -nocase "library" $xDescription]} {return "library"}
        if {[regexp -nocase "locale" $xDescription]} {return "locale"}
        if {[regexp -nocase "deamon" $xDescription]} {return "deamon"}
        if {[regexp -nocase "plugin" $xDescription]} {return "plugin"}
        if {[regexp -nocase "console" $xDescription]} {return "console"}
        if {[regexp -nocase "kernel" $xDescription]} {return "kernel"}
        if {[regexp -nocase "service" $xDescription]} {return "service"}
        if {[regexp -nocase "font" $xDescription]} {return "data:font"}
        if {[regexp -nocase "doc" $xDescription]} {return "data:doc"}
        if {[regexp -nocase "data" $xDescription]} {return "data"}
        if {[regexp -nocase "devel" $xDescription]} {return "devel"}
        if {[regexp -nocase "client" $xDescription]} {return "app:cli"}
        if {[regexp -nocase "gui" $xDescription]} {return "app:gui"}
        if {[regexp -nocase "game" $xDescription]} {return "applications:games"}
        if {[regexp -nocase "util" $xDescription]} {return "console"}
        return "app:gui"
    }
}