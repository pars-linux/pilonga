# -*- coding: utf-8 -*-
#
# Licensed under the GNU General Public License, version 2.
# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

namespace eval ::help {
    #checks option '-h' and shows help...
    proc ShowHelp {} {
        global ARG_Help ARG_Version env
        if {$ARG_Version == 1} {
            puts "** Pilonga Version 2.0"
        }
        if {$ARG_Help == 1} {
            if {[regexp "^tr" $env(LANG)]} {
                puts " Kullanım: pilonga \[SEÇENEK]... \[PROGRAM İSMİ]...

 Verilen program isminin ebuild dosyasını seceneklere göre Gentoo-Portage
 sitesinden indirir ve bu dosyayı pisi dosyalarına cevirir.

 Seçenekler:
  --version             : Programın versiyon numarasını göster ve çık
  -h \[--help]           : Bu yardım mesajını göster ve çık

 Genel Seçenekler:
  -d \[--destdir] pathname : Dosyaların kaydedileceği dizinini değiştir
  -f \[--ebuild-file] arg : Ebuild dosyasının direkt adresini al
  -nw \[--no-window]       : Bitimde Konqueror penceresi açma
  -np \[--no-patch-download] : Yamaları yükleme
  -nd \[--no-dependency-check] : Bağımlılıkları kontrol etme
  -nm \[--no-menu] : Gentoo sitesindeki mevcut versiyonları listeleme

  Örnekler:
   Birden çok paket aynı anda indirilip çevrilebilinir:
       > pilonga gaim gimp krita
   Ofline olarak bir ebuild dosyası parametre olarak verilebilinir:
       > pilonga -f ./gaim-2.0.0_beta6.ebuild
"
            } else {
                puts " Usage: pilonga \[OPTION]... \[PROGRAM NAME]...

 Download ebuild file from Gentoo-Portage and convert ebuild file to pisi files.

 Options
  --version              : Show version number.
  -h \[--help]           : Show this help

 General Options:
  -d \[--destdir] pathname : Change the path
  -f \[--ebuild-file] arg : Get ebuild file directly
  -nw \[--no-window]       : Don't open Konqueror window
  -np \[--no-patch-download] : Don't download any patch
  -nd \[--no-dependency-check] : Don't check dependencies (Turkish lang. only)
  -nm \[--no-menu] : Don't list versions available in Gentoo-Portage

  Examples:
   We can convert more than one package at the same time:
       > pilonga gaim gimp krita
   We can convert ebuild file as an offline without connecting gentoo portage:
       > pilonga -f ./gaim-2.0.0_beta6.ebuild
"
            }
        }
    }
}