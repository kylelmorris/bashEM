#!/usr/bin/env bash
#

star=$1
xlow=$2
xhigh=$3
ylow=$4
yhigh=$5
starbase=$(basename "$star" .star)
starfsc=$(echo $starbase'_localres.png')
fscdat=$(echo $starbase'_localres.dat')
dir=$(dirname $star)

if [[ -z $1 ]] ; then

  echo ""
  echo "Variables empty, usage is relion_fsc (1) (2) (3)"
  echo ""
  echo "(1) = Post-processing localres star file"
  echo "(2) = x-axis low (optional)"
  echo "(3) = x-axis high (optional)"
  echo "(4) = y-axis low (optional)"
  echo "(5) = y-axis high (optional)"
  echo ""

  exit
fi

# -V makes it sort numerically
grep "local resolution= " $star | awk '{print $9}' | sort -V > $dir/$fscdat

# Get high and low resolutions, filter out e+01 numbers
high=$(cat $dir/$fscdat | grep -v + | head -n 1)
low=$(cat $dir/$fscdat | grep -v + | tail -n 1)

# Report high and low resolution
echo ""
echo "Highest resolution (Å): ${high}"
echo "Lowest resolution (Å):  ${low}"
echo ""
echo "Plotting data..."
echo ""

# Plotting
gnuplot <<- EOF
set term png
set output "$dir/$starfsc"
set xrange [$xlow:$xhigh]
set yrange [$ylow:$yhigh]
set style histogram rowstacked gap 0
set style fill solid 0.5 border lt -1
binwidth = 0.2  # set width of x values in each bin
bin(val) = binwidth * floor(val/binwidth)
plot "$dir/$fscdat" using (bin(column(1))):(1.0) smooth frequency with boxes
EOF

open $dir/$starfsc
eog $dir/$starfsc
