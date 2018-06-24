#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of Berkeley 2017
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
echo "Class occupancy script for Relion, Kyle Morris University of California Berkeley 2016"
echo ""
echo "This will plot the class occupancy from *_model.star files from Relion 2.0"
echo "Note: This script uses Eye Of Gnome to display the class_occupancy.png"
echo "*************************************************************************"

##Test if input variables are empty (if or statement)

echo ""
echo "Usage is relion_class_occupancy (1) (2) (3)"
echo ""
echo "(1) = directory containing *model.star"
echo "(2) = First class number (optional)"
echo "(3) = Last class number (optional)"
echo ""
echo "Note that if you are using this in OSX you will need to edit relion_star_printtable to use gawk"
echo ""

if [[ -z $1 ]] ; then
  echo ""
  echo "Location of *model.star needs to be specified..."
  echo ""
  exit
else
  dir=$1
  if [[ -z $2 ]] || [[ -z $3 ]] ; then
    echo ""
    echo "No variables provided analysing all classes"
    echo ""
    classfirst=1
    classlast=$(ls *model.star* | wc -l)
  else
    echo ""
    echo "Analysing all classes, but plotting" $1 "to" $2
    echo ""
    #classfirst=$1 ; CF=$(printf "%03d" $classfirst) # Use CF variable in script
    #classlast=$2 ; CL=$(printf "%03d" $classlast) # Use CL variable in script
    classfirst=1
    classlast=$(ls *model.star* | wc -l)
    xlow=$1
    xhigh=$2
  fi
fi

## Change directory to where *model.star files are
cwd=$(pwd)
cd $dir

## Make a backup of the *model.star
mkdir -p class_occupancy/model_star_backup
scp -r *model.star class_occupancy/model_star_backup

##Print the raw class occupancy data to terminal
iteration=$(ls *model.star* | wc -l)

relion_star_printtable run_*000_model.star data_model_classes _rlnClassDistribution > classocc.dat

for (( i=1; i<$iteration; i++ ))
do
  j=$(printf "%03d" $i)
  relion_star_printtable run_*"$j"_model.star data_model_classes _rlnClassDistribution > tmpocc.dat
  paste classocc.dat tmpocc.dat > tmpocc_new.dat
  mv tmpocc_new.dat classocc.dat
done

# Transpose (http://stackoverflow.com/questions/25062169/using-bash-to-sort-data-horizontally)
transpose () {
  gawk '{for (i=1; i<=NF; i++) a[i,NR]=$i; max=(max<NF?NF:max)}
        END {for (i=1; i<=max; i++)
              {for (j=1; j<=NR; j++)
                  printf "%s%s", a[i,j], (j<NR?OFS:ORS)
              }
        }'
}

cat classocc.dat | transpose > tmpocc.dat
mv tmpocc.dat class_occupancy.dat
cat class_occupancy.dat

rm -rf tmpocc.dat
rm -rf tmpocc_new.dat

##Gnu plot
smoothlines=$(wc -l class_occupancy.dat | gawk '{print $1}')

if (($smoothlines > 3))
then
	echo ''
	echo 'More than 4 data points, using smooth lines for plot'
	echo ''
	lines='with lines lw 2 smooth bezier'
else
	echo ''
	echo 'Fewer than 4 data points, using normal lines for plot'
	lines='with lines lw 2'
	echo ''
fi

gnuplot <<- EOF
set xlabel "3D classification iteration"
set ylabel "Class % ptcl occupancy"
set xrange [$xlow:$xhigh]
set key outside
set term png size 900,400
set size ratio 0.6
set output "class_occupancy.png"
plot for [i=$classfirst:$classlast] "class_occupancy.dat" using i title 'class' .i $lines
EOF

mv class_occupancy.dat class_occupancy
mv class_occupancy.png class_occupancy
mv classocc.dat class_occupancy

eog class_occupancy/class_occupancy.png &
open class_occupancy/class_occupancy.png &

# Change back to original working directory
cd $cwd
