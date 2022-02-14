#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# eBIC - Diamond Light Source 2021
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

echo "------------------------------------------------------------------"
echo "$(basename $0)"
echo "------------------------------------------------------------------"
echo "-i - input star file (required)"
echo "-c - column to plot (required)"
echo ""
echo "-x - xrange for plotting (format: 0:500)"
echo "-y - yrange for plotting (format: 0:1)"
echo ""
echo "-s - Surpress display (optional) y/n"
echo ""
echo "------------------------------------------------------------------"

flagcheck=0

while getopts ':-i:c:x:y:s:' flag; do
  case "${flag}" in
    i) starin=$OPTARG
    flagcheck=0 ;;
    c) columnname=$OPTARG    # For manual input
    flagcheck=1 ;;
    x) xrange=$OPTARG
    flagcheck=1 ;;
    y) yrange=$OPTARG
    flagcheck=1 ;;
    t) threshold=$OPTARG
    flagcheck=1 ;;
    s) suppress=$OPTARG
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
  echo "Required options not met, exiting."
  echo "Please read initial program instructions..."
  echo ""
  exit 1
fi

# Program display
# https://stackoverflow.com/questions/394230/how-to-detect-the-os-from-a-bash-script/18434831
if [[ "$OSTYPE" == "linux-gnu" ]]; then
        #display=eog
        display="gio open"
elif [[ "$OSTYPE" == "darwin"* ]]; then
        display=open
else
        echo 'OS type unknown'
fi

#Get input star file basename
file=$(basename $starin .star)

#Remove existing analysis
#rm -rf relion_star_plot_data
#rm -rf .relion_star_plot_data

#Use bashEM dependancy to extract > relion3 star file data
relion.star_data_extract.sh $starin .relion_star_plot_data

#Expect the following files with start file data
dataHeader=.relion_star_plot_data/mainDataHeader.dat
# .mainDataLine.dat
dataLines=.relion_star_plot_data/mainDataLines.dat
# .opticsDataHeader.dat
# .opticsDataLines.dat
# .version.dat

#Get column number in sar file
echo "------------------------------------------------------------------"
echo 'star file in:' $starin
echo 'Column name to plot:' $columnname
echo 'xrange:' $xrange
echo 'yrange:' $yrange
echo ''
column=$(grep ${columnname} $dataHeader | awk '{print $2}' | sed 's/#//g')
columnname=$(grep ${columnname} $dataHeader | awk '{print $1}' | sed 's/#//g')
echo $columnname 'is column number:' $column
echo ''

#Send column data to file, filter out empty lines and number images for plotting
awk -v column=$column -v starin=$starin {'print $column'} $dataLines | grep -v '^$' | cat -n > ${columnname}.dat
echo 'Number of images to plot data for:' $(wc -l ${columnname}.dat | awk '{print $1}')

rln_data_plot=rln_data_plot${columnname}.png
rln_data_hist=rln_data_hist${columnname}.png

#gnuplot for data
gnuplot <<- EOF
set xlabel "Image number"
set ylabel "${columnname}"
set xrange [$xrange]
set yrange [$yrange]
set key top
set term png size 1200,600
set output "rln_data_plot.png"
plot "${columnname}.dat"
EOF

# Calculate bin size for 50 bins

#cat ${columnname}.dat | awk '{print $2}' | awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print "avg " total/count," | max "max," | min " min}'
max=$(cat ${columnname}.dat | awk '{print $2}' | awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print max}')
min=$(cat ${columnname}.dat | awk '{print $2}' | awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print min}')

bin=$(echo "((${max})-(${min}))/30" | bc)

# Put data into bins for histogram

awk '{print $2}' ${columnname}.dat | awk '{
        BIN=sprintf("%d", $1*(1/BINSIZE))+0;
        DATA[BIN]++;
        if((!MIN)||(MIN>BIN)) MIN=BIN;
        if((!MAX)||(MAX<BIN)) MAX=BIN;
 }
END {
        for(BIN=MIN; BIN<=MAX; BIN++)
                printf("%+2.0f-%+2.0f\t%d\n", (BIN*BINSIZE), (BIN*BINSIZE)+(BINSIZE), DATA[BIN]);
}' BINSIZE=$bin > ${columnname}_bin.dat

#gnuplot for histogram
gnuplot <<- EOF
set style data histograms
set style fill solid
set xtics rotate
set xlabel "${columnname}"
set ylabel "Frequency"
set xrange [$xrange]
set yrange [$yrange]
set key top
set term png size 1200,600
set output "rln_data_histogram.png"
plot "./${columnname}_bin.dat" using 2:xtic(1)
EOF

mkdir -p relion_star_plot_data
mv ${columnname}.dat relion_star_plot_data
mv rln_data_plot.png relion_star_plot_data/$rln_data_plot

mv ${columnname}_bin.dat relion_star_plot_data
mv rln_data_histogram.png relion_star_plot_data/$rln_data_hist

# Tidy up and show plots
if [[ $suppress == "y" ]] ; then
  echo "Surpressing display..."
elif [[ $suppress == "n" ]] ; then
  $display relion_star_plot_data/$rln_data_plot
  $display relion_star_plot_data/$rln_data_hist
elif [[ -z $suppress ]] ; then
  $display relion_star_plot_data/$rln_data_plot
  $display relion_star_plot_data/$rln_data_hist
fi

#Tidy up
rm -rf header.dat
rm -rf tmp.star
rm -rf star_sel.star

echo ''
echo 'Tidying up...'
echo 'Created folder with data and plots in current working directory called relion_star_plot_data'
echo ''

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
