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
echo "Usage is $(basename $0) (1) (2) (3)"
echo ""
echo "(1) = directory containing *model.star"
echo "(2) = First class number (optional)"
echo "(3) = Last class number (optional)"
echo ""
echo "Note that if you are using this in OSX you will need to edit relion_star_printtable to use gawk"
echo ""

# Test if Relion is sourced and available
command -v relion >/dev/null 2>&1 || { echo >&2 "Relion does not appear to be installed or loaded..."; exit 1; }

if [[ -z $1 ]] ; then
  echo ""
  echo "Location of *model.star needs to be specified..."
  echo "i.e. $(basename $0) ./Class3D/job007"
  echo ""
  exit
else

  dir=$1
  ## Change directory to where *model.star files are
  cwd=$(pwd)
  echo "Changing directory to ${dir}"
  cd ${dir}

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

## Make a backup of the *model.star and work in this directory
mkdir -p class_occupancy/model_star_backup
scp -r *model.star class_occupancy/model_star_backup
cd class_occupancy/model_star_backup

##Extract the class occupancy data from the model.star files
modelfiles=$(ls *model.star*)
iteration=$(ls *model.star* | wc -l)

# Get first class occupancy data
relion_star_printtable run_*000_model.star data_model_classes _rlnClassDistribution > classocc.dat

# Loop through *model files that were found
while read -r line; do
  relion_star_printtable $line data_model_classes _rlnClassDistribution > tmpocc.dat
  paste classocc.dat tmpocc.dat > tmpocc_new.dat
  mv tmpocc_new.dat classocc.dat
done <<< "$modelfiles"

# Old way of looping through model files, doesn't work with non sequential it000, it010, it020
#for (( i=1; i<$iteration; i++ ))
#do
#  j=$(printf "%03d" $i)
#  relion_star_printtable run_*"$j"_model.star data_model_classes _rlnClassDistribution > tmpocc.dat
#  paste classocc.dat tmpocc.dat > tmpocc_new.dat
#  mv tmpocc_new.dat classocc.dat
#done

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
set style line 1 lw 2 lc rgb "#B1B1B1"
set style line 2 lw 2 lc rgb "#E8E99D"
set style line 3 lw 2 lc rgb "#B6F5F4"
set style line 4 lw 2 lc rgb "#BAB8FF"
set style line 5 lw 2 lc rgb "#F8C1FF"
set style line 6 lw 2 lc rgb "#EDA8AA"
set style line 7 lw 2 lc rgb "#A5DF978"
set style line 8 lw 2 lc rgb "#F2CDA4"
set style line 9 lw 2 lc rgb "#A2C5EE"
set style line 10 lw 2 lc rgb "#CBCB94"
set style increment user
set xlabel "Iteration"
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

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
