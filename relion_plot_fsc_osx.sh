#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of Warwick 2016
#
# This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
############################################################################


#Script using relion_star_printable to plot FSC using eye of gnome

echo ''
echo 'Usage: relion_fsc *.star xlow (optional) xhigh (optional)'
echo ''

star=$1
starbase=$(basename "$star" .star)
starfsc=$(echo $starbase'_fsc.png')
fscdat=$(echo $starbase'_fsc.dat')
xlow=$2
xhigh=$3
rln4="FSC_Corrected"
rln5="FSC_UnmaskedMaps"
rln6="FSC_MaskedMaps"
rln7="Correcte_FSC_Phase_Randomized_Masked_Maps"

relion_star_printtable $star data_fsc > $fscdat

fscrow=$(awk '$4<=0.143' $fscdat | head -n 1 | awk '{print $1}')
fscrow=$((fscrow-1))
fsc0p143=$(grep "         "$fscrow $fscdat)
fscx=$(echo $fsc0p143 | awk '{printf $2}')
fscy=$(echo $fsc0p143 | awk '{printf $4}')
fscres=$(echo $fsc0p143 | awk '{printf "%2.2f\n",$3}')
echo "Resolution (FSC 0.143, A):" $fscres
echo ""

gnuplot <<- EOF
set xlabel "Resolution (1/Å)"
set ylabel "FSC"
set yrange [0:1]
set xrange [$xlow:$xhigh]
labels = "$rln4 $rln5 $rln6 $rln7"
set style line 1 lt 5 lw 1 lc rgb "red"     #Lines
set style line 2 lt 5 lw 2 lc rgb "navy"    #FSC_corrected
set style line 3 lt 5 lw 2 lc rgb "orange"     #FSC_UnmaskedMaps
set style line 4 lt 5 lw 2 lc rgb "red"     #FSC_MaskedMaps
set style line 5 lt 3 lw 2 lc rgb "black"    #FSC_Phase_Randomised

set term png
set output "$starfsc"
set title "FSC plot: $star"
set label "  $fscres A" at $fscx,$fscy point pointtype 1
set arrow 1 ls 1 from graph 0,first 0.143 to graph 1,first 0.143 nohead
#plot for [i=4:7] "$fscdat" using 2:i title ''.word(labels, i-3).'' with lines lw 2

plot "$fscdat" using 2:4 title ''.word(labels,1).'' with lines ls 2, \
     "$fscdat" using 2:5 title ''.word(labels,2).'' with lines ls 3, \
     "$fscdat" using 2:6 title ''.word(labels,3).'' with lines ls 4, \
     "$fscdat" using 2:7 title ''.word(labels,4).'' with lines ls 5
EOF

rm -rf relion_fsc.png
ln -s $starfsc relion_fsc.png
open relion_fsc.png
