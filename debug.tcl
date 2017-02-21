# -*- coding: utf-8 -*-
#
# Licensed under the GNU General Public License, version 2.
# See the file http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

global gDebug_ShowFunctionLine gDebug_ShowLineByLine gDebug_NewVariable gDebug_ShowFunctionDef gDebug_PrintLocalVar
global gDebug_Profil gDebug_PrintCache

set gDebug_ShowFunctionLine 1
set gDebug_ShowLineByLine   0
set gDebug_NewVariable      0
set gDebug_ShowFunctionDef  0
set gDebug_PrintLocalVar    0

set gDebug_Profil           1
set gDebug_PrintCache       1


proc PrintLocalVar {FunctionName} {
    global gDebug_PrintLocalVar xbashlocalvar
    if {$gDebug_PrintLocalVar == 0} return
    puts "LOCALVAR $FunctionName : $xbashlocalvar"
}

proc PrintgLine {} {
    global gDebug_ShowLineByLine gline
    if {$gDebug_ShowLineByLine == 0} return
    puts "$gline"
}