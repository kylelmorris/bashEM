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

# Test if Relion is sourced and available
command -v relion >/dev/null 2>&1 || { echo >&2 "Relion does not appear to be installed or loaded..."; exit 1; }

# Test for correct variable entry
if [[ -z $1 ]] ; then

  echo ""
  echo "Variables empty, usage is $(basename $0) (1) (2) (3) (4)"
  echo ""
  echo "(1) = Post-processing star file"
  echo "(2) = Show plot (0/1, optional)"
  echo "(3) = x-axis low (optional)"
  echo "(4) = x-axis high (optional)"
  echo ""

  exit
fi

#Script using relion_star_printable to plot FSC using eye of gnome

echo ''
echo 'Usage: relion_fsc *.star xlow (optional) xhigh (optional)'
echo ''

star=$1
starbase=$(basename "$star" .star)
starfscall=$(echo $starbase'_fsc_all.png')
starfsc=$(echo $starbase'_fsc_corrected.png')
fscdat=$(echo $starbase'_fsc.dat')
dir=$(dirname $star)
showplot=$2
xlow=$3
xhigh=$4

rln4="Corrected"
rln5="Unmasked-Maps"
rln6="Masked-Maps"
rln7="Phase-Randomized-Maps"

relion_star_printtable $star data_fsc > $fscdat

fscrow=$(awk '$4<=0.143' $fscdat | head -n 1 | awk '{print $1}')
fscrow=$((fscrow-1))
fsc0p143=$(grep "         "$fscrow $fscdat)
fscx=$(echo $fsc0p143 | awk '{printf $2}')
fscy=$(echo $fsc0p143 | awk '{printf $4}')
fscres=$(echo $fsc0p143 | awk '{printf "%2.2f\n",$3}')
echo "Resolution (FSC 0.143, A):" $fscres
echo ""

# Plot with all curves and just corrected
gnuplot <<- EOF
set term pngcairo dashed
set output "${starfscall}"

# Coloring as in original phase randomisation paper
#set style line 1 lt 5 lw 1 lc rgb "red"     #Lines
#set style line 2 lt 5 lw 2 lc rgb "navy"    #FSC_corrected
#set style line 3 lt 5 lw 2 lc rgb "orange"  #FSC_UnmaskedMaps
#set style line 4 lt 5 lw 2 lc rgb "red"     #FSC_MaskedMaps
#set style line 5 lt 3 lw 2 lc rgb "black"   #FSC_Phase_Randomised

# Coloring as in Relion output
set style line 1 lt 5 lw 1 lc rgb "orange"  #Lines
set style line 2 lt 5 lw 2 lc rgb "black"   #FSC_corrected
set style line 3 lt 5 lw 1 lc rgb "green"   #FSC_UnmaskedMaps
set style line 4 lt 5 lw 1 lc rgb "blue"    #FSC_MaskedMaps
set style line 5 lt 3 lw 1 lc rgb "red"     #FSC_Phase_Randomised
set style line 6 lt 1 lw 1 lc rgb "grey"    #Grid

set xlabel "Resolution (1/Å)"
set ylabel "Fourier Shell Correlation"
set yrange [0:1]
set ytics 0.1
#set ytics add ("0.143" 0.143)
set xrange [$xlow:$xhigh]
set xtics 0.05
set grid xtics ytics ls 6
labels = "$rln4 $rln5 $rln6 $rln7"

set title "Final resolution = $fscres Ångstroms"
#set label "  $fscres A" at $fscx,$fscy point pointtype 1
set label "" at $fscx,$fscy point pointtype 1

set arrow 1 ls 1 from graph 0,first 0.143 to graph 1,first 0.143 nohead
set label "0.143" at 0.01,0.163

#plot for [i=4:7] "$fscdat" using 2:i title ''.word(labels, i-3).'' with lines lw 2

plot "$fscdat" using 2:4 title ''.word(labels,1).'' with lines ls 2, \
     "$fscdat" using 2:5 title ''.word(labels,2).'' with lines ls 3, \
     "$fscdat" using 2:6 title ''.word(labels,3).'' with lines ls 4, \
     "$fscdat" using 2:7 title ''.word(labels,4).'' with lines ls 5

set output "${starfsc}"

plot "$fscdat" using 2:4 title ''.word(labels,1).'' with lines ls 2

EOF

mv $starfsc $dir
mv $starfscall $dir
mv $fscdat $dir

# Show plots depending on user input
if [[ $showplot == 1 ]]; then
  eog $dir/$starfscall
  open $dir/$starfscall
elif [[ $showplot == 0 ]]; then
  echo 'Supressing plot output'
else
  echo 'Show plots flag not declared, displaying anyway...'
fi

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
