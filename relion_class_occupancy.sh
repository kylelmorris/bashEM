#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of California Berkeley 2016
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

echo "*************************************************************************************"
echo "Class occupancy script for Relion, Kyle Morris University of California Berkeley 2016"
echo ""
echo "This will plot the class occupancy for select *_model.star files from Relion 2.0"
echo "Note: This script uses Eye Of Gnome to display the class_occupancy.png"
echo "*************************************************************************************"

# Test if input variables are empty (if or statement)
echo ""
echo "Usage is relion_class_occupancy (1)"
echo ""
echo "(1) = Iteration to plot classes for"
echo ""

if [[ -z $1 ]] ; then
  echo ""
  echo "No variables provided analysing all classes"
  echo ""
  exit
fi

# Set up user input variables
iteration=$1
j=$(printf "%03d" $iteration)

# Check if analysis has already been done
DIR=$(echo run_it"$j"_classes)
if [ -d "$DIR" ]; then
  echo "Class analysis directory already exists..."
  echo ""
  echo "Do you want to overwrite? yes (y) or quit (q)"
  read continue
  if [ $continue == q ] ; then
    exit
  elif [ $continue == y ] ; then
    rm -rf $DIR
  else
    exit
  fi
else
  echo "No existing class analysis directory, continuing..."
  echo ""
fi

##############################################################################################################################
## The following will analyse the class distribution based on the _model.star file
##############################################################################################################################

## Get number of ptcls
#Get header of star1
awk '{if (NF > 3) exit; print }' < run_it"$j"_data.star > run_it"$j"_data_header.star

totallines=$(wc -l run_it"$j"_data.star | awk {'print $1'})
headerlines=$(wc -l run_it"$j"_data_header.star | awk {'print $1'})
ptcllines=$((totallines-headerlines))

rm -rf run_it"$j"_data_header.star

echo '#########################################'
echo 'File:' run_it"$j"_data.star
echo 'Number of ptcls in star file:' $ptcllines
echo '#########################################'

rm -rf run_it"j"_data_header.star

## Extract class distribution
echo ""
echo "Analysing class distribution for iteration" $j
echo ""

relion_star_printtable run_it"$j"_model.star data_model_classes _rlnClassDistribution | cat -n > run_it"$j"_model_class_dist.dat

## Calculate percentages and populate .dat file
while read p; do
  #echo $p
  prct=$(echo $p | awk '{print $2}')
  S=$(echo $prct*$ptcllines | bc -l)
  echo ${S%.*} >> run_it"$j"_model_class_pct.dat
done < run_it"$j"_model_class_dist.dat

paste run_it"$j"_model_class_dist.dat run_it"$j"_model_class_pct.dat > tmp.dat

## Tidy up
cp tmp.dat run_it"$j"_model_class_dist.dat
rm -rf run_it"$j"_model_class_pct.dat

#cat run_it"$j"_model_class_dist.dat
# Sort the .dat file to find the top classes (-numberic -reverse -k3 column 3)
sort -nrk3 run_it"$j"_model_class_dist.dat | cat -n > run_it"$j"_model_class_dist_sort.dat
classno=$(e2iminfo.py run_it"$j"_classes.mrcs | awk {'print $2'} | sed -n 1p)

##############################################################################################################################
## The following code will plot the class average distribution
##############################################################################################################################

cp -r run_it"$j"_model_class_dist_sort.dat tmp.dat

# Gnu plot for relative percentage values
rm -rf class_occupancy.png
gnuplot <<- EOF
set xlabel "Class #"
set ylabel "Class occupancy %"
set boxwidth 0.5
set style fill solid
set term png
set output "class_occupancy.png"
# The following will plot percentages
plot "tmp.dat" using 2:3:xtic(1) with boxes lc rgb"purple"
EOF

# Gnu plot for absolute values
rm -rf class_occupancy_abs.png
gnuplot <<- EOF
set xlabel "Class #"
set ylabel "Class occupancy %"
set boxwidth 0.5
set style fill solid
set term png
set output "class_occupancy_abs.png"
# The following will plot absolute numbers
plot "tmp.dat" using 2:4:xtic(1) with boxes lc rgb"purple"
EOF

# Gnu plot for sorted absolute values
rm -rf class_occupancy_sorted.png
gnuplot <<- EOF
set xlabel "Class # (sorted ascending)"
set ylabel "Class occupancy %"
set grid xtics mxtics
set mxtics 25
set grid
set boxwidth 0.5
set style fill solid
set term png
set output "class_occupancy_sorted.png"
# The following will plot absolute numbers
plot 'tmp.dat' using 1:4:xtic(1) with boxes lc rgb"purple"
EOF

# Tidy up
rm -rf tmp.dat

## The following will display the class distribution results
eog class_occupancy.png &
eog class_occupancy_abs.png &
eog class_occupancy_sorted.png &

open class_occupancy.png &
open class_occupancy_abs.png &
open class_occupancy_sorted.png &

##############################################################################################################################
## The following code will split the class average stack and move the top classes into a seperate folder for inspection
##############################################################################################################################

# Unstacking by eman2
echo ""
echo "Unstacking using eman2"
echo ""
e2proc2d.py --unstacking run_it"$j"_classes.mrcs mrc
mkdir run_it"$j"_classes
mv mrc-* run_it"$j"_classes
# Make directories to store sorted classes
mkdir run_it"$j"_classes/top
mkdir run_it"$j"_classes/topless
echo ""

# Ask user for threshold particle occupancy to sort most highly populated classes
echo "Enter particle occupancy threshold for sorting or quit (q)"
echo ""
read threshold

if [ $threshold == q ] ; then
  e2proc2d.py --verbose 0 run_it"$j"_classes/*.mrc run_it"$j"_classes/@.png
  mv run_it"$j"_classes/*.mrc run_it"$j"_classes/top
  mv run_it"$j"_classes/*.png run_it"$j"_classes/top
else

  ##Get top percentile of classes
  #top=$((classno/100*20))
  #echo ""
  #echo "Top 20% of classes:" $top "out of" $classno "classes"
  #echo ""
  #head -n $top run_it"$j"_model_class_dist_sort.dat > run_it"$j"_model_class_dist_sort_top.dat

  # Get class numbers of most abundently populated classes
  awk -v threshold="$threshold" '$4 > threshold' run_it"$j"_model_class_dist_sort.dat | awk {'print $2'} > top.dat
  #awk {'print $2'} run_it"$j"_model_class_dist_sort_top.dat > top.dat

  # Move most abundently populated classes into seperate directory
  while read p; do
    n=$(printf "%03d" $p)
    echo "Moving: mrc-${n}.mrc"
    mv run_it"$j"_classes/mrc-${n}.mrc run_it"$j"_classes/top
  done < top.dat
  rm -rf top.dat
  rm -rf run_it"$j"_model_class_dist_sort_top.dat

  mv run_it"$j"_classes/*.mrc run_it"$j"_classes/topless
  echo ""

  # Convert .mrc class averages into .png for easy powerpoint insertion to impress your boss
  e2proc2d.py --verbose 0 run_it"$j"_classes/top/*.mrc run_it"$j"_classes/top/@.png
  e2proc2d.py --verbose 0 run_it"$j"_classes/topless/*.mrc run_it"$j"_classes/topless/@.png

  # Use relion_display manual pick to bring up a display panel for saving a star file to these classes
  `which relion_manualpick` --i "run_it${j}_classes/top/*.mrc" --o selected_micrographs_ctf.star --pickname manualpick --scale 1 --sigma_contrast 3 --black 0 --white 0 --lowpass 0 --angpix 1 --ctf_scale 1 --particle_diameter 200 &

fi

##############################################################################################################################
# Finish up
##############################################################################################################################

# Tidy up
mv class_occupancy.png run_it"$j"_classes
mv class_occupancy_abs.png run_it"$j"_classes
mv class_occupancy_sorted.png run_it"$j"_classes
mv run_it"$j"_model_class_dist.dat run_it"$j"_classes
mv run_it"$j"_model_class_dist_sort.dat run_it"$j"_classes

echo ""
echo "Files written:"
echo "class_occupancy.png"
echo "class_occupancy_abs.png"
echo "class_occupancy_sorted.png"
echo ""
echo "Class averages with particle occupany above" $threshold "particles moved to top directory"

echo ""
echo "Done!"
echo ""
