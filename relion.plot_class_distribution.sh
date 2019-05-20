#!/bin/bash
#

starin=$1

# Test if Relion is sourced and available
command -v relion >/dev/null 2>&1 || { echo >&2 "Relion does not appear to be installed or loaded..."; exit 1; }

echo ""
echo "Usage is $(basename $0) (1)"
echo ""
echo "(1) = *model.star"
echo "(2) = sort or not / 1 or 0 (optional)"
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

# Directory and folder names
ext=$(echo ${starin##*.})
name=$(basename $starin .${ext})
dir=$(dirname $starin)

# Make directory for class occupancy data and plots
mkdir -p ${dir}/class_distribution

# Get total class occupancy
total=$(relion_star_printtable $starin data_model_classes _rlnClassDistribution | awk -F '|' '{sum+=$NF} END {print sum}')

# Print sanity check
echo "Total class occupancy total: ${total}"
echo ""

# Get per class occupancy
if [[ $2 == 1 ]] ; then
  relion_star_printtable $starin data_model_classes _rlnClassDistribution | sort -r | grep -v e > classocc.dat
elif [[ $2 == 0 ]] ; then
  relion_star_printtable $starin data_model_classes _rlnClassDistribution | grep -v e > classocc.dat
elif [[ -z $2 ]]; then
  relion_star_printtable $starin data_model_classes _rlnClassDistribution | grep -v e > classocc.dat
fi
xhigh=$(wc -l classocc.dat | awk {'print $1'})

#format
cat -n classocc.dat > tmp.dat
mv tmp.dat classocc.dat

# Plot data
gnuplot <<- EOF
set xlabel "Class number"
set ylabel "Class % ptcl occupancy"
set xrange [-0.5:]
set xtics 1
set key outside
set term png size 900,400
#set size ratio 0.25
set style fill solid 0.66 border
set boxwidth 0.95
set output "class_occupancy.png"
plot "classocc.dat" using 1:2 with boxes
EOF

# Tidy up and show plot
mv classocc.dat ${dir}/class_distribution/${name}_classocc.dat
mv class_occupancy.png ${dir}/class_distribution/${name}_class_occupancy.png

eog ${dir}/class_distribution/${name}_class_occupancy.png
open ${dir}/class_distribution/${name}_class_occupancy.png

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
