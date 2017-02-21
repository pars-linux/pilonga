# -*- coding: utf-8 -*-
#
# Licensed under the GNU General Public License, version 2.
# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

#Creating pspec.xml and action.py

namespace eval ::pisi_action {
    #create actions.py
    proc Create {} {
        global xPatch xsetup xbuild xinstall xkde xconfopt xWorkDir

        PutMessage [format "[uplevel #0 {set MSG_saving}]" "[pwd]/actions.py"]

        set xsetup [::pisi_action::Normalization $xsetup]
        set xbuild [::pisi_action::Normalization $xbuild]
        set xinstall [::pisi_action::Normalization $xinstall]

        set fh [open "actions.py" "w"]

        puts $fh "#!/usr/bin/python"
        puts $fh "# -*- coding: utf-8 -*-"
        puts $fh "#"
        puts $fh "# Licensed under the GNU General Public License, version 2."
        puts $fh "# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt\n"

        if {[regexp " kde\." "$xsetup$xbuild$xinstall"]} {puts $fh "from pisi.actionsapi import kde"}
        if {[regexp " autotools\." "$xsetup$xbuild$xinstall"]} {puts $fh "from pisi.actionsapi import autotools"}
        if {[regexp " pisitools\." "$xsetup$xbuild$xinstall"]} {puts $fh "from pisi.actionsapi import pisitools"}
        if {[regexp " shelltools\." "$xsetup$xbuild$xinstall"]} {puts $fh "from pisi.actionsapi import shelltools"}
        if {[regexp " get\." "$xsetup$xbuild$xinstall"]} {puts $fh "from pisi.actionsapi import get"}

        if { $xWorkDir != "" } {
            puts $fh  "\nWorkDir = $xWorkDir"
        }

        puts $fh ""
        if {$xsetup != ""} {
            puts $fh "def setup():"
            puts $fh "$xsetup"
        }
        if {$xbuild != ""} {
            puts $fh "def build():"
            puts $fh "$xbuild"
        }
        puts $fh "def install():"
        puts $fh "$xinstall"

        close $fh

        uplevel #0 {PutMessage "[format $MSG_saving action.py]"}
    }

    proc Normalization {a} {
        regsub -all "autotools.make\\(\"\"\\)" $a "autotools.make\(\)" a
        regsub -all "autotools.make\\(\\).?.?.?.?    autotools.make\\(\\)" $a "autotools.make\(\)" a
        return $a
    }
}