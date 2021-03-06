
# Ce fichier contient toutes les procedures qui ont du etre developpees sur
# HPCAL (machine de calculs) et non sur pcjeff (machine de developpement).
# A terme ces procedures _doivent_ soit etre deplacer vers pcjeff, soit etre
# effacees, soit etre repeintes en orange exsangue du retour precoce du
# cheval Titude.

proc ssload {name num_lst {options ""}} {
    foreach num $num_lst {
	set frmt_num [format "%.3d" $num]
	sload ${name}${frmt_num} $options
    }
}

proc sszoom {name val num_lst} {
    foreach num $num_lst {
	set frmt_num [format "%.3d" $num]
	szoom ${name}${frmt_num} ${name}${frmt_num} $val
    }
}

proc opdisp {name} {
    set tau_lst "[lsort -decreasing [ginfo ${name}_taum* -list]] [lsort [ginfo ${name}_tau?p* -list]]"
    set h_lst "[lsort -decreasing [ginfo ${name}_hm* -list]] [lsort [ginfo ${name}_h?p* -list]]"
    set D_lst "[lsort -decreasing [ginfo ${name}_Dm* -list]] [lsort [ginfo ${name}_D?p* -list]]"
    set code [catch {eval "mdisp 2 2 {{$tau_lst} {$h_lst} {$D_lst}}"} result]
    if {$code != 0} {
	error $result $result
    }
    return $result
}

proc pdisp2 {name {q_lst ""}} {
    set completeLst {}
    if {$q_lst == ""} {
	return opdisp $name
    } else {
	set sigLst {}
	foreach q $q_lst {
	    set q_str [get_q_str $q]
	    set sigLst [lappend sigLst ${name}_tau${q_str}]
	}
	set completeLst [lappend completeLst ${sigLst}]
	set sigLst {}
	foreach q $q_lst {
	    set q_str [get_q_str $q]
	    set sigLst [lappend sigLst ${name}_h${q_str}]
	}
	set completeLst [lappend completeLst ${sigLst}]
	set sigLst {}
	foreach q $q_lst {
	    set q_str [get_q_str $q]
	    set sigLst [lappend sigLst ${name}_D${q_str}]
	}
	set completeLst [lappend completeLst ${sigLst}]
    }

    set code [catch {mdisp 2 2 ${completeLst}} result]
    if {$code != 0} {
	error $result $result
    }
    $result setColorsByList {darkgreen green darkcyan darkblue slateblue darkviolet violet}
    set itemList {}
    foreach value $q_lst {
	set itemList [lappend itemlist [list %c $value]]
    }
    eval $result setLabelsItemsByList $itemList
    ${result}gr0000 set_label {black "Z(a,q), q = "} allSigLabel
    ${result}gr0100 set_label {black "D(a,q), q = "} allSigLabel
    ${result}gr0001 set_label {black "H(a,q), q = "} allSigLabel
    return $result
}

proc adisp {name q} {
    set q_str [get_q_str $q]
    set tau_lst "[lsort [ginfo ${name}?_tau${q_str} -list]]"
    set h_lst "[lsort [ginfo ${name}?_h${q_str} -list]]"
    set D_lst "[lsort [ginfo ${name}?_D${q_str} -list]]"
    #eval "mdisp 2 2 {{$tau_lst} {$h_lst} {$D_lst}}"
    set code [catch {eval "mdisp 2 2 {{$tau_lst} {$h_lst} {$D_lst}}"} result]
    if {$code != 0} {
	error $result $result
    }
    $result setColorsByList {darkcyan darkblue slateblue darkviolet darkcyan darkblue slateblue darkviolet}
    #red darkblue black gold red darkblue black gold
    set itemList {}
    foreach value {-pi -3pi/4 -pi/2 -pi/4 0 pi/4 pi/2 3pi/2} {
	set itemList [lappend itemlist [list %c $value]]
    }
    eval $result setLabelsItemsByList $itemList
    ${result}gr0000 set_label {black "Z(a,q), q = $q,"} allSigLabel
    ${result}gr0100 set_label {black "D(a,q), q = $q,"} allSigLabel
    ${result}gr0001 set_label {black "H(a,q), q = $q,"} allSigLabel

    return $result
}

# slogx --
# usage: slogx signal1 signal2 [base]
#
#   transforms signal1 into signal2 just by computing log(x)
#   without doing anything on y.
#
# Parameters:
#   signal1   - Signal to treat   (y versus     x  ).
#   signal2   - resulting signal  (y versus log(x) ).
#   [base]    - real (computes log(x)/log(base)) 
#
# option:
#
# Return value:
#   None.


proc slogx {sig res {base "e"} } {
    if {$base == "e"} {
	set base [expr exp(1)]
    }    
    set y_lst [sgetlst $sig]
    set x0 [sgetx0 $sig] 
    set dx [sgetdx $sig]
    set size [ssize $sig]
    for {set i 0} {$i < $size} {incr i} {
	set x [expr $x0+$i*$dx]
	if {$x > 0} {
	    set logx [expr log($x)/log($base)]
	} else {
	    set logx 0
	}
	lappend x_lst $logx
    }
    screate $res 0 1 $y_lst -xy $x_lst
}

# slogx2 --
# usage: slogx2 signal string base
#
#   transforms signal into signal (named "string") just by computing
#   log(x)/log($base)
#   without doing anything on y. (see h2logh)
#
# Parameters:
#   signal1   - Signal to treat   (y versus     x             ).
#   signal2   - resulting signal  (y versus log(x)/log($base) ).
#
# Return value:
#   None.


proc slogx2 {sig {res ""} {base ""}} {
    if {$base == ""} {
	set base [expr exp(1)]
    }
    if {$res == ""} {
	set res log${sig}
    }
    sigloop $sig {
	if {$x > 0} {
	    # Don't remove [expr $x] !!
	    lappend xPosLst [expr log($x)/log($base)]
	    lappend yPosLst [expr $y]
	}
    }

    screate $res 0 1 $yPosLst -xy $xPosLst
}


# slogy --
# usage: slogy signal string
#
#   transforms signal into signal (named "string") just by computing log(y)
#   without doing anything on x. (see h2logh)
#
# Parameters:
#   signal1   - Signal to treat   (y      versus x  ).
#   signal2   - resulting signal  (log(y) versus x  ).
#
# Return value:
#   None.


proc slogy {sig {res ""} {baselog ""} } {
    if {$baselog == ""} {
	set baselog [expr exp(1)]
    }

    if {$res == ""} {
	set res log${sig}
    }
    sigloop $sig {
	if {$y > 0} {
	    # Don't remove [expr $x] !!
	    lappend xPosLst [expr $x]
	    lappend yPosLst [expr log($y)/log($baselog)]
	}
    }

    screate $res 0 1 $yPosLst -xy $xPosLst
}


# sloglog --
# usage: sloglog signal string
#
#   transforms signal into signal (named "string") by computing log(x)
#   and log(y).
#
# Parameters:
#   signal    - Signal to treat
#   string    - name of the result
#
# Return value:
#   None.


proc sloglog {sig {res ""}} {
    if {$res == ""} {
	set res loglog${sig}
    }
    sigloop $sig {
	if {$x > 0 & $y >0} {
	    # Don't remove [expr $x] !!
	    lappend xPosLst [expr log($x)]
	    lappend yPosLst [expr log($y)]
	}
    }

    screate $res 0 1 $yPosLst -xy $xPosLst
}

# sloglog10 --
# usage: sloglog10 signal string
#
#   transforms signal into signal (named "string") by computing log(x)
#   and log(y).
#
# Parameters:
#   signal    - Signal to treat
#   string    - name of the result
#
# Return value:
#   None.


proc sloglog10 {sig {res ""}} {
    if {$res == ""} {
	set res loglog${sig}
    }
    sigloop $sig {
	if {$x > 0 & $y >0} {
	    lappend xPosLst [expr log($x)/log(10)]
	    lappend yPosLst [expr log($y)/log(10)]
	}
    }

    screate $res 0 1 $yPosLst -xy $xPosLst
}

# sdivide --
# usage: sdivide signal1 signal2 string
#
#   computes signal1 divided by signal2 and put result into signal (named "string")
#   takes care of divide by zero.
#   Notes: signal1 and signal2 must have the same size.
#
# Parameters:
#   signal1   - 
#   signal2   - 
#   string    - result
#
# Return value:
#   None.
proc sdivide {sig1 sig2 {res ""} } {

    if {$res == ""} {
	set res divide_result
    }

    set y1Lst [sgetlst $sig1]
    set y2Lst [sgetlst $sig2]
    set tmp [expr [llength $sig1]-[llength $sig2]]
    if {!$tmp} {
	set xLst [sgetlst $sig1 -x]
	
	foreach x $xLst y1 $y1Lst y2 $y2Lst {
	    # Don't remove [expr $x] !!
	    lappend xPosLst [expr $x]
	    if {$y2} {
		lappend yPosLst [expr $y1/$y2]
	    } else {
		lappend yPosLst [expr 0]
	    }
	}
	screate $res 0 1 $yPosLst 
	#-xy $xPosLst
    } else {
	echo "the two signals must have the same size !!!"
    }
}

# smultx --
# usage: smultx signal1 signal2 float
#
#   transforms signal1 into signal2 just by multiplying x
#   by a scale factor param without doing anything on y.
#
# Parameters:
#   signal1   - Signal to treat   (y versus       x ).
#   signal2   - resulting signal  (y versus param*x ).
#   [base]    - real
#
# option:
#
# Return value:
#   None.


proc smultx {sig res {param 1} } {
    sigloop $sig {
	if {1} {
	    # Don't remove [expr $x] !!
	    lappend x_lst [expr $x*$param]
	    lappend y_lst [expr $y]
	}
    }
    llength $y_lst
    llength $x_lst
    screate $res 0 1 $y_lst -xy $x_lst
}

# smulty --
# usage: smulty signal1 signal2 float
#
#   transforms signal1 into signal2 just by multiplying y
#   by a scale factor param without doing anything on x.
#
# Parameters:
#   signal1   - Signal to treat   (y       versus  x ).
#   signal2   - resulting signal  (param*y versus  x ).
#   [base]    - real
#
# option:
#
# Return value:
#   None.


proc smulty {sig res {param 1} } {
    sigloop $sig {
	if {1} {
	    # Don't remove [expr $x] !!
	    lappend x_lst [expr $x]
	    lappend y_lst [expr $y*$param]
	}
    }
    llength $y_lst
    llength $x_lst
    screate $res 0 1 $y_lst -xy $x_lst
}

# srealloc --
# usage: srealloc signal string list1 list2
#
#   transforms signal into signal (named "string") by ...
#
# Parameters:
#   signal    - Signal to treat
#   string    - name of the result
#   list1     - list of number
#   list2     - list of number
#
# Return value:
#   None.

proc srealloc {sig {res ""} list1 list2} {
    if {$res == ""} {
	set res realloc${sig}
    }
    
    set zel [llength $list1]
    set sigsize [ssize $sig]

    set list1a [lreplace $list1 [expr $zel -1] [expr $zel -1]] 
    set list1b [lreplace $list1 0 0]
    set list2a [lreplace $list2 [expr $zel -1] [expr $zel -1]] 
    set list2b [lreplace $list2 0 0]
    echo $list1a
    echo $list1b

    #set i 0
    #set j 2570

    for {set v 0} {$v < $sigsize} {incr v} {
	set xy [sget $sig $v]
	set x [lindex $xy 1]
	set y [lindex $xy 0]
	foreach i $list1a j $list1b {
	    if { $x >= $i & $x < $j } {
		set n [lsearch $list1 $i]
		set k [lindex $list2a $n]
		set l [lindex $list2b $n]
		
		set pente [expr ($l-$k)*1.0/($j-$i)]
		set newx [expr $k + $pente * ($x - $i)]
		lappend xPosLst $newx
		lappend yPosLst $y
	    }
	}
    }
    screate $res 0 1 $yPosLst -xy $xPosLst
}



# mysderiv --
# usage: mysderiv signal str int
#
#   compute the (forward) derivative of signal_in using a convolution method.
#   puts it in signal_out
#
# Parameters:
#   signal      - Signal to treat
#   string      - name of the result (signal)
#   integer     - size
#
# mind the fact that signal_input size decreased !!!
#
# comment: it creates signals :
#  thebox    : rectangular shape 
#  deriv_box : 1 -1 shape (type sdisp deriv_box to see)
#                          or type sgetlst deriv_box)
# Return value:
#   None.

proc mysderiv {sig res size} {

    set x0 [sgetx0 $sig] 
    set dx [sgetdx $sig]
    set sig_size [ssize $sig]

    exprr thebox 0*x 0 [expr ${sig_size}-1] ${sig_size}
    for {set i 0} { $i < $size } {incr i} {
	sset thebox $i 1
    }

    exprr deriv_box 0*x 0 [expr ${sig_size}-1] ${sig_size}
    for {set i 0} { $i < $size } {incr i} {
	sset deriv_box $i 1
	sset deriv_box [expr ${size} + $i] -1
    }

    cv1dn $sig deriv_box _res -di -pe
    sputdx _res [sgetdx $sig]
    sputx0 _res [sgetx0 $sig]
    scomb _res _res x/[sgetdx _res]/($size*$size) _res
    scut _res $res [expr 2*$size-1] 0
    scut $sig new_$sig [expr $size - 1] $size 

    scopy new_$sig $sig
    delete new_$sig _res
}


# scutx --
# usage: scutx signal_in signal_out real real
#
#   extracts a piece of signal_in (between xmin and xmax) and
#   puts it in signal_out
#
# Parameters:
#   signal      - Signal to treat
#   string      - resulting signal
#   real        - xmin
#   real        - xmax
#
# Return value:
#   None.

proc scutx {sig res xMin xMax} {
    set y_lst [sgetlst $sig]
    set x0 [sgetx0 $sig] 
    set new_x0 [sgetx0 $sig] 
    set dx [sgetdx $sig]
    set size [ssize $sig]
    set first 0
    set last $size

    for {set i 0} {$i <= $size} {incr i} {
	set x [expr $x0+$i*$dx]
	if {$x >= $xMin} {
	    set first $i
	    set new_x0 $x
	    break;
	}
    }
    for {} {$i <= $size} {incr i} {
	set x [expr $x0+$i*$dx]
	if {$x > $xMax} {
	    set last [expr $i-1]
	    break;
	}
	lappend x_lst $x
    }
    set y_lst [lrange $y_lst $first $last]
    screate $res $new_x0 $dx $y_lst
}

# s2sp2 --
# usage: s2sp2 signal_in signal_out
#
#   power spectrum computation
#   signal_out is an XY signal:
#   y -> log(fft(signal_in)^2)
#   x -> log(k)
#
# Parameters:
#   signal_in   - Signal to treat.
#   signal_out  - resulting signal.
#
# Return value:
#   None.

proc s2sp2 {sig res} {
    gfft $sig __f
    sgfft2ri __f __rf __if
    scomb __rf __if log(x*x+y*y) __sp
    #scomb __rf __if (x*x+y*y) __sp
    #scomb __rf __if sqrt(x*x+y*y) __sp
    scutx __sp __sp 0.000001 10
    slogx __sp $res 2
    #scopy __sp $res
    delete __*
}

# gsload --
# usage: gsload name [ int ]
#
#    Load a list of signals that in curren.
#
# Parameters:
#   name        - Base name of files containing signals.
#   [ int ]     - Argument to szoom.
#
# Return value:
#   None.

proc gsload {name {zoom ""}} {
    set hist_lst [glob -nocomplain $name*]
    foreach file $hist_lst {
	sload $file $file -sw
	if {$zoom != ""} {
	    szoom $file $file $zoom
	}
    }
}

proc hload {{zoom ""}} {
    gsload h_mod $zoom
    gsload h_arg $zoom
    gsload h_max_mod $zoom
    gsload h_max_arg $zoom
    gsload h_max_line_mod $zoom
    gsload h_max_line_arg $zoom
}

proc all_hdisp {{lst ""}} {
    set result [hdisp 2 3 {h_mod h_max_mod h_max_line_mod h_arg h_max_arg h_max_line_arg} $lst]
    ${result}gr0000 set_label {black "Module -"} allSigLabel
    ${result}gr0001 set_label {black "Module (line) -"} allSigLabel
    ${result}gr0002 set_label {black "Module (max)  -"} allSigLabel
    ${result}gr0100 set_label {black "Argument -"} allSigLabel
    ${result}gr0101 set_label {black "Argument (line) -"} allSigLabel
    ${result}gr0102 set_label {black "Argument (max)  -"} allSigLabel
}

proc hdisp {nRows nLines nameLst {lst ""}} {
    set completeLst {}
    foreach name $nameLst {
	if {$lst == ""} {
	    set sigLst [ginfo $name* -list]
	} else {
	    set sigLst {}
	    foreach value $lst {
		set new_value [format "%.3d" $value]
		set sigLst [lappend sigLst ${name}${new_value}]
	    }
	}
	set completeLst [lappend completeLst ${sigLst}]
    }
    set code [catch {mdisp $nRows $nLines ${completeLst}} result]
    if {$code != 0} {
	error $result $result
    }
    $result setColorsByList {black red green blue yellow brown slateblue}
    set itemList {}
    foreach value $lst {
	set itemList [lappend itemlist [list %c $value]]
    }
    eval $result setLabelsItemsByList $itemList
    return $result
}

proc ps4 {name {psFileName out.ps}} {
    set fileId [open ${name}.fig w]

    puts $fileId "\#FIG 3.1"
    puts $fileId "Portrait"
    puts $fileId "Center"
    puts $fileId "Metric"
    puts $fileId "1200 2"
    puts $fileId "6 450 1920 8955 10845"
    puts $fileId "2 5 0 1 0 -1 0 0 -1 0.000 0 0 -1 0 0 5"
    puts $fileId "	0 ${name}_a1.ps"
    puts $fileId "	 4769 1942 8950 1942 8950 6310 4769 6310 4769 1942"
    puts $fileId "2 5 0 1 0 -1 0 0 -1 0.000 0 0 -1 0 0 5"
    puts $fileId "	0 ${name}_a0.ps"
    puts $fileId "	 494 1920 4675 1920 4675 6288 494 6288 494 1920"
    puts $fileId "2 5 0 1 0 -1 0 0 -1 0.000 0 0 -1 0 0 5"
    puts $fileId "	0 ${name}_a2.ps"
    puts $fileId "	 450 6460 4631 6460 4631 10828 450 10828 450 6460"
    puts $fileId "2 5 0 1 0 -1 0 0 -1 0.000 0 0 -1 0 0 5"
    puts $fileId "	0 ${name}_a3.ps"
    puts $fileId "	 4769 6460 8950 6460 8950 10828 4769 10828 4769 6460"
    puts $fileId "-6"
    puts $fileId "4 1 0 0 0 14 20 0.0000 4 240 1260 4725 1485 ${name}\001"

    close $fileId
    exec fig2dev -L ps ${name}.fig ${psFileName}
}

proc sna {} {
    set lst [ginfo *arg* -list]
    foreach sig $lst {
	snorm $sig
    }
}

proc snh {} {
    set lst [ginfo h_* -list]
    foreach sig $lst {
	snorm $sig
    }
}

proc calload {type zoom args} {
    foreach value $args {
	set fmtValue [format "%.3d" $value]
	set name calendos_${type}${fmtValue}
	iload $name
	if {$zoom > 1} {
	    izoom $name $name $zoom
	}
    }
}

proc calload2 {type zoom args} {
    foreach value $args {
	set fmtValue [format "%.3d" $value]
	set name calendos_${type}${fmtValue}
	iload $name
	if {$zoom > 1} {
	    izoom $name $name $zoom
	}
	icomb $name $name log(x+1) $name
    }
}

proc caldisp {type args} {
    foreach value $args {
	set fmtValue [format "%.3d" $value]
	set name calendos_${type}${fmtValue}
	iaff $name
    }
}

proc calprint {type filename width height item args} {
    set value [lindex $item 0]
    set xPos [lindex $item 1]
    set yPos [lindex $item 2]
    set fmtValue [format "%.3d" $value]
    set name calendos_${type}${fmtValue}
    i2eps $name $filename \
	    -size $width $height \
	    -pos $xPos $yPos \
	    -inv
    foreach item $args {
	set value [lindex $item 0]
	set xPos [lindex $item 1]
	set yPos [lindex $item 2]
	set fmtValue [format "%.3d" $value]
	set name calendos_${type}${fmtValue}
	i2eps $name $filename \
		-pos $xPos $yPos \
		-inv \
		-add
    }
    smeps2ps $filename
}

proc mycalprint {type zoom} {
    calload $type $zoom 0 10 20 30
    set pos [expr 550/$zoom]
    set size [expr 1066/$zoom]
    set x1 [expr (576-$size)/2]
    set x2 [expr (576-$size)/2+$pos]
    set y1 [expr (828-$size)/2]
    set y2 [expr (828-$size)/2+$pos]
    calprint $type cal_$type.ps \
	    576 828 \
	    "0  $x1 $y2" \
	    "10 $x2 $y2" \
	    "20 $x1 $y1" \
	    "30 $x2 $y1"
}

proc mycalprint2 {type zoom} {
    calload $type $zoom 0 5 10 15 20 25 30 35
    set pos [expr 550/$zoom]
    set size [expr 1066/$zoom]
    set x1 [expr (576-$size)/2]
    set x2 [expr (576-$size)/2+$pos]
    set y1 [expr (828-$size)/4]
    set y2 [expr (828-$size)/4+$pos]

    set y3 [expr (828-$size)/4+2*$pos]
    set y4 [expr (828-$size)/4+3*$pos]
    calprint $type cal_$type.ps \
	    576 828 \
	    "0  $x1 $y4" \
	    "5  $x2 $y4" \
	    "10 $x1 $y3" \
	    "15 $x2 $y3" \
	    "20 $x1 $y2" \
	    "25 $x2 $y2" \
	    "30 $x1 $y1" \
	    "35 $x2 $y1"
}

proc mycalprint3 {type zoom} {
    calload2 $type $zoom 0 5 10 15 20 25 30 35
    set pos [expr 550/$zoom]
    set size [expr 1066/$zoom]
    set x1 [expr (576-$size)/2]
    set x2 [expr (576-$size)/2+$pos]
    set y1 [expr (828-$size)/4]
    set y2 [expr (828-$size)/4+$pos]

    set y3 [expr (828-$size)/4+2*$pos]
    set y4 [expr (828-$size)/4+3*$pos]
    calprint $type cal_$type.ps \
	    576 828 \
	    "0  $x1 $y4" \
	    "5  $x2 $y4" \
	    "10 $x1 $y3" \
	    "15 $x2 $y3" \
	    "20 $x1 $y2" \
	    "25 $x2 $y2" \
	    "30 $x1 $y1" \
	    "35 $x2 $y1"
}

proc mycalprint4 {type zoom nR nL args} {
    eval "calload2 $type $zoom $args"
    set pos [expr 520/$zoom]
    set size [expr 1066/$zoom]

    set script "calprint $type cal_$type.ps 576 828"
    puts $script
    set y [expr (828-$size)/$nL+$nL*$pos]
    for {set j 0} {$j < $nL} {incr j} {
	set y [expr $y-$pos]
	set x [expr (576-$size)/$nR]
	for {set i 0} {$i < $nR} {incr i} {
	    set scaleNum [lindex $args [expr $i+$j*$nR]]
	    set script "$script \{$scaleNum $x $y\}"
	    set x [expr $x+$pos]
	}
    }
    eval $script
}

proc newcalprint {fileName zoom args} {
    set nL [llength $args]
    set nR 4
    set pos 130
    set imageScale [expr $zoom*0.25]

    eval "calload image $zoom $args"
    eval "calload max $zoom $args"
    eval "calload max_line $zoom $args"
    foreach scale $args {
	set num [format "%.3d" $scale]
	eload ../00/max$num e$num
    }

    catch {exec rm $fileName}

    set y [expr (828-$nL*$pos)/$nL+$nL*$pos]
    for {set j 0} {$j < $nL} {incr j} {
	set scale [lindex $args $j]
	set num [format "%.3d" $scale]
	set y [expr $y-$pos]
	set x [expr (576-$nR*$pos)/$nR]
	e2eps e$num $fileName -size 576 828 -scale 0.125 -pos $x $y -inv -add
	set x [expr $x+$pos]
	i2eps calendos_image$num $fileName -scale $imageScale -pos $x $y -inv -add
	set x [expr $x+$pos]
	i2eps calendos_max$num $fileName -scale $imageScale -pos $x $y -inv -add
	set x [expr $x+$pos]
	i2eps calendos_max_line$num $fileName -scale $imageScale -pos $x $y -inv -add
    }
    smeps2ps $fileName
    return
}

proc print1scale {fileName zoom scaleId args} {
    set nL 2
    set nR 2
    set pos 260
    set imageScale [expr $zoom*0.25]

    set num [format "%.3d" $scaleId]
    iload calendos_image$num
    if {[string compare $args "-log"] == 0} {
	icomb calendos_image$num calendos_image$num log(x+1) calendos_image$num
    }
    iload calendos_max$num
    iload calendos_max_line$num
    eload ../00/max$num e$num

    catch {exec rm $fileName}

    set y [expr (828-$nL*$pos)/$nL+$nL*$pos]
    set y [expr $y-$pos]
    set x [expr (576-$nR*$pos)/$nR]
    e2eps e$num $fileName -size 576 828 -scale 0.25 -pos $x $y -inv -add
    set x [expr $x+$pos]
    i2eps calendos_image$num $fileName -scale $imageScale -pos $x $y -inv -add
    set y [expr $y-$pos]
    set x [expr (576-$nR*$pos)/$nR]
    i2eps calendos_max$num $fileName -scale $imageScale -pos $x $y -inv -add
    set x [expr $x+$pos]
    i2eps calendos_max_line$num $fileName -scale $imageScale -pos $x $y -inv -add

    smeps2ps $fileName
    return
}

proc smeps2ps {filename} {
    set fileId [open $filename a]
    puts $fileId showpage
    close $fileId
}

proc foreachscale {scaleVarName scaleIdVarName aMin nOctave nVox bodyScript} {
    upvar $scaleVarName scale
    upvar $scaleIdVarName scaleId

    for {set oct 0;set num 0}\
	    { $oct < $nOctave} \
	    { incr oct } {
	for {set vox 0} \
		{ $vox < $nVox } \
		{ incr vox ; incr num} {
	    set scale [expr $aMin*pow(2,$oct+($vox/double($nVox)))]
	    set scale [expr $scale*(6/0.86)]
	    set scaleId [format "%.3d" $num]
	    uplevel $bodyScript
	}
    }
}

proc allchain {{boxRatio 1}} {
    source ../parameters.tcl
    set pi 3.1416
    set m_pi -3.1416

    set no [expr $noct-1]
    set nv [expr $nvox-1]
    set scale_max [expr $amin*pow(2,$no+($nv/double($nvox)))]
    set scale_max [expr $scale_max*(6/0.86)]
    set border_size [expr int($scale_max*$border_percent)]

    for { set oct 0;set num 0}\
	    { $oct < $noct} \
	    { incr oct } {
	for {set vox 0} \
		{ $vox < $nvox } \
		{ incr vox ; incr num} {
	    # Setting of local parameters
	    set scale [expr $amin*pow(2,$oct+($vox/double($nvox)))]
	    set scale [expr $scale*(6/0.86)]
	    dputs "  Octave $oct - vox $vox - scale $scale ( $num )"
	    set new_num [format "%.3d" $num]
	    set prev_num [expr $num-1]
	    set prev_new_num [format "%.3d" $prev_num]

	    eload max$new_num m$new_num

	    # We remove the border of the ext_image
	    set border [expr $size-$border_size]
	    rm_ext m$new_num m$new_num $border_size $border $border_size $border

	    # Research of maxima lines and maxima line maxima (yes, don't laugh).
	    hsearch m$new_num
	    ssm m$new_num

	    set box_size [expr int($boxRatio*log($scale)*2/log(2))]
	    if { $prev_num == 0} {
		vchain m$prev_new_num m$new_num $box_size $similitude -first
	    } else {
		if {$prev_num > 0} {
		    vchain m$prev_new_num m$new_num $box_size $similitude
		}
	    }
	}   
    }
}

proc getgrad {ext x y {name gr}} {
    vc2s $ext _sm $x $y -arg _sa
    scomb _sm _sa x*cos(y) _sx
    scomb _sm _sa x*sin(y) _sy
    screate $name 0 1 [sgetlst _sy] -xy [sgetlst _sx]
    delete _sm _sa _sx _sy
}

proc getallgrad {ext} {
    set i 0
    set j 0
    foreache $ext {
	if {[string compare $type "vc"] == 0} {
	    vc2s $ext sm$i $x $y -arg sa$i
	    scomb sm$i sa$i x*cos(y) sx$i
	    scomb sm$i sa$i x*sin(y) sy$i
	    screate gr$i 0 1 [sgetlst sy$i] -xy [sgetlst sx$i]
	    getgrad $ext $x $y gr$i
	    s2fs sx$i nsx$i x log(abs(y))
	    s2fs sy$i nsy$i x log(abs(y))
	    mylassign {index} [sgetindex sa$i 100]
	    set point [sget sa$i $index]
	    set y_value [lindex $point 0]
	    set x_value [lindex $point 1]
	    set cste [format "%f" [expr tan($y_value+1.5707963267948966)/(14*pow(2,$x_value/10.0))]]
	    s2fs sa$i nsa$i 14*pow(2,x/10.0) sin(y+1.5707963267948966)/(cos(y+1.5707963267948966))
	    incr i
	} else {
	    incr j
	}
    }
    #delete _sx _sy
    return "$i $j"
}

proc histdxdy {type scale {max ""}} {
    set newScale [format "%.3d" $scale]
    if {[file exists calendos_${type}$newScale] == 1} {
	set fileName calendos_${type}$newScale
    } elseif {[file exists h_${type}_cal$newScale] == 1} {
	set fileName h_${type}_cal$newScale
    } else {
	error "no 2d histogram file"
    }
    iload $fileName _itmp
    set image _itmp
    set name h_${type}
    icut $image _tmp 0
    set size [im_size $image]
    sscamult _tmp 0 ${name}dx${newScale}
    sscamult _tmp 0 ${name}dy${newScale}
    for {set i 0} {$i < $size} {incr i} {
	icut $image _tmp $i
	sadd _tmp ${name}dx${newScale} ${name}dx${newScale}
	icut $image _tmp $i -y
	sadd _tmp ${name}dy${newScale} ${name}dy${newScale}
    }
    if {$max != ""} {
	sputdx ${name}dx${newScale} [expr 2*$max/$size]
	sputx0 ${name}dx${newScale} [expr -$max]
	sputdx ${name}dy${newScale} [expr 2*$max/$size]
	sputx0 ${name}dy${newScale} [expr -$max]
    }
    szoom  ${name}dx${newScale} ${name}dx${newScale} 1
    szoom  ${name}dy${newScale} ${name}dy${newScale} 1
    delete _tmp
}

proc allhistdxdy {type {max ""}} {
    set scaleLst {0 10 20 30}
    foreach scale $scaleLst {
	histdxdy $type $scale $max
    }
}

proc all_dxdyhdisp {{lst ""}} {
    set result [hdisp 2 3 {h_imagedx h_maxdx h_max_linedx h_imagedy h_maxdy h_max_linedy} $lst]
    ${result}gr0000 set_label {black "dx -"} allSigLabel
    ${result}gr0001 set_label {black "dx (line) -"} allSigLabel
    ${result}gr0002 set_label {black "dx (max)  -"} allSigLabel
    ${result}gr0100 set_label {black "dy -"} allSigLabel
    ${result}gr0101 set_label {black "dy (line) -"} allSigLabel
    ${result}gr0102 set_label {black "dy (max)  -"} allSigLabel
}

# signal doit etre normalise.

proc smoment2 {signal n} {
    set size [ssize $signal]
    set dx [sgetdx $signal]

    for {set k 1} {$k <= $n} {incr k} {
	set res 0.0
	foreachs $signal {
	    set newX $x
	    for {set i 1} {$i < $k} {incr i} {
		set newX [expr $newX*$x]
	    }
	    set newX [expr $newX*$y*$dx]
	    set res [expr $res+$newX]
	}
	lappend resLst $res
    }
    return $resLst
}

proc sstat {signal n} {
    set momLst [smoment $signal $n]
    set m1 [lindex $momLst 0]
    set m2 [lindex $momLst 1]
    set sigma [expr sqrt($m2-$m1*$m1)]
    puts "sigma $sigma"
    for {set i 1} {$i <= $n} {incr i} {
	puts "moment $i [lindex $momLst [expr $i-1]]"
    }
}

# smoment2 --
# usage: smoment2 signal [ ]
#
# signal ne doit pas etre normalise.
#                   integrale (x * f(x) )
# mean vaut    m =  --------------------
#                   integrale ( f(x)  )


proc smoment2 {signal {mean ""}} {
    set size [ssize $signal]
    set dx [sgetdx $signal]

    if {$mean == ""} {
	set N 0
	set mean 0.0
	foreachs $signal {
	    set mean [expr $mean+$x*$y]
	    incr N [expr int($y)]
	}
	set mean [expr $mean/$N]
    }

    set adev 0.0
    set var1 0.0
    set var2 0.0
    set skew 0.0
    set kurt 0.0
    foreachs $signal {
	set adev [expr $adev+$y*abs($x-$mean)]
	set var1 [expr $var1+$y*pow($x-$mean,2)]
	set var2 [expr $var2+$y*($x-$mean)]
	set skew [expr $skew+$y*pow($x-$mean,3)]
	set kurt [expr $kurt+$y*pow($x-$mean,4)]
    }
    set adev [expr $adev/$N]
    set var  [expr ($var1-($var2*$var2)/$N)/($N-1)]
    set sigma [expr sqrt($var)]
    set skew [expr $skew/($N*pow($sigma,3))]
    set kurt [expr $kurt/($N*pow($sigma,4))-3]

    set skewErr [expr sqrt(15.0/$N)]
    set kurtErr [expr sqrt(96.0/$N)]

    return [list $mean $adev $var $sigma [list $skew $skewErr] [list $kurt $kurtErr]]
}

# smean --
# usage: smean signal [ ]
#
# c'est une copie de smoment2 
# (qui est definie deux fois dans hpcal_proc.tcl !!!) 
#
# signal ne doit pas etre normalise.
#                        integrale (x * f(x) )
# mean vaut         m =  ---------------------
#                         integrale ( f(x)  )
#
#
#                        integrale( (x-m)^2 * f(x))
# var1 vaut      var1 =  -------------------------
#                                    1
#
#
proc smean {signal {mean ""}} {
    set size [ssize $signal]
    set dx [sgetdx $signal]

    if {$mean == ""} {
	set N 0
	set mean 0.0
	foreachs $signal {
	    set mean [expr $mean+$x*$y]
	    incr N [expr int($y)]
	}
	set mean [expr $mean/$N]
    }

    set adev 0.0
    set var1 0.0
    set var2 0.0
    set skew 0.0
    set kurt 0.0
    foreachs $signal {
	set adev [expr $adev+$y*abs($x-$mean)]
	set var1 [expr $var1+$y*pow($x-$mean,2)]
	set var2 [expr $var2+$y*($x-$mean)]
	set skew [expr $skew+$y*pow($x-$mean,3)]
	set kurt [expr $kurt+$y*pow($x-$mean,4)]
    }
    set adev [expr $adev/$N]
    set var  [expr ($var1-($var2*$var2)/$N)/($N-1)]
    set sigma [expr sqrt($var)]
    set skew [expr $skew/($N*pow($sigma,3))]
    set kurt [expr $kurt/($N*pow($sigma,4))-3]

    set skewErr [expr sqrt(15.0/$N)]
    set kurtErr [expr sqrt(96.0/$N)]

    return [list $mean $adev $var $sigma [list $skew $skewErr] [list $kurt $kurtErr]]
}




#
proc gauss {name mean sigma xmin xmax n} {
    exprr $name exp(-((x-$mean)/$sigma)^2/2) $xmin $xmax $n
}

proc afit {name aMin aMax q_lst} {
    foreach theta {0 1 2 3 4 5 6 7} {
	ntq $aMin $aMax $q_lst $name$theta
	nDq $aMin $aMax $q_lst $name$theta
	nhq $aMin $aMax $q_lst $name$theta
    }

    ntq $aMin $aMax $q_lst m_part
    nDq $aMin $aMax $q_lst m_part
    nhq $aMin $aMax $q_lst m_part
}


proc mmdisp {} {
    set wid [mdisp 2 2 {{m0_tq m1_tq m2_tq m3_tq m4_tq m5_tq m6_tq m7_tq m_part_tq} {m0_hq m1_hq m2_hq m3_hq m4_hq m5_hq m6_hq m7_hq m_part_hq} {m0_Dq m1_Dq m2_Dq m3_Dq m4_Dq m5_Dq m6_Dq m7_Dq m_part_Dq}}]
    $wid setColorsByList {red yellow green blue red yellow green blue black}
    set itemList {}
    foreach value {-pi -3pi/4 -pi/2 -pi/4 0 pi/4 pi/2 3pi/2 glob} {
	set itemList [lappend itemlist [list %c $value]]
    }
    set result $wid
    eval $result setLabelsItemsByList $itemList
    ${result}gr0000 set_label {black "tau(q),"} allSigLabel
    ${result}gr0100 set_label {black "D(q),"} allSigLabel
    ${result}gr0001 set_label {black "h(q),"} allSigLabel
}


# 
proc tqtheo {name H beta p1 xmin xmax n} {
    
    if {$beta == 0} {
	exprr ${name}tq -1.0*log(pow(2.0-2.0*$p1,x)+pow(2.0*$p1,x))/log(2.0)-1.0 $xmin $xmax $n	
	return ${name}tq
    }

    if {$H == 0.0} {
	set beta_eps [expr 1.0-log(1.0+2*$p1*($p1-1))/log(2.0)]
	set expo [expr ($beta-$beta_eps)/2.0]
	puts "H=$expo"
	puts "beta_eps=$beta_eps"
	exprr ${name}tq -1.0*log(pow(2.0-2.0*$p1,x)+pow(2.0*$p1,x))/log(2.0)-1.0+x*$expo $xmin $xmax $n	
	#sderiv ${name}tq ${name}hq 
	#s2fs ${name}hq ${name}dq x x*y
	#scomb ${name}dq ${name}hq x-y ${name}dq
	return ${name}tq
    }
#    foreachs ${name}tq {
#	puts "($x $y)" 
#    }
}

#
proc readsig {fileName {sigName ""}} {
    if {$sigName == ""} {
	set sigName $fileName
    }
    set fileId [open $fileName r]

    while {[gets $fileId line] >= 0} {
	lappend xLst [lindex $line 0]
	lappend yLst [lindex $line 1]
    }
    screate $sigName 0 1 $yLst -xy $xLst

    close $fileId
}

#
proc mlaha {} {
    foreach i {10 20 40 80} {
	sload h_dx0$i h_dx0$i -sw
	sload h_dy0$i h_dy0$i -sw
    }
}

proc ilst2ps {iDblLst fileName args} {
    # Default option values.

    set scale 1
    set isLoaddel 0
    set isEinv 0

    # List of args for e2eps and i2eps commands.
    set newArgs ""

    # Arguments analysis.

    while {[string match -* $args]} {
	switch -glob -- [lindex $args 0] {
	    -scale {
		set scale [lindex $args 1]
		set args [lreplace $args 0 1]
	    }
	    -einv {
		set isEinv 1
		set args [lreplace $args 0 0]
	    }
	    -loaddel {
		set isLoaddel 1
		set args [lreplace $args 0 0]
	    }
	    default {
		lappend newArgs [lindex $args 0]
		set args [lreplace $args 0 0]
	    }
	}
    }

    # Page width and height of the result.

    set ps(pW) 0
    set ps(pH) 0

    # Number of lines.

    set ps(nL) 0

    # Get the attributes of the page.

    foreach iLst $iDblLst {
	# iLst contains the image list of the current line.

	set curL $ps(nL)

	# Current line width and height.

	set ps($curL,lW) 0
	set ps($curL,lH) 0
	set ps($curL,nR) 0
	foreach im $iLst {
	    switch -glob -- [gettype $im] {
		E {
		    set cmdPref e
		}
		I {
		    set cmdPref i
		}
		default  {
		    return -code error "bad object type [gettype $im]"
		}
	    }
	    if {$isLoaddel} {
		${cmdPref}load $im
	    }
	    set lx [expr int([lindex [${cmdPref}info $im] 1]*$scale)+2]
	    set ly [expr int([lindex [${cmdPref}info $im] 2]*$scale)+2]
	    if {$ly > $ps($curL,lH)} {
		set ps($curL,lH) $ly
	    }
	    incr ps($curL,lW) $lx
	    incr ps($curL,nR)
	    if {$isLoaddel} {
		delete $im
	    }
	}
	if {$ps($curL,lW) > $ps(pW)} {
	    set ps(pW) $ps($curL,lW)
	}
	incr ps(pH) $ps($curL,lH)
	incr ps(nL)
    }

    # Check the request size.

    if {$ps(pW) > 576 || $ps(pH) > 828} {
	return -code error "too big request size ($ps(pW), $ps(pH))"
    }

    # Create the postscript.

    set posY [expr 828-(828-$ps(pH))/2]
    set curL 0
    catch {exec rm $fileName}
    foreach iLst $iDblLst {
	# iLst contains the image list of the current line.

	set posX [expr (576-$ps($curL,lW))/2]
	foreach im $iLst {
	    set eArgs ""
	    switch -glob -- [gettype $im] {
		E {
		    if {$isEinv == 1} {
			set eArgs "-inv"
		    }
		    set cmdPref e
		}
		I {
		    set cmdPref i
		}
		default {
		    return -code error "bad object type [gettype $im]"
		}
	    }
	    if {$isLoaddel} {
		${cmdPref}load $im
	    }
	    set lx [expr int([lindex [${cmdPref}info $im] 1]*$scale)+2]
	    set ly [expr int([lindex [${cmdPref}info $im] 2]*$scale)+2]
	    set tmpPosY [expr $posY-$ly]
	    eval {${cmdPref}2eps $im $fileName \
		    -size 576 828 \
		    -pos $posX $tmpPosY \
		    -scale $scale \
		    -add} $newArgs $eArgs
	    incr posX $lx
	    if {$isLoaddel} {
		delete $im
	    }
	}
	incr posY -$ps($curL,lH)
	incr curL
    }
    smeps2ps $fileName
    return $fileName
}

proc rm1stline {file1Name file2Name} {
    set f1 [open $file1Name r]
    set f2 [open $file2Name w]
    gets $f1
    while {[gets $f1 line] != -1 } {
	puts $f2 $line
    }
    close $f1
    close $f2
}

proc s2dat {sig fileName {step 1}} {
    set f [open $fileName w]
    set count 0
    foreachs $sig {
	if {$count == 0} {
	    puts $f "$x $y"
	}
	incr count
	if {$count == $step} {
	    set count 0
	}
    }
    close $f
}

proc wt12im {name} {
    catch {delete $name}
    set sLst [lsort [ginfo ${name}* -list]]
    set lx [lindex [sinfo [lindex $sLst 0]] 1]
    set lx 1024
    set ly [llength $sLst]
    inull $name $lx $ly
    set y 0
    foreach s $sLst {
	iinssig $name $s $y
	incr y
    }
    return $name
}


proc lkjklhj {name} {
    set f [open res r]
    set amin 3.0
    set size 1024
    set no 4
    set nv 9
    set ns [expr $no*$nv]
    gets $f l
    set lst ""
    for {set j 0} {$j < $size} {incr j} {
	gets $f l
	lappend lst $l
    }
    screate $name 0 [expr 1.0/$size] $lst
    for {set i 0} {$i < $ns} {incr i} {
	set newi [format "%.3d" $i]
	gets $f l
	gets $f l
	set lst ""
	for {set j 0} {$j < $size} {incr j} {
	    gets $f l
	    lappend lst $l
	}
	screate ${name}wt$newi 0 [expr 1.0/$size] $lst
    }
}

# i2sp --
# usage: i2sp image [ int ] [ real ]
#
#   compute the power spectrum log-log (base 2 log)
#   of an image and puts it in a signal (name : imagessp)
#   which default size value is 32.
#   it also creates an image : imageisp ( abs(fft)^2 of image).
#
# Parameters:
#   image     - name of the image to treat
#   [ int ]   - size of the power spectrum signal
#               this size is important for the resolution.
#   [ real]   - base of logarithm (default value is exp(1)
#               for neperian log.)
#
# Return value:
#   None.


proc i2sp {im {size 32} {base "e"} } {
    if {$base == "e"} {
	set base [expr exp(1)]
    }
    echo $base
    igfft $im _f
    igfft2ri _f _r _i
    delete _f
    set isp ${im}isp
    set ssp ${im}ssp
    icomb _r _i x*x+y*y $isp
    delete _r _i
    iswap $isp
    isp2ssp $isp $ssp $size
    scomb $ssp $ssp log(x)/log($base) $ssp
    slogx $ssp $ssp $base
}

# myi2sp --
# usage: myi2sp image real real [ int ]
#
#   compute the power spectrum log-log (neperian log)
#   of an image in angular sector of (kx,ky) plane.
#
#   it creates 2 signals for the 2 complementary spectrum 
#   (name : imagessp1 and imagessp2)
#   their default size value is 32.
#   it also creates an image : imageisp (the "swaped" abs(fft)^2
#   of image, i.e. the point kx=ky=0 is in the center of imageisp).
#
# Parameters:
#   image     - name of the image to treat
#   real      - theta1 angle in degrees : from -90 to 90
#   real      - theta2  (to define the angular sector)
#   [ int ]   - size of the power spectrum signal
#               this size is important for the resolution.
#
# Return value:
#   None.


proc myi2sp {im theta1 theta2 {size 32}} {
    igfft $im _f
    igfft2ri _f _r _i
    delete _f
    set isp ${im}isp
    set ssp1 ${im}ssp1
    set ssp2 ${im}ssp2
    icomb _r _i x*x+y*y $isp
    delete _r _i
    iswap $isp
    myisp2ssp $isp $ssp1 $ssp2 $theta1 $theta2 $size
    scut $ssp1 $ssp1 2 1
    scut $ssp2 $ssp2 2 1
    scomb $ssp1 $ssp1 log(x) $ssp1
    scomb $ssp2 $ssp2 log(x) $ssp2
    slogx $ssp1 $ssp1
    slogx $ssp2 $ssp2
}

proc i2isp {im isp} {
    igfft $im _f
    igfft2ri _f _r _i
    delete _f
    icomb _r _i x*x+y*y $isp
    delete _r _i
    iswap $isp
}

# i2powspec --
# usage: i2powspec image [ int ] [ real ]
#
#   compute the power spectrum log-log (base 2 log)
#   of an image and puts it in a signal (name : imagessp)
#   which default size value is 32.
#
#   This command uses the FFTW based command ifftw2d/ifftw3d.
#
# Parameters:
#   image     - name of the image to treat
#   [ int ]   - size of the power spectrum signal
#               this size is important for the resolution.
#   [ real]   - base of logarithm (default value is exp(1)
#               for neperian log.)
#   [ int ]   - number of threads (only used if xsmurf is linked against
#               the multi-threaded fftw lib).
#
# Return value:
#   None.

proc i2powspec {im {size 32} {base "e"} {nthreads 1} } {
    if {$base == "e"} {
	set base [expr exp(1)]
    }
    echo $base
    
    set ssp ${im}ssp

    if {[lindex [ginfo $im] 0] == "Image3D" } {
	
	ifftw3d $im -threads $nthreads
	i3Dpowspec $im $ssp $size
	ifftw3d $im -threads $nthreads

    } else {
    
	ifftw2d $im -threads $nthreads	
	ipowspec $im $ssp $size
	ifftw2d $im -threads $nthreads
    }
    
    scomb $ssp $ssp log(x)/log($base) $ssp
    slogx $ssp $ssp $base

}


# myizoom --
# usage: myizoom image str  int
#
#   zoom image by the value "zoom" (see also izoom's help message)
#
# Parameters:
#   image     - Image  to treat
#   string    - name of the resulting image
#   integer   - must be an integer!!!
#
# Return value:
#   None.

proc myizoom {imin imout zoom} {
    set t1 [ntime]
    set lx [igetlx $imin]
    set ly [igetly $imin]
    set lx [expr $lx/$zoom*$zoom]
    set ly [expr $ly/$zoom*$zoom]
    iicut $imin _tmp 0 0 $lx $ly
    izoom _tmp $imout $zoom
    delete _tmp
    set t2 [ntime]
    echo temps de calcul approx (en secondes) : [expr $t2 - $t1]
    unset t1 t2 lx ly
}

proc tracerect {ima listex listey { zoom 5 } {size 214} } {
    set ssize [expr $size/$zoom]
    foreach i $listex j $listey {
	set ii [expr $i/$zoom+29]
	set jj [expr $j/$zoom+29]
	
	itracerect $ima $ii $jj $ssize $ssize
    }
}

proc isp2powSpec {isp ssp size} {
    isp2ssp $isp $ssp $size
    scomb $ssp $ssp log(x) $ssp
    slogx $ssp $ssp
}

proc s2sp {sig} {
    gfft $sig _f
    sgfft2ri _f _r _i
    delete _f
    set ssp ${sig}ssp
    scomb _r _i log(x*x+y*y) $ssp
    scutx $ssp $ssp 0 100
    slogx $ssp $ssp
}

proc icut2sp {im res args} {
    set imSize [im_size $im]
    set ssp $res
    icut $im _s 0 $args
    gfft _s _f
    delete _s
    sgfft2ri _f _r _i
    delete _f
    scomb _r _i 0 $ssp
    delete _r _i
    for {set x 0} {$x < $imSize} {incr x} {
	icut $im _s $x $args
	gfft _s _f
	delete _s
	sgfft2ri _f _r _i
	delete _f
	scomb _r _i (x*x+y*y)/1000000 _ssp
	delete _r _i
	scomb $ssp _ssp x+y $ssp
	delete _ssp
    }
    #scomb $ssp $ssp log(x/$imSize)/log(2) $ssp
    scomb $ssp $ssp (x/$imSize) $ssp
    scutx $ssp $ssp 0 100000
    slogx $ssp $ssp 2

    return $ssp
}

proc icut2sp2 {im res args} {
    set imSize [im_size $im]
    set ssp $res
    icut $im _s 0 $args
    gfft _s _f
    delete _s
    sgfft2ri _f _r _i
    delete _f
    scomb _r _i 0 $ssp
    delete _r _i
    for {set x 350} {$x < 650} {incr x} {
	icut $im _s $x $args
	gfft _s _f
	delete _s
	sgfft2ri _f _r _i
	delete _f
	scomb _r _i x*x+y*y _ssp
	delete _r _i
	scomb $ssp _ssp x+y $ssp
	delete _ssp
    }
    scomb $ssp $ssp log(x/300.0) $ssp
    scutx $ssp $ssp 0 100000
    slogx $ssp $ssp

    return $ssp
}

proc step {file1Name file2Name {step 1}} {
    set f1 [open $file1Name r]
    set f2 [open $file2Name w]
    set count 0
    while {[gets $f1 l] != -1} {
	if {$count == 0} {
	    puts $f2 $l
	}
	incr count
	if {$count == $step} {
	    set count 0
	}
    }
    close $f1
    close $f2
}

proc subsample {file1Name file2Name {step 1} {offset 0}} {
    set f1 [open $file1Name r]
    set f2 [open $file2Name w]
    for {set i 0} {$i < $offset} {incr i} {
	gets $f1 l
    }
    set count 0
    while {[gets $f1 l] != -1} {
	if {$count == 0} {
	    puts $f2 $l
	}
	incr count
	if {$count == $step} {
	    set count 0
	}
    }
    close $f1
    close $f2
}

proc rmend {file1Name file2Name index} {
    set f1 [open $file1Name r]
    set f2 [open $file2Name w]
    set count 0
    while {([gets $f1 l] != -1) && ($count != $index)} {
	puts $f2 $l
	incr count
    }
    close $f1
    close $f2
}

proc mm {} {
    set sList {m_part_tqbest m_part_tqpref m_part_tqmean m_part_t qmax m_part_tqmin m_part_tqbestamax m_part_tqbestamin}
    foreach s $sList {
	sinus $s 1024
    }
    set code [catch {mdisp 1 2 {{m_part_tqbest m_part_tqpref m_part_tqmean m_part_t qmax m_part_tqmin} {m_part_tqbestamax m_part_tqbestamin}}} result]
    $result setColorsByList {red green cyan blue violet}

    set itemList ""
    foreach value {best pref mean max min} {
	set itemList [lappend itemlist [list %c $value]]
    }
    eval ${result}gr0000 setLabelsItemsByList $itemList
    ${result}gr0000 set_label {black "fit, "} allSigLabel

    set itemList1 {{%c "amax "} {%c "amin "}}
    eval ${result}gr0001 setLabelsItemsByList $itemList1
    ${result}gr0001 set_label {black "best, "} allSigLabel 



}

proc sstats2 {signal n} {
    set size [ssize $signal]
    set dx [sgetdx $signal]
    for {set k 1} {$k <= $n} {incr k} {
        set res 0.0
        foreachs $signal {
            set newY [expr $y]
            for {set i 1} {$i < $k} {incr i} {
                set newY [expr $newY*$y]
            }
            set res [expr $res+$newY]
        }
        set res [expr $res/($size+1)]
        lappend resLst $res
    }

    return $resLst
}

# localfit --
# usage : str str list [-display] [real] [real]
#
#  Compute different local linear regression of the partition functions ``name''
# of order q from the ``basename'' file. Take windows of size 1/2, 1, 1.5 and 2
# dyades.
# create the signals :
#    best: the best slope.
#    mean: the mean slope.
#    min : the min slope
#    max : the max slope
#    [pref: the prefered slope] 
#
# Parameters :
#   str      - basename of the partition functions
#   str      - name of the partition functions (i.e. tau, h or D)
#   list     - list of the q values
#   -display - display the results
#   real     - prefered value of the minimum scale 
#   real     - prefered value of the maximum scale
#
# Return value :
#   The list of the name of the 5 created signals.

proc localfit {basename name q_lst {option ""} {prefamin ""} {prefamax ""}} { 
    cd partition
    sw_part_load ${basename}
    cd ..
    thd ${basename} $q_lst
    catch {unset fit_lst}
    catch {unset meanfit_lst}
    catch {unset bestfit_lst}
    catch {unset amin_bestfit_lst}
    catch {unset amax_bestfit_lst}
    catch {unset amax_fitmax_lst}
    catch {unset amin_fitmax_lst}
    catch {unset amax_fitmin_lst}
    catch {unset amin_fitmin_lst}
    if {$prefamin != "" && $prefamax != ""} {
	catch {unset preffit_lst}
    }
    foreach q $q_lst {
	set chi 100.0
	set ss 0.0
	set meantot 0.0
	set q_str [get_q_str $q]
	set num [ssize ${basename}_${name}$q_str]
	set x0 [sgetx0 ${basename}_${name}$q_str]
	set dx [sgetdx ${basename}_${name}$q_str]
	set WindLst {5 10 15 20}
	if {$prefamin != "" && $prefamax != ""} {
	    set newwind [expr $prefamax-$prefamin]
	    set newwind [expr $newwind/$dx]
	    set testwind 0
	    foreach wind $WindLst {
		if {$newwind == $wind} {
		    set testwind 1
		}
	    }
	    if {$testwind == 0} {
		lappend WindLst $newwind
	    }
	}
	foreach wind $WindLst {
	    catch {unset fit_lst}
	    catch {unset x_lst}
	    if {$wind == 20} {
		catch {unset aminfit_lst}
		catch {unset amaxfit_lst}
	    }
	    set numb [expr $num-$wind]
	    for {set i 0} {$i <= $numb} {incr i} {
		set amin [expr $x0+$dx*$i]
		set amax [expr $amin+$wind*$dx]
		set posx [expr ($amin+$amax)/2.0]
		set fit [sfit ${basename}_${name}$q_str $amin $amax]
		set a [lindex $fit 0]
		if {![string compare $a nan]} {
		    set a 0
		}
		lappend fit_lst $a
		lappend x_lst $posx
		if {$amin == $prefamin && $amax == $prefamax} {
		    set preffit $a
		}
		if {$wind == 20} {
		    set chi2 [lindex $fit 4]
		    if {$chi2 <= $chi} {
			set chi $chi2
			set besta $a
			set bestamax $amax
			set bestamin $amin
		    }
		    lappend aminfit_lst $amin
		    lappend amaxfit_lst $amax
		}
	    }
	    if {$wind == 20} {
		lappend bestfit_lst $besta
		lappend amax_bestfit_lst $bestamax
		lappend amin_bestfit_lst $bestamin
		screate amin_temp [lindex $x_lst 0] $dx $aminfit_lst
		screate amax_temp [lindex $x_lst 0] $dx $amaxfit_lst
	    }
	    screate ${basename}_${name}_wind${wind} [lindex $x_lst 0] $dx $fit_lst 
	    set meanvar [sstats ${basename}_${name}_wind${wind} 2]
	    set size [ssize ${basename}_${name}_wind${wind}]
	    set mean [lindex $meanvar 0]
	    set meantot [expr $meantot+$size*$mean]
	    set ss [expr $ss+$size]
	}
	set meantot [expr $meantot/$ss]
	set fit [sgetextr ${basename}_${name}_wind20]
	set fitmin [lindex $fit 0]
	set fitmax [lindex $fit 1]
	set iminfit [lindex $fit 2]
	set imaxfit [lindex $fit 3]
	lappend meanfit_lst $meantot
	lappend minfit_lst $fitmin
	lappend maxfit_lst $fitmax	
	if {$prefamin != "" && $prefamax != ""} {
	    lappend preffit_lst $preffit
	}
	set temp [sget amin_temp $iminfit]
	set amin_fitmin [lindex $temp 0]
	set temp [sget amax_temp $iminfit]
	set amax_fitmin [lindex $temp 0]
	set temp [sget amin_temp $imaxfit]
	set amin_fitmax [lindex $temp 0]
	set temp [sget amax_temp $imaxfit]
	set amax_fitmax [lindex $temp 0]
	lappend amin_fitmin_lst $amin_fitmin
	lappend amax_fitmin_lst $amax_fitmin
	lappend amin_fitmax_lst $amin_fitmax
	lappend amax_fitmax_lst $amax_fitmax
    }
    screate ${basename}_${name}best [lindex $q_lst 0] 1 $bestfit_lst -xy $q_lst
    screate ${basename}_${name}bestamax [lindex $q_lst 0] 1 $amax_bestfit_lst -xy $q_lst
    screate ${basename}_${name}bestamin [lindex $q_lst 0] 1 $amin_bestfit_lst -xy $q_lst

    screate ${basename}_${name}mean [lindex $q_lst 0] 1 $meanfit_lst -xy $q_lst
    screate ${basename}_${name}max [lindex $q_lst 0] 1 $maxfit_lst -xy $q_lst
    screate ${basename}_${name}maxamax [lindex $q_lst 0] 1 $amax_fitmax_lst -xy $q_lst
    screate ${basename}_${name}maxamin [lindex $q_lst 0] 1 $amin_fitmax_lst -xy $q_lst

    screate ${basename}_${name}min [lindex $q_lst 0] 1 $minfit_lst -xy $q_lst
    screate ${basename}_${name}minamax [lindex $q_lst 0] 1 $amax_fitmin_lst -xy $q_lst
    screate ${basename}_${name}minamin [lindex $q_lst 0] 1 $amin_fitmin_lst -xy $q_lst

    if {$prefamin != "" && $prefamax != ""} {
	screate ${basename}_${name}pref [lindex $q_lst 0] 1 $preffit_lst -xy $q_lst
    }
    if {[string compare $option -display] == 0} {
	set completeLst {}
	if {$prefamin != "" && $prefamax != ""} {
	    set sigLst {}
	    foreach val {best pref mean max min} {
		set sigLst [lappend sigLst ${basename}_${name}$val]
	    }
	    set completeLst [lappend completeLst ${sigLst}]
	    set sigLst2 {}
	    foreach val {bestamax bestamin maxamax maxamin minamax minamin} {
		set sigLst2 [lappend sigLst2 ${basename}_${name}$val]
	    }
	    set completeLst [lappend completeLst ${sigLst2}]
	    set code [catch {mdisp 1 2 ${completeLst}} result]
	    if {$code != 0} {
		error $result $result
	    }
	    ${result}gr0000 setColorsByList {red violet cyan green blue}
	    set itemList {}
	    foreach value {best pref mean max min} {
		set itemList [lappend itemlist [list %c $value]]
	    }
	    eval ${result}gr0000 setLabelsItemsByList $itemList
	    ${result}gr0000 set_label {black "fit, "} allSigLabel
	} else {
	    set sigLst {}
	    foreach val {best mean max min} {
		set sigLst [lappend sigLst ${basename}_${name}$val]
	    }
	    set completeLst [lappend completeLst ${sigLst}]
	    set sigLst2 {}
	    foreach val {bestamax bestamin maxamax maxamin minamax minamin} {
		set sigLst2 [lappend sigLst2 ${basename}_${name}$val]
	    }
	    set completeLst [lappend completeLst ${sigLst2}]
	    set code [catch {mdisp 1 2 ${completeLst}} result]
	    if {$code != 0} {
		error $result $result
	    }
	    ${result}gr0000 setColorsByList {red cyan green blue}
	    set itemList {}
	    foreach value {best mean max min} {
		set itemList [lappend itemlist [list %c $value]]
	    }
	    eval ${result}gr0000 setLabelsItemsByList $itemList
	    ${result}gr0000 set_label {black "fit, "} allSigLabel
	}
	${result}gr0001 setColorsByList {red red green green blue blue}
	set itemList1 {}
	foreach value {best .. max .. min ..} {
	    set itemList1 [lappend itemlist1 [list %c $value]]
	}
	eval ${result}gr0001 setLabelsItemsByList $itemList1
	${result}gr0001 set_label {black "Range for, "} allSigLabel
    }
    return $sigLst
}


# localslope --
# usage : str str real [-display]
#
#  Compute the local linear regression of the partition functions ``name'' 
# of order q from the ``basename'' file. Take windows of size 1/2, 1, 1.5 and 2
# dyades
#
# Parameters :
#   str      - basename of the partition functions
#   str      - name of the partition functions (i.e. tau, h or D)
#   real     - the considered q value
#   -display - display the results
#
# Return value :
#   The list of the name of the 4 created signals.

proc localslope {basename name q {option ""}} { 
    cd partition
    sw_part_load ${basename}
    cd ..
    thd ${basename} $q
    
    set q_str [get_q_str $q]
    set num [ssize ${basename}_${name}$q_str]
    set x0 [sgetx0 ${basename}_${name}$q_str]
    set dx [sgetdx ${basename}_${name}$q_str]
    set WindLst {5 10 15 20}

    set sigLst {}
    foreach wind $WindLst {
	catch {unset fit_lst}
	catch {unset x_lst}
	
	set numb [expr $num-$wind]
	for {set i 0} {$i <= $numb} {incr i} {
	    set amin [expr $x0+$dx*$i]
	    set amax [expr $amin+$wind*$dx]
	    set posx [expr ($amin+$amax)/2.0]
	    set fit [sfit ${basename}_${name}$q_str $amin $amax]
	    set a [lindex $fit 0]
	    if {![string compare $a nan]} {
		set a 0
	    }
	    lappend fit_lst $a
	    lappend x_lst $posx
	}
	screate ${basename}_${name}_wind${wind} [lindex $x_lst 0] $dx $fit_lst 
	set sigLst [lappend sigLst ${basename}_${name}_wind${wind}]
    }

    if {[string compare $option -display] == 0} {
	set completelst {}
	set completeLst [lappend completeLst ${sigLst}]
	set code [catch {mdisp 1 1 ${completeLst}} result]
	if {$code != 0} {
	    error $result $result
	}
	${result}gr0000 setColorsByList {red cyan green blue}
	set itemList {}
	foreach value $WindLst {
	    set value [expr $value*$dx]
	    set itemList [lappend itemlist [list %c $value]]
	}
	eval ${result}gr0000 setLabelsItemsByList $itemList
	${result}gr0000 set_label {black "Window size, "} allSigLabel
    }
    return $sigLst
}



proc allloc {basename name qliste} {
    set complete_Lst {}
    foreach qq $qliste {
        set sig_Lst {}
        set list [localslope $basename $name $qq]
        foreach name2 $list {
            scopy $name2 ${qq}_$name2
            set sig_Lst [lappend sig_Lst ${qq}_$name2] 
        }
        set complete_Lst [lappend complete_Lst $sig_Lst]        
    }
    set code [catch {mdisp 3 3 ${complete_Lst}} result]
    if {$code != 0} {
        error $result $result
    }
    ${result} setColorsByList {red cyan green blue}
    set itemList {}    
    foreach value {0.5 1.0 1.5 2.0} {
        set itemList [lappend itemlist [list %c $value]]
    }
    eval ${result} setLabelsItemsByList $itemList
    set r 0
    set l 0
    foreach qq $qliste {
        set newL [format "%.2d" $l]
        set newR [format "%.2d" $r]
        ${result}gr${newR}${newL} set_label [list black "$name q=$qq W. size, "] allSigLabel
        incr l
        if {$l == 3} {
            set l 0
            incr r
        }

    }
}

proc allchain2 {{boxRatio 1}} {
    source ../parameters.tcl
    set pi 3.1416
    set m_pi -3.1416

    set no [expr $noct-1]
    set nv [expr $nvox-1]
    set scale_max [expr $amin*pow(2,$no+($nv/double($nvox)))]
    set scale_max [expr $scale_max*(6/0.86)]
    set border_size [expr int($scale_max*$border_percent)]
    set border [expr $size-$border_size]
    puts "border size=$border_size"

    #iload image
    set bb [expr $border_size-1]
    set bbb [expr $border+1]
    #cutedge image image $bb
    #set ss [im_size image]
    #puts "New size of the image ${ss}x${ss}"

    for { set oct 0;set num 0}\
	    { $oct < $noct} \
	    { incr oct } {
	for {set vox 0} \
		{ $vox < $nvox } \
		{ incr vox ; incr num} {
	    # Setting of local parameters
	    set scale [expr $amin*pow(2,$oct+($vox/double($nvox)))]
	    set scale [expr $scale*(6/0.86)]
	    dputs "  Octave $oct - vox $vox - scale $scale ( $num )"
	    set new_num [format "%.3d" $num]
	    set prev_num [expr $num-1]
	    set prev_new_num [format "%.3d" $prev_num]

	    eload max$new_num m$new_num

	    # We remove the border of the ext_image
	    #rm_ext m$new_num max$new_num $border_size $border $border_size $border

	    puts "$bb $bbb"
	    ecut m$new_num m$new_num $bb $bb $bbb $bbb

	    # Research of maxima lines and maxima line maxima (yes, don't laugh).
	    puts coucou
	    hsearch m$new_num
	    puts coucou2
	    ssm m$new_num
	    puts coucou3
	    set box_size [expr int($boxRatio*log($scale)*2/log(2))]
	    if { $prev_num == 0} {
		#vchain m$prev_new_num m$new_num $box_size $similitude -first
	    } else {
		if {$prev_num > 0} {
		    #vchain m$prev_new_num m$new_num $box_size $similitude
		}
	    }
	}   
    }
}


proc hsvch2 {amin noct nvox firstsid {boxRatio 1} {thresh 0}} {
    set similitude 0.8

    set no [expr $noct-1]
    set nv [expr $nvox-1]
    set scale_max [expr $amin*pow(2,$no+($nv/double($nvox)))]
    set scale_max [expr $scale_max*(6/0.86)]

    for { set oct 0;set num 0}\
	    { $oct < $noct} \
	    { incr oct } {
	for {set vox 0} \
		{ $vox < $nvox } \
		{ incr vox ; incr num} {
	    # Setting of local parameters
	    set scale [expr $amin*pow(2,$oct+($vox/double($nvox)))]
	    set scale [expr $scale*(6/0.86)]
	    dputs "  Octave $oct - vox $vox - scale $scale ( $num )"
	    if {$num < $firstsid} {
		continue
	    }
	    set new_num [format "%.3d" $num]
	    set prev_num [expr $num-1]
	    set prev_new_num [format "%.3d" $prev_num]

	    eload max$new_num m$new_num
	    if {$thresh > 0} {
		ekeep m$new_num m$new_num $thresh
	    }

	    hsearch m$new_num
	    ssm m$new_num

	    set box_size [expr int($boxRatio*log($scale)*2/log(2))]
	    if { $prev_num == 0} {
		vchain m$prev_new_num m$new_num $box_size $similitude -first
	    } else {
		if {$prev_num > 0} {
		    vchain m$prev_new_num m$new_num $box_size $similitude
		}
	    }
	}   
    }
}

proc hsvch3 {amin noct nvox {id_offset 0} {boxRatio 1} {thresh 0}} {
    set similitude 0.8

    set no [expr $noct-1]
    set nv [expr $nvox-1]
    set scale_max [expr $amin*pow(2,$no+($nv/double($nvox)))]
    set scale_max [expr $scale_max*(6/0.86)]

    for { set oct 0;set num $id_offset;set fnum 0}\
	    { $oct < $noct} \
	    { incr oct } {
	for {set vox 0} \
		{ $vox < $nvox } \
		{ incr vox ; incr num; incr fnum} {
	    # Setting of local parameters
	    set scale [expr $amin*pow(2,$oct+($vox/double($nvox)))]
	    set scale [expr $scale*(6/0.86)]
	    dputs "  Octave $oct - vox $vox - scale $scale ( $num )"
	    set new_fnum [format "%.3d" $fnum]
	    set new_num [format "%.3d" $num]
	    set prev_num [expr $num-1]
	    set prev_new_num [format "%.3d" $prev_num]

	    eload max$new_fnum m$new_num
	    if {$thresh > 0} {
		ekeep m$new_num m$new_num $thresh
	    }

	    hsearch m$new_num
	    ssm m$new_num

	    set box_size [expr int($boxRatio*log($scale)*2/log(2))]
	    if { $prev_num == $id_offset} {
		vchain m$prev_new_num m$new_num $box_size $similitude -first
	    } else {
		if {$prev_num > $id_offset} {
		    vchain m$prev_new_num m$new_num $box_size $similitude
		}
	    }
	}   
    }
}

proc hsvch {amin noct nvox {boxRatio 1} {thresh 0}} {
    set similitude 0.8

    set no [expr $noct-1]
    set nv [expr $nvox-1]
    set scale_max [expr $amin*pow(2,$no+($nv/double($nvox)))]
    set scale_max [expr $scale_max*(6/0.86)]

    for { set oct 0;set num 0}\
	    { $oct < $noct} \
	    { incr oct } {
	for {set vox 0} \
		{ $vox < $nvox } \
		{ incr vox ; incr num} {
	    # Setting of local parameters
	    set scale [expr $amin*pow(2,$oct+($vox/double($nvox)))]
	    set scale [expr $scale*(6/0.86)]
	    dputs "  Octave $oct - vox $vox - scale $scale ( $num )"
	    set new_num [format "%.3d" $num]
	    set prev_num [expr $num-1]
	    set prev_new_num [format "%.3d" $prev_num]

	    eload max$new_num m$new_num
	    if {$thresh > 0} {
		ekeep m$new_num m$new_num $thresh
	    }

	    hsearch m$new_num
	    ssm m$new_num

	    set box_size [expr int($boxRatio*log($scale)*2/log(2))]
	    if { $prev_num == 0} {
		vchain m$prev_new_num m$new_num $box_size $similitude -first
	    } else {
		if {$prev_num > 0} {
		    vchain m$prev_new_num m$new_num $box_size $similitude
		}
	    }
	}   
    }
}

proc hsvch4 {amin noct nvox {eps 0} {offset 0} {boxRatio 1} {thresh 0}} {
    set similitude 0.8

    set no [expr $noct-1]
    set nv [expr $nvox-1]
    set scale_max [expr $amin*pow(2,$no+($nv/double($nvox)))]
    set scale_max [expr $scale_max*(6/0.86)]

    for { set oct 0;set num $offset}\
	    { $oct < $noct} \
	    { incr oct } {
	for {set vox 0} \
		{ $vox < $nvox } \
		{ incr vox ; incr num} {
	    # Setting of local parameters
	    set scale [expr $amin*pow(2,$oct+($vox/double($nvox)))]
	    set scale [expr $scale*(6/0.86)]
	    dputs "  Octave $oct - vox $vox - scale $scale ( $num )"
	    set new_num [format "%.3d" $num]
	    set prev_num [expr $num-1]
	    set prev_new_num [format "%.3d" $prev_num]

	    eload max$new_num m$new_num
	    if {$thresh > 0} {
		ekeep m$new_num m$new_num $thresh
	    }

	    hsearch m$new_num
	    ssm m$new_num -smooth -eps $eps

	    set box_size [expr int($boxRatio*log($scale)*2/log(2))]
	    if { $prev_num == $offset} {
		vchain m$prev_new_num m$new_num $box_size $similitude -first
	    } else {
		if {$prev_num > $offset} {
		    vchain m$prev_new_num m$new_num $box_size $similitude
		}
	    }
	}   
    }
}

proc hsvch5 {amin noct nvox {offset 0} {boxRatio 1} {thresh 0}} {
    set similitude 0.8

    set no [expr $noct-1]
    set nv [expr $nvox-1]
    set scale_max [expr $amin*pow(2,$no+($nv/double($nvox)))]
    set scale_max [expr $scale_max*(6/0.86)]

    for { set oct 0;set num $offset}\
	    { $oct < $noct} \
	    { incr oct } {
	for {set vox 0} \
		{ $vox < $nvox } \
		{ incr vox ; incr num} {
	    # Setting of local parameters
	    set scale [expr $amin*pow(2,$oct+($vox/double($nvox)))]
	    set scale [expr $scale*(6/0.86)]
	    dputs "  Octave $oct - vox $vox - scale $scale ( $num )"
	    set new_num [format "%.3d" $num]
	    set prev_num [expr $num-1]
	    set prev_new_num [format "%.3d" $prev_num]

	    eload max$new_num m$new_num
	    if {$thresh > 0} {
		ekeep m$new_num m$new_num $thresh
	    }

	    hsearch m$new_num
	    ssm m$new_num -greatest

	    set box_size [expr int($boxRatio*log($scale)*2/log(2))]
	    if { $prev_num == $offset} {
		vchain m$prev_new_num m$new_num $box_size $similitude -first
	    } else {
		if {$prev_num > $offset} {
		    vchain m$prev_new_num m$new_num $box_size $similitude
		}
	    }
	}   
    }
}

proc hsvch6 {amin noct nvox {offset 0} {boxRatio 1} {thresh 0}} {
    set similitude 0.8

    set no [expr $noct-1]
    set nv [expr $nvox-1]
    set scale_max [expr $amin*pow(2,$no+($nv/double($nvox)))]
    set scale_max [expr $scale_max*(6/0.86)]

    for { set oct 0;set num $offset; set file_num 0}\
	    { $oct < $noct} \
	    { incr oct } {
	for {set vox 0} \
		{ $vox < $nvox } \
		{ incr vox ; incr num; incr file_num} {
	    # Setting of local parameters
	    set scale [expr $amin*pow(2,$oct+($vox/double($nvox)))]
	    set scale [expr $scale*(6/0.86)]
	    dputs "  Octave $oct - vox $vox - scale $scale ( $num )"
	    set new_num [format "%.3d" $num]
	    set file_new_num [format "%.3d" $file_num]
	    set prev_num [expr $num-1]
	    set prev_new_num [format "%.3d" $prev_num]

	    eload max$file_new_num m$new_num
	    if {$thresh > 0} {
		ekeep m$new_num m$new_num $thresh
	    }

	    hsearch m$new_num
	    ssm m$new_num -greatest

	    set box_size [expr int($boxRatio*log($scale)*2/log(2))]
	    if { $prev_num == $offset} {
		vchain m$prev_new_num m$new_num $box_size $similitude -first
	    } else {
		if {$prev_num > $offset} {
		    vchain m$prev_new_num m$new_num $box_size $similitude
		}
	    }
	}   
    }
}

proc fitfnpart { } {
    source parameters.tcl
    for { set oct 0;set num 0}\
	    { $oct < $noct} \
	    { incr oct } {
	for {set vox 0} \
		{ $vox < $nvox } \
		{ incr vox ; incr num} {
	    set new_num [format "%.3d" $num]
	    sload histograms/h_log_max_line_mod$new_num
h_log_max_line_mod$new_num -sw
	}
    }   
    snh
    for { set oct 0;set num 0}\
	    { $oct < $noct} \
	    { incr oct } {
	for {set vox 0} \
		{ $vox < $nvox } \
		{ incr vox ; incr num} {
	    set new_num [format "%.3d" $num]
	    h2logh h_log_max_line_mod$new_num
	    set momLst ""
	    set momLst [smoment h_log_max_line_mod$new_num 2]
	    set m1 [lindex $momLst 0]
	    set m2 [lindex $momLst 1]
	    set sigma [expr sqrt($m2-$m1*$m1)]    
	    gauss h_g$new_num $m1 $sigma -8 8 512	    
	}
    }
    snh

# The computation of the fns of partition with the log-normal fit.
set dx [expr 1.0/$nvox]
foreach q $q_lst {
	puts "q=$q"
	set zq_lst {}
	set hq_lst {}
	set dq_lst {}
	for { set oct 0;set num 0}\
		{ $oct < $noct} \
		{ incr oct } {
	    for {set vox 0} \
		    { $vox < $nvox } \
		    { incr vox ; incr num} {
		set new_num [format "%.3d" $num]
		# Pour Z(q,a) = somme T^q = somme exp(qln T)
		s2fs h_g$new_num uu x y*exp($q*x)
		sintegrate uu uuu
		set result [ssize uuu]
		set res [sget uuu $result]
		set val [lindex $res 0]
		set val [format %f $val]
		set zq_)lst [lappend zq_lst $val]
		# Pour h(q,a) = somme (T^q*log T )/Z(q,a)
		s2fs h_g$new_num uu x y*exp($q*x)*x/($val*log(2.0))
		sintegrate uu uuu
		set result [ssize uuu]
		set res [sget uuu $result]
		set valh [lindex $res 0]
		set hq_lst [lappend hq_lst $valh]
		# Pour D(q,a) = somme (T^q*log(T/Z(q,a)))/Z(q,a)
		s2fs h_g$new_num uu x
y*exp($q*x)*($q*x-log($val))/($val*log(2.0))
		sintegrate uu uuu
		set result [ssize uuu]
		set res [sget uuu $result]
		set valD [lindex $res 0]
		set dq_lst [lappend dq_lst $valD]
	    }
	}
	screate z_$q 1 $dx $zq_lst
	screate h_$q 1 $dx $hq_lst
	screate d_$q 1 $dx $dq_lst	
	s2fs z_$q z_$q x log(y)/log(2.0)-2*x
	s2fs d_$q d_$q x y+2*x

	set q_str [get_q_str $q]
	ssave z_$q partition/fit_m_part_tau$q_str -sw
	ssave h_$q partition/fit_m_part_h$q_str -sw
	ssave d_$q partition/fit_m_part_D$q_str -sw

    }
}



proc fitfnpart2 { } {
    source parameters.tcl
    for { set oct 0;set num 0}\
	    { $oct < $noct} \
	    { incr oct } {
	for {set vox 0} \
		{ $vox < $nvox } \
		{ incr vox ; incr num} {
	    set new_num [format "%.3d" $num]
	    sload histograms/h_max_line_mod$new_num h_max_line_mod$new_num
-sw
	}
    }   
#    snh

# The computation of the fns of partition with the log-normal fit.
    set dx [expr 1.0/$nvox]
    foreach q {1.0 2.0} {
	puts "q=$q"
	set zq_lst {}
	set hq_lst {}
	set dq_lst {}
	for { set oct 0;set num 0}\
		{ $oct < $noct} \
		{ incr oct } {
	    for {set vox 0} \
		    { $vox < $nvox } \
		    { incr vox ; incr num} {
		set new_num [format "%.3d" $num]
		# Pour Z(q,a) = somme T^q = somme exp(qln T)
		s2fs h_max_line_mod$new_num uu x y*x^$q
		sintegrate uu uuu
		set result [ssize uuu]
		set res [sget uuu $result]
		set val [lindex $res 0]
		set val [format %f $val]
		set zq_lst [lappend zq_lst $val]
		# Pour h(q,a) = somme (T^q*log T )/Z(q,a)
#		s2fs h_max_line_mod$new_num uu x
y*exp($q*log(abs(x)))*log(abs(x))/($val*log(2.0))
		s2fs h_max_line_mod$new_num uu x
y*x^$q*log(x)/($val*log(2.0))
		sintegrate uu uuu
		set result [ssize uuu]
		set res [sget uuu $result]
		set valh [lindex $res 0]
		set hq_lst [lappend hq_lst $valh]
		# Pour D(q,a) = somme (T^q*log(T^q/Z(q,a)))/Z(q,a)
#		s2fs h_max_line_mod$new_num uu x
y*exp($q*log(abs(x)))*($q*log(abs(x))-log($val))/$val
		s2fs h_max_line_mod$new_num uu x
y*x^$q*log(x^$q/$val)/($val*log(2.0))
		sintegrate uu uuu
		set result [ssize uuu]
		set res [sget uuu $result]
		set valD [lindex $res 0]
		set dq_lst [lappend dq_lst $valD]
	    }
	}
	
	screate z_$q 1 $dx $zq_lst
	screate h_$q 1 $dx $hq_lst
	screate d_$q 1 $dx $dq_lst
	s2fs z_$q z_$q x log(y)/log(2.0)
    }
}


proc im2dat {im fName} {
    set f [open $fName w]

    mylassign {gah lx ly} [iinfo $im]

    puts $f "$lx 0 0 1\nhaha\n$ly 0 0 1\nhoho"

    imloop $im {
	puts $f [format "%f" $value]
    }

    close $f
}

# lvc2dat --
# usage: lvc2dat extima string string string [real] 
#
# 
#
#

proc lvc2dat {extImage lFileName aFileName cFileName {mult -1} {istag 0}} {
    set lFileId [open $lFileName w]
    set aFileId [open $aFileName w]
    set cFileId [open $cFileName w]
    mylassign {scale lx ly extrNb chainNb nbOfLines stamp} [einfo $extImage]
    mylassign {min max} [egetextr $extImage]
    if {$mult == -1} {
	set mult [expr 30.0/$max]
    }
    if {$istag == 0} {
	eiloop $extImage {
	    puts $lFileId "$x $y"
	    if {$type == "vc"} {
		puts $cFileId "$x $y"
		puts $aFileId "$x $y"
		set x1 [expr $x+$mult*$mod*cos($arg)]
		set y1 [expr $y+$mult*$mod*sin($arg)]
		puts $aFileId "$x1 $y1"
	    }
	}
	close $lFileId
	close $aFileId
	close $cFileId
	return $mult
    } else {
	eigrloop $extImage {
	    puts $lFileId "$x $y"
	    if {$type == "tag vc"} {
		puts $cFileId "$x $y"
		puts $aFileId "$x $y"
		set x1 [expr $x+$mult*$mod*cos($arg)]
		set y1 [expr $y+$mult*$mod*sin($arg)]
		puts $aFileId "$x1 $y1"
	    }
	}
	close $lFileId
	close $aFileId
	close $cFileId
	return $mult
    }

}

proc gr2dat {extImage aFileName {mult -1}} {
    set aFileId [open $aFileName w]
    mylassign {scale lx ly extrNb chainNb nbOfLines stamp} [einfo $extImage]
    mylassign {min max} [egetextr $extImage]
    if {$mult == -1} {
	set mult [expr 30.0/$max]
    }
    eigrloop $extImage {
	puts $aFileId "$x $y"
	set x1 [expr $x+$mult*$mod*cos($arg)]
	set y1 [expr $y+$mult*$mod*sin($arg)]
	puts $aFileId "$x1 $y1"
    }
    close $aFileId
    return $mult
}

proc ma2dat {mod arg aFileName cFileName {step 1}} {
    set aFileId [open $aFileName w]
    set cFileId [open $cFileName w]
    mylassign {dummy lx ly} [iinfo $mod]
    mylassign {min max} [im_extrema $mod]
    set mult [expr 30.0/$max]
    imloop $mod {
        if {[expr $x%$step] == 0 && [expr $y%$step] == 0 } {
	    set m [expr $value]
	    set a [value $arg $x $y]
            puts $cFileId "$x $y"
            puts $aFileId "$x $y"
            set x1 [expr $x+$mult*$m*cos($a)]
            set y1 [expr $y+$mult*$m*sin($a)]
            puts $aFileId "$x1 $y1"
        }
    }
    close $aFileId
    close $cFileId

    return $mult
}

proc hsvch2 {name amin noct nvox {boxRatio 1}} {
    set similitude 0.8

    set no [expr $noct-1]
    set nv [expr $nvox-1]
    set scale_max [expr $amin*pow(2,$no+($nv/double($nvox)))]
    set scale_max [expr $scale_max*(6/0.86)]

    for { set oct 0;set num 0}\
	    { $oct < $noct} \
	    { incr oct } {
	for {set vox 0} \
		{ $vox < $nvox } \
		{ incr vox ; incr num} {
	    # Setting of local parameters
	    set scale [expr $amin*pow(2,$oct+($vox/double($nvox)))]
	    set scale [expr $scale*(6/0.86)]
	    dputs "  Octave $oct - vox $vox - scale $scale ( $num )"
	    set new_num [format "%.3d" $num]
	    set prev_num [expr $num-1]
	    set prev_new_num [format "%.3d" $prev_num]

	    #hsearch ${name}$new_num
	    ssm ${name}$new_num

	    set box_size [expr int($boxRatio*log($scale)*2/log(2))]
	    if { $prev_num == 0} {
		vchain ${name}$prev_new_num ${name}$new_num $box_size $similitude -first
	    } else {
		if {$prev_num > 0} {
		    vchain ${name}$prev_new_num ${name}$new_num $box_size $similitude
		}
	    }
	}   
    }
}

proc reads {name {res ""}} {
    if {$res == ""} {
	set res $name
    }
    set f [open $name r]
    set xLst {}
    set yLst {}
    while {[gets $f l] != -1} {
	lappend xLst [lindex $l 0]
	lappend yLst [lindex $l 1]
    }
    screate $res 0 1 $yLst -xy $xLst
    close $f
}


proc legendre3 {name list} {
    set qlst {-6.0 -5.0 -4.0 -3.0 -2.0 -1.0 -0.2 0.0 0.2 0.5 0.8 1.0 1.2
1.5 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0}
    s2fs $name d$name x 0.05*x+.0001
    screate val 0 1 $list
    screate f$name 0 1 $qlst
#    set npoint [expr int(($max+10)*2+1)]
#    exprr f$name x -10 $max $npoint
    polyf $name d$name val res -fit f$name
    sderiv f$name h$name
# We verifie that h(q) is always decreasing
    sderiv h$name uuu
    set i 0
    foreachs uuu {
        if {$y > 0.0} {
            puts "<<<<<<<<<<<<< WARNING >>>>>>>>>>>>>>"
            puts "  fit change for value above x =$x"
            puts "<<<<<<<<<<<<< WARNING >>>>>>>>>>>>>>"
            break
        }
        incr i
    } 
    set imin [expr $i-2]
    set imax [expr $i+1]
    set xmin [lindex [sget f$name $imin] 1]  
    set xmax [lindex [sget f$name $imax] 1]  
    puts "$xmin $xmax"
    sthresh f$name uuu $xmin $xmax
    s2fs uuu s  x .00001
    screate newf 0 1 $qlst
#    exprr newf x -10 $max $npoint
    puts $xmin
    sthresh newf newf $imin 1000
    screate v 0 1 $list
    polyf uuu s v r -fit newf
    set xx [expr $xmin -.001]
    puts $xx
    sthresh f$name f$name -100 $xx
    scolle f$name newf f$name
    sderiv f$name h$name

    s2fs h$name temp x y*x

#    set m [expr $max-0.001]
    sthresh f$name f$name -11 10.2
    scomb temp f$name x-y dq$name
    smerge h$name dq$name dh$name
    return "f$name h$name dh$name" 
}

# boxwt --
# usage : boxwt signal int
#
# take care signal must be of type REALXY !!!
#

proc boxwt {sig size } {

    set xLst [sgetlst $sig -x]
    set yLst [sgetlst $sig -y]

    exprr wt_2 0*x 0  [expr $size/2 *  $size/2  - 1] [expr $size/2*$size/2]
    exprr wt_4 0*x 0  [expr $size/4 *  $size/4  - 1] [expr $size/4*$size/4]
    exprr wt_8 0*x 0  [expr $size/8 *  $size/8  - 1] [expr $size/8*$size/8]
    exprr wt_16 0*x 0 [expr $size/16 * $size/16 - 1] [expr $size/16*$size/16]
    exprr wt_32 0*x 0 [expr $size/32 * $size/32 - 1] [expr $size/32*$size/32]
    exprr wt_64 0*x 0 [expr $size/64 * $size/64 - 1] [expr $size/64*$size/64]

# [expr int(log($size)/log(2))]

    foreach i $xLst j $yLst {
	for {set logscale 1} {$logscale < 7} {incr logscale} {
	    set scale  [expr int(pow(2,$logscale))]
	    set newi   [expr $i/$scale]
	    set newj   [expr $j/$scale]
	    set indice [expr $newi*$size/$scale+$newj]
	    sset wt_$scale $indice [expr [lindex [sget wt_$scale $indice] 0] + 1]
	}
    }


}
