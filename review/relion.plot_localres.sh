#!/usr/bin/env bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of Berkeley 2017
# MRC London Institute of Medical Sciences 2019
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

# Variables
starin=$1
xlow=$2
xhigh=$3
ylow=$4
yhigh=$5

# Directory and folder names
ext=$(echo ${starin##*.})
name=$(basename $starin .${ext})
dir=$(dirname $starin)

starfsc=$(echo $name'_localres.png')
fscdat=$(echo $name'_localres.dat')

# Test for correct variable entry
if [[ -z $1 ]] ; then

  echo ""
  echo "Variables empty, usage is $(basename $0) (1) (2) (3)"
  echo ""
  echo "(1) = Locres star file"
  echo "(2) = x-axis low (optional)"
  echo "(3) = x-axis high (optional)"
  echo "(4) = y-axis low (optional)"
  echo "(5) = y-axis high (optional)"
  echo ""

  exit
fi

# -V makes it sort numerically
grep "local resolution= " $starin | awk '{print $9}' | sort -V > $dir/$fscdat

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

# Change directory to where *.star file resides
cwd=$(pwd)

# Split star file into individual fsc data
awk -v dir=${dir} '/data_fsc/{n++}{print >dir"/relion_locres_fsc_" n ".star" }' ${starin}
mkdir $dir/locres_fscs
mv $dir/relion_locres_fsc_*star $dir/locres_fscs
cd $dir/locres_fscs
rm -rf $dir/relion_locres_fsc_.star

# Plot individual FSC curves
echo "To plot individual FSC curves run the following command:"
echo "for f in ${dir}/locres_fscs/*star; do relion.plot_fsc.sh \$f 0 ; done"
echo ""

# Return to directory
cd $cwd

# Show resolution range histogram
open $dir/$starfsc
eog $dir/$starfsc

echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
