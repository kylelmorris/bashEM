#!/bin/bash
#

# Find raw movies and timestamps
find ./raw/GridSquare*/Data -name "*fractions.tiff" -printf '%TF %TR 1 %p\n' | sort -n | cat -n | tail > timestamp.dat

# Plot in gnuplot
gnuplot <<- EOF
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%m/%d\n%H:%M"
set xlabel "Time"
set ylabel "Image count"
set key top
set term png size 1200,600
set output "timestamp_plot.png"
plot '<sort filestamps.dat' using 2:1 with points pointtype 0
EOF

open timestamp_plot.png