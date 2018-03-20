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
echo "Class occupancy script for Relion, Kyle Morris University of Warwick 2015"
echo ""
echo "This will plot the class occupancy of Class3D files from Relion 1.3"
echo "Note: This script uses Eye Of Gnome to display the class_occupancy.png"
echo "*************************************************************************"

classfirst=$1 ; CF=$(printf "%03d" $classfirst) # Use CF variable in script
classlast=$2 ; CL=$(printf "%03d" $classlast) # Use CL variable in script

#Test if input variables are empty (if or statement)

if [[ -z $1 ]] || [[ -z $2 ]] ; then

  echo ""
  echo "Variables empty, usage is 3Dclass_occupancy (1) (2) (3) (4)"
  echo ""
  echo "(1) = First class number"
  echo "(2) = Last class number"
  echo "(3) = Low iteration (x) value to plot (optional)"
  echo "(4) = High iteration (x) value to plot (optional)"
  echo ""

  exit

else

  echo "***********************************************************************"
  echo "Printing class occupancy for class"$CF" to class"$CL
  echo "***********************************************************************"

  #Print the raw class occupancy data to terminal

  for (( i=$classfirst; i<=$classlast; i++ ))
  do
	  j=$(printf "%03d" $i)
	  grep class$j *model.star
  done

  echo ""
  echo "***********************************************************************"
  echo "Printed class occupancy for class"$CF" to class"$CL
  echo ""
  echo "Now working on graphical plot..."
  echo "***********************************************************************"
  echo ""

  #User input x-axis
  xlow=$3
  xhigh=$4

  #Grab data from *model.star and write *.dat files for this

  for (( i=$classfirst; i<=$classlast; i++ ))
  do
	j=$(printf "%03d" $i)
	grep class$j *model.star | awk '{print $2}' > class$j.dat
  done

  #Populate class_occupancy.dat file with individual class data

  #class001.dat into tmp file
  k=$(printf "%03d" "1")
  paste class$k.dat > tmp.dat
  echo "class"$k

  #if more than one class for plotting loop through other class files, otherwise do nothin
  if [ $classlast -gt 1 ]
  then
	for (( i=$classfirst; i<$classlast; i++ ))
	do
		  j=$((i+1))
		  j=$(printf "%03d" $j)
		  echo "class"$j
		  paste tmp.dat class$j.dat > tmp2.dat
		  paste tmp2.dat > tmp.dat	
	done

	rm -rf tmp2.dat
  fi

  #make final file containing all data
  mv tmp.dat class_occupancy.dat

  #Remove individual class###.dat files

  for (( i=$classfirst; i<=$classlast; i++ ))
  do
	j=$(printf "%03d" $i)
	rm -rf class$j.dat
  done

fi

#Gnu plot 

smoothlines=$(wc -l class_occupancy.dat | awk '{print $1}')

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

eog class_occupancy.png &
