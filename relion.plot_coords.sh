#!/bin/bash
#

# https://stackoverflow.com/questions/29449675/gnuplot-plot-image-without-white-border

# Variables
if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]] || [[ -z $5 ]] ; then

  echo ""
  echo "Variables empty, usage is ${0} (1) (2) (3) (4) (5)"
  echo ""
  echo "(1) = Star file in"
  echo "(2) = Search term for micrograph to plot coordinates"
  echo "(3) = Detector size px x"
  echo "(4) = Detector size px y"
  echo "(5) = Pick diameter (px)"
  echo "(6) = Surpress output (optional) y/n"
  echo ""
  echo "Common detector sizes:"
  echo "K2: 3838 3710"
  echo "K3: 5760 4092"
  echo "FII: 4096 4096"
  echo "FIII: 4096 4096"
  exit

fi

starin=$1
mic=$2
x=$3
y=$4
d=$5

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

# Plot data
gnuplot <<- EOF
set xrange [0:${x}]
set yrange [0:${y}] reverse
set term png transparent truecolor
set term png size 1024,1024
set autoscale xfix
set autoscale yfix
set margins 0,0,0,0
unset xtics
unset ytics
unset border
unset key
set output "particles.png"
plot ".coordinates.dat" using 1:2:(${d}) with circles lc rgb "green" lw 3
EOF

# Tidy up and show plot
if [[ $5 == "y" ]] ; then
  echo "Surpressing output..."
elif [[ $5 == "n" ]] ; then
  eog particles.png
  open particles.png
fi

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
