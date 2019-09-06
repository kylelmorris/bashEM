#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
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

# https://stackoverflow.com/questions/29449675/gnuplot-plot-image-without-white-border

echo "------------------------------------------------------------------"
echo "$(basename $0)"
echo "------------------------------------------------------------------"
echo "-i - Star file input (required)"
echo "-m - Search term for micrograph to plot coordinates"
echo "-x - Detector size px x"
echo "-y - Detector size px y"
echo "-d - Pick diameter (px)"
echo "-s - Surpress output (optional) y/n"
echo "-f - Flip coordinates (optional) y/n"
echo ""
echo "------------------------------------------------------------------"

flagcheck=0

while getopts ':-i:m:x:y:d:s:f:' flag; do
  case "${flag}" in
    i) starin=$OPTARG
    flagcheck=0 ;;
    m) mic=$OPTARG
    flagcheck=1 ;;
    x) x=$OPTARG
    flagcheck=1 ;;
    y) y=$OPTARG
    flagcheck=1 ;;
    d) d=$OPTARG    # For manual input
    flagcheck=1 ;;
    s) suppress=$OPTARG
    flagcheck=1 ;;
    f) flip=$OPTARG
    flagcheck=1 ;;
    \?)
      echo ""
      echo "Invalid option, please read initial program instructions..."
      echo ""
      exit 1 ;;
  esac
done

if [ $flagcheck = 0 ] ; then
  echo ""
  echo "No options used, exiting, I require an input..."
  echo ""
  exit 1
fi

# Program display
# https://stackoverflow.com/questions/394230/how-to-detect-the-os-from-a-bash-script/18434831
if [[ "$OSTYPE" == "linux-gnu" ]]; then
        display=eog
elif [[ "$OSTYPE" == "darwin"* ]]; then
        display=open
else
        echo 'OS type unknown'
fi

# Coordinate column names
coord1=rlnCoordinateX
coord2=rlnCoordinateY

#Get column number in sar file
echo ''
echo 'star file in:                ' $starin
echo 'Column name to plot:         ' $coord1
echo 'Column name to plot:         ' $coord2
echo ''
column1=$(grep ${coord1} ${starin} | awk '{print $2}' | sed 's/#//g')
columnname1=$(grep ${coord1} ${starin} | awk '{print $1}' | sed 's/#//g')
column2=$(grep ${coord2} ${starin} | awk '{print $2}' | sed 's/#//g')
columnname2=$(grep ${coord2} ${starin} | awk '{print $1}' | sed 's/#//g')
echo "Column number:                #${column1}"
echo "Column number:                #${column2}"
echo ''

#Report important inputs
echo "Detector size input as (px): ${x} x ${y}"
echo ""

#Send column data to file, filter out empty lines and remove any file path or particle numbering
grep ${mic} ${starin} | awk -v column1=$column1 -v column2=$column2 {'print $column1,$column2'} | grep -v '^$' | sed 's!.*/!!' > .coordinates.dat
#Report how many particles
echo 'Number of particles in star file to plot coordinates:     ' $(wc -l .coordinates.dat | awk '{print $1}')

# Reverse axis for horizontal flip or not
if [[ $flip == y ]]; then
  reverse="reverse"
elif [[ $flip == n ]]; then
  reverse=""
else
  reverse=""
fi

# Output
output="${mic}_particles.png"

# Plot data
gnuplot <<- EOF
set xrange [0:${x}]
set yrange [0:${y}] $reverse
set term png transparent truecolor
set term png size 1024,1024
set autoscale xfix
set autoscale yfix
set margins 0,0,0,0
unset xtics
unset ytics
unset border
unset key
set output "$output"
plot ".coordinates.dat" using 1:2:(${d}) with circles lc rgb "white" lw 3
EOF

# Tidy up and show plot
if [[ $suppress == "y" ]] ; then
  echo "Surpressing output..."
elif [[ $suppress == "n" ]] ; then
  $display ${output}
elif [[ -z $suppress ]] ; then
  $display ${output}
fi

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""

exit
