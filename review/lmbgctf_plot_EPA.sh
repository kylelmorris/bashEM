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

echo "*************************************************************************"
echo "Kyle Morris University of Warwick 2016"
echo ""
echo "Note: This script uses Eye Of Gnome"
echo "*************************************************************************"

EPAin=$1
pngout=$2

if [[ -z $1 ]] || [[ -z $2 ]] ; then

  echo ""
  echo "Variables empty, usage is lmbgctf_plot_EPA.sh (1) (2)"
  echo ""
  echo "(1) = EPA log file"
  echo "(2) = .png out"
  echo ""

  exit

fi

cat $EPAin | sed 1d | awk '{print $1=1/$1,$2,$3,$4,$5}' > plotEPA.dat

cat plotEPA.dat

gnuplot <<- EOF
set term png size 1200, 480
set xlabel "Resolution (1/Å)"
set ylabel "CTF"
set y2tics
set y2label "CTF"
set yrange [-1:2]
#set logscale y2 2
labels = "CTFsim EPA(Ln|F) EPA(Ln|F|-Bg) CCC)"
set style line 1 lt 5 lw 1 lc rgb "red"     #CTFsim
set style line 2 lt 5 lw 1 lc rgb "navy"    #EPA(Ln|F)
set style line 3 lt 5 lw 1 lc rgb "orange"  #EPA(Ln|F|-Bg)
set style line 4 lt 5 lw 1 lc rgb "red"     #CCC
set style line 5 lt 3 lw 1 lc rgb "black"   #

set term png
set output "$pngout"
set title "EPA plot: $EPAin"

plot "plotEPA.dat" using 1:2 title ''.word(labels,1).'' with lines ls 2 axes x1y1, \
     "plotEPA.dat" using 1:4 title ''.word(labels,3).''with lines ls 4 axes x1y2
EOF

rm -rf plotEPA.dat
open $pngout
eog $pngout

#plot "plotEPA.dat" using 1:2 title ''.word(labels,1).'' with lines ls 2, \ #CTFsim
#     "plotEPA.dat" using 1:3 title ''.word(labels,2).'' with lines ls 3, \ #EPA(Ln|F)
#     "plotEPA.dat" using 1:4 title ''.word(labels,3).''with lines ls 4     #EPA(Ln|F|-Bg)

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
