#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of California Berkeley 2017
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
##Test if input variables are empty (if or statement)

echo ""
echo "Usage is $(basename $0) (1)"
echo ""
echo "(1) = directory containing run.out"
echo "i.e. $(basename $0) ./Refine3D/job007"
echo ""

dir=$1
## Change directory to where *model.star files are
cwd=$(pwd)
echo "Changing directory to ${dir}"
cd ${dir}

if [[ -e run.out ]] ; then
  echo "run.out exists, proceeding to plot..."
else
  echo "run.out does not exist, exiting!"
  exit
fi

#Tidy directory
rm -rf tmp*.dat
rm -rf run_data.out

echo "Iteration#1 Resolution#2 AngSamp#3 XYSamp#4 AngChange#5 XYChange#6 AngAccuracy#7 XYAccuracy#8 AngStep#9" > tmp0.dat

grep "CurrentResolution" run.out | awk '{print $2}' | cat -n > tmp2.dat
grep -A2 "Oversampling= 1" run.out |  grep -v "Oversampling= 1" | grep -v "TranslationalSampling" | awk '{print $2}' | grep -v ^$ > tmp3.dat
grep -A2 "Oversampling= 1" run.out |  grep -v "Oversampling= 1" | grep -v "OrientationalSampling" | awk '{print $2}' | grep -v ^$ > tmp4.dat
grep "Changes in angles" run.out | awk '{print $5,$10}' > tmp5.dat
grep "accuracy" run.out | awk '{print $5,$8}' > tmp6.dat
grep "Angular step" run.out | awk '{print $4}' > tmp7.dat

paste tmp2.dat tmp3.dat tmp4.dat tmp5.dat tmp6.dat tmp7.dat > tmp1.dat

cat tmp0.dat tmp1.dat > run_data.out

rm -rf tmp*.dat

gnuplot <<- EOF
set title "Relion refinement statistics per iteration" font "Arial-Bold, 14" tc rgb "black"
set xlabel "Iteration no"
set ylabel "Resolution (Angstroms)" font "Arial-Bold, 14" tc rgb '#2c7fb8'
set y2label "Angular (deg) and translational (px) accuracy" font "Arial-Bold, 14" tc rgb 'orange'
#set y2label "CTF data"
set style line 1 lt 2 lw 2 pt 3 ps 0.5
set term png size 1500,800
set size ratio 0.6
set yrange [0:]
set y2range [0:]
set grid ytics lc rgb "#bbbbbb" lw 1 lt 0
set grid xtics lc rgb "#bbbbbb" lw 1 lt 0
set xtics tc rgb 'black' font ",13"
set ytics nomirror tc rgb '#2c7fb8' font ",14"
set y2tics nomirror tc rgb 'orange' font ",14"
set style line 1 lc rgb '#2c7fb8' lt 1 lw 3 #blue
set style line 2 lc rgb '#7fcdbb' lt 1 lw 2  #green
set style line 3 lc rgb 'orange' lt 1 lw 2
set style line 4 lc rgb 'black' lt 0 lw 1
set key autotitle columnhead
set output "run_data_plot.png"
#See http://stackoverflow.com/questions/16736861/pointtype-command-for-gnuplot
plot "run_data.out" using 1:7:3 w yerrorbars ls 2 axes x1y2 title "Angular accuracy +/- ang sampling", \
     "run_data.out" using 1:8:4 w yerrorbars ls 3 axes x1y2 title "XY sampling +/- XY sampling", \
     "run_data.out" using 1:7 with lines ls 4 axes x1y2 title "", \
     "run_data.out" using 1:8 with lines ls 4 axes x1y2 title "", \
     "run_data.out" using 1:2 with lines ls 1 axes x1y1 title "Resolution"
EOF

#"run_data.out" using 1:3 with points pointtype 27 axes x1y2 title "Angular sampling", \
#"run_data.out" using 1:4 with points pointtype 27 axes x1y2 title "XY sampling", \
#"run_data.out" using 1:7 with points pointtype 6 axes x1y2 title "Angular accuracy", \
#"run_data.out" using 1:8 with points pointtype 18 axes x1y2 title "XY accuracy"
#"run_data.out" using 1:9 with points pointtype 3 axes x1y2 title "Angular step"

open run_data_plot.png
eog run_data_plot.png

# Change back to original working directory
cd $cwd

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
