#!/bin/bash
#

starin=$1

# Test if Relion is sourced and available
command -v relion >/dev/null 2>&1 || { echo >&2 "Relion does not appear to be installed or loaded..."; exit 1; }

echo ""
echo "Usage is $(basename $0) (1)"
echo ""
echo "(1) = *model.star"
echo ""
echo "Note that if you are using this in OSX you will need to edit relion_star_printtable to use gawk"
echo ""

if [[ -z $1 ]] ; then
  echo ""
  echo "Location of *model.star needs to be specified..."
  echo "i.e. $(basename $0) ./Class3D/job007/run_it025_model.star"
  echo ""
  exit
fi

# Get total class occupancy
total=$(relion_star_printtable $starin data_model_classes _rlnClassDistribution | awk -F '|' '{sum+=$NF} END {print sum}')

# Print sanity check
echo "Total class occupancy total: ${total}"
echo ""

# Get per class occupancy
relion_star_printtable $starin data_model_classes _rlnClassDistribution | sort -r | grep -v e > classocc.dat
xhigh=$(wc -l classocc.dat | awk {'print $1'})

# Plot data

gnuplot <<- EOF
set xlabel "Class number"
set ylabel "Class % ptcl occupancy"
set xrange [-3:$xhigh]
set key outside
set term png size 900,400
set size ratio 0.6
set output "class_occupancy.png"
plot "classocc.dat" with boxes
EOF

eog class_occupancy.png
