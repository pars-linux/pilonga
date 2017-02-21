# -*- coding: utf-8 -*-
#
# Licensed under the GNU General Public License, version 2.
# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

#Dependecy reporting feature..

global gPackagesAlreadyInstalled gPackagesAvailableInDepo gPackagesNeedsToBeUpdated gPackagesNotAvailable

namespace eval ::dependency {
    # CheckDependencies
    proc Check {} {
        global gPackagesAlreadyInstalled gPackagesAvailableInDepo gPackagesNeedsToBeUpdated gPackagesNotAvailable
        global ARG_NoDependencyCheck env
        global xDependency xRDependency

        set BuildDep $xDependency
        set RunTimeDep $xRDependency

        if {$ARG_NoDependencyCheck} return
        if {![regexp "^tr" $env(LANG)]} return

        PutMessage "bagımlılıklar kontrol ediliyor..."
        foreach {Dep Ver} $RunTimeDep {
            if {[lsearch $BuildDep $Dep] == -1} {set BuildDep "$BuildDep $Dep $Ver"}
        }
        set gPackagesAlreadyInstalled ""
        set gPackagesAvailableInDepo ""
        set gPackagesNeedsToBeUpdated ""
        set gPackagesNotAvailable ""
        set a ""
        foreach {package version} $BuildDep {
            if { [catch {set a [eval exec pisi info $package]}] == -1} {
                return 0
            }
            if {$a == ""} {return 0}
            #Sorry, for the time being, it is written for Turkish output :)
            if {[regexp "Yüklü paket:.?.?.?.?Ad: \[^,]*, versiyon (\[^,]*), sürüm" $a dummy version1]} {
                if {[CompareVersions $version1 $version] > -1} {
                    set gPackagesAlreadyInstalled "$gPackagesAlreadyInstalled $package"
                } else {
                    if {[regexp "Paket depoda bulundu:.?.?.?.?Ad: \[^,]*, versiyon (\[^,]*), sürüm" $a dummy version2]} {
                        if {[CompareVersions $version2 $version] > -1} {
                            set gPackagesAvailableInDepo "$gPackagesAvailableInDepo $package"
                        } else {
                            set gPackagesNeedsToBeUpdated "$gPackagesNeedsToBeUpdated $package"
                        }
                    }
                }
                continue
            }
            if {[regexp "Paket depoda bulundu:.?.?.?.?Ad: \[^,]*, versiyon (\[^,]*), sürüm" $a dummy version2]} {
                if {[CompareVersions $version2 $version] > -1} {
                    set gPackagesAvailableInDepo "$gPackagesAvailableInDepo $package"
                } else {
                    set gPackagesNeedsToBeUpdated "$gPackagesNeedsToBeUpdated $package"
                }
                continue
            }
            set gPackagesNotAvailable "$gPackagesNotAvailable $package"
        }
        return 1
    }
    #Availlable Packages
    proc AlreadyInstalledPackages {} {
        global gPackagesAlreadyInstalled
        if {$gPackagesAlreadyInstalled != ""} {
            puts "\[33mYüklü paketler:\[0m $gPackagesAlreadyInstalled"
        }
    }
    #Install these packages
    proc PackagesAvailableInDepo {} {
        global gPackagesAvailableInDepo
        if {$gPackagesAvailableInDepo != ""} {
            puts "\[33mDepoda mevcut paketler:\[0m $gPackagesAvailableInDepo"
        }
    }
    #Update Pisi for them :)
    proc PackagesNeedsToBeUpdated {} {
        global gPackagesNeedsToBeUpdated
        if {$gPackagesNeedsToBeUpdated != ""} {
            puts "\[33mGüncellenmesi gereken paketler:\[0m $gPackagesNeedsToBeUpdated"
        }
    }
    #Not Available Packages. Create Pisi for them :)
    proc PackagesNotAvailable {} {
        global gPackagesNotAvailable
        if {$gPackagesNotAvailable != ""} {
            puts "\[33mMevcut olmayan paketler:\[0m $gPackagesNotAvailable"
        }
    }
    proc Report {} {
        global ARG_NoDependencyCheck env
        if {$ARG_NoDependencyCheck} return
        if {![regexp "^tr" $env(LANG)]} return
        AlreadyInstalledPackages
        PackagesAvailableInDepo
        PackagesNeedsToBeUpdated
        PackagesNotAvailable
    }
    # Compare Versions
    proc CompareVersions {version1 version2} {
        regsub -all "\[\_\\-\.]" $version1 " " version1
        regsub -all "\[\_\\-\.]" $version2 " " version2
        set ind 0
        while {1} {
            set v1 [lindex $version1 $ind]
            set v2 [lindex $version2 $ind]
            #puts "<$v1> <$v2>"
            if {$v1 == "" || $v2 == ""} {
                if {$v1 != ""} {
                    if {[regexp "^\[a-zA-Z]" $v1]} {return -1}
                    return 1
                }
                if {$v2 != ""} {
                    if {[regexp "^\[a-zA-Z]" $v2]} {return 1}
                    return -1
                }
                return 0
            }
            incr ind
            if {$v1 > $v2} { return 1 }
            if {$v1 < $v2} { return -1 }
        }
    }
    proc Normalization {Dependency} {
        set c ""
        foreach {a b} $Dependency {
            if { $a == "gtk+" && $b == "2.0"} { set a gtk2 ; set b "-" }
            if { $a == "glib" && $b == "2.0"} { set a glib2 ; set b "-" } else {
                if { $a == "glib" && [regexp "^2" $b]} { set a glib2 } 
            }
            if { $a == "gtk+" } { set a gtk2 }
            if { $a == "tk" } { set a tcltk }
            if { $a == "x11" } { set a "xorg-server" }
            if {![CheckSystemBase $a]} continue
            set c [concat $c $a $b]
        }
        return $c
    }

    proc CheckSystemBase {Dependency} {
        if {[lsearch -exact "acl
attr baselayout bash bc bzip2 comar comar-api coolplug coreutils cpio cracklib curl db1 db3 db4 debianutils dhcpcd diffutils e2fsprogs expat fbgrab file findutils flex freetype gawk gdbm gettext glib2 glibc grep groff groff-utf8 grub gzip hdparm iputils jpeg kbd klibc less lib-compat libidn libpcre libpng libusb lzma man man-pages memtest86 mingetty miscfiles mkinitramfs module-init-tools mudur nano ncompress ncurses net-tools nss-mdns openssh openssl pam parted pciutils pcmciautils perl piksemel pisi popt procps psmisc pwdb pyparted python python-bsddb3 python-fchksum readline sed shadow slang splash-theme splashutils splashutils-misc sysfsutils sysklogd sysvinit tar tcp-wrappers texinfo time udev unzip usbutils util-linux vixie-cron which wireless-tools zip zlib apr apr1 apr-util apr-util1 autoconf2_13 autoconf2_59 autoconf-wrapper automake1_4 automake1_5 automake1_6 automake1_7 automake1_8 automake1_9 automake-wrapper binutils bison catbox ccache cmake gcc gnuconfig icecream intltool libtool m4 make nasm patch pkgconfig scons subversion swig unifdef yacc" $Dependency] == -1} {return 1}
        #puts $Dependency
        PutMessage "Dependency $Dependency found in system base"
        return 0
    }

    proc GetDependencies {DependencyStr} {
        set MyDependency ""
        set Action 0
        regsub -all "\[ \t]+" $DependencyStr "  " DependencyStr
        regsub -all "\\( +" $DependencyStr "\(" DependencyStr
        regsub -all " +\\)" $DependencyStr "\)" DependencyStr
        regsub -all "\\? +" $DependencyStr "?___" DependencyStr
        set DependencyStr2 $DependencyStr
        regsub -all "(^| |\\()\[^\\(\\) ]+\?___\\(\[^\\(\\) ]+\\)(\\)| |$)" $DependencyStr2 "\\1~\\2" DependencyStr2
        regsub -all "(^| |\\()\[^\\(\\) ~]+(\\)| |$)" $DependencyStr2 "\\1~\\2" DependencyStr2
        while {[regexp "^(.* )(\[^\\(\\) ]+)\\?___\\((\[^\\(\\)]+)\\)( .*$)" $DependencyStr2 xx x1 x2 x3 x4]} {
            set DependencyStr2 "$x1$x3$x4"
            regsub -all "~" $x3 "\\\[^ \]+" MyRegExp
            set MyRegExp "^(.* )$x2\\\\?___\\\\(($MyRegExp)\\\\)( .*)$"
            eval "regexp \"$MyRegExp\" \$DependencyStr dd d1 d2 d3"
            set Action [regsub "^!" $x2 "" x2]
            if {$Action == [use $x2]} {
                set DependencyStr "$d1$d3"
            } else {
                set DependencyStr "$d1$d2$d3"
            }
        }
        foreach {str} $DependencyStr {
            set Condition ""
            if {[regexp "^(\[^\\(]*)\\?___\\(?(\[^\\)]*)\\)?$" $str Dummy Condition str]} {
                set Action [regsub "^!" $Condition "" Condition]
                if {$Action == [use $Condition]} continue
            }
            if {[regexp ">=.*/(.*)$" $str Dummy Dependency]} {
                if {[regexp "^(.*)-(\[0-9]\[^ \"-]*)" $Dependency Dummy DependencyName DependencyVersion]} {
                    set MyDependency [linsert $MyDependency end $DependencyName $DependencyVersion]
                }
            } elseif {[regexp "./(\[0-9a-zA-Z_\-]*)$" $str Dummy DependencyName] } {
                set MyDependency [linsert $MyDependency end $DependencyName -]
            }
        }
        return [::dependency::Normalization $MyDependency]
    }
}