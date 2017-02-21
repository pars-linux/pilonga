if {[regexp "^tr" $env(LANG)]} {
    source lang/language_tr.tcl 
} else {
    source lang/language_en.tcl 
}
