#!/bin/bash
#

#threshold=0.33

echo "------------------------------------------------------------------"
echo "relion_star_data_plot.sh"
echo "------------------------------------------------------------------"
echo "-i - input star file (required)"
echo "-x - xrange for plotting (format: 0:500)"
echo "-y - yrange for plotting (format: 0:1)"
echo "-l - rlnLogLikeliContribution"
echo "-s - rlnNrOfSignificantSamples"
echo "-p - rlnMaxValueProbDistribution"
echo ""
echo "-m manual column entry         (type column manually)"
echo "------------------------------------------------------------------"

flagcheck=0

while getopts ':-i:lspm:x:y:' flag; do
  case "${flag}" in
    i) starin=$OPTARG
    flagcheck=1 ;;
    l) columnname='rlnLogLikeliContribution'
    flagcheck=1 ;;
    s) columnname='rlnNrOfSignificantSamples'
    flagcheck=1 ;;
    p) columnname='rlnMaxValueProbDistribution'
    flagcheck=1 ;;
    m) columnname=$OPTARG    # For manual input
    flagcheck=1 ;;
    x) xrange=$OPTARG
    flagcheck=1 ;;
    y) yrange=$OPTARG
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
  echo "No column, exiting, I require an input..."
  echo ""
  exit 1
fi

#Get column number in sar file
echo 'star file in:' $starin
echo 'Column name to plot:' $columnname
echo 'xrange:' $xrange
echo 'yrange:' $yrange
echo ''
column=$(grep ${columnname} ${starin} | awk '{print $2}' | sed 's/#//g')
echo $columnname 'is column number:' $column
echo ''

#Send column data to file, filter out empty lines and number particles for plotting
awk -v column=$column -v starin=$starin {'print $column'} $starin | grep -v '^$' | cat -n > columndata.dat
echo 'Number of particles to plot data for:' $(wc -l columndata.dat | awk '{print $1}')

#Filter star file by threshold
if [[ -z $threshold ]] ; then
  cat $starin > tmp.star
else
  awk -v threshold=$threshold -v column=$column '$column < threshold' $starin > tmp.star
fi

awk '{if (NF > 3) exit; print }' < $starin > header.dat
cat header.dat tmp.star > star_sel.star
## Get lines only containing images with stats above threshold
awk -v column=$column {'print $column'} star_sel.star | grep -v '^$' | cat -n > columndatasel.dat
# Get number of particles selected from class
echo 'Number of particles to extract above threshold:' $(wc -l columndatasel.dat | awk {'print $1'})

#gnuplot
gnuplot <<- EOF
set xlabel "x"
set ylabel "y"
set xrange [$xrange]
set yrange [$yrange]
set key outside
set term png size 1200,600
set output "rln_data_plot.png"
plot "columndata.dat"
EOF

gpicview rln_data_plot.png

#gnuplot
gnuplot <<- EOF
set xlabel "x"
set ylabel "y"
set xrange [$xrange]
set yrange [$yrange]
set key outside
set term png size 1200,600
set output "rln_data_plot_sel.png"
plot "columndatasel.dat"
EOF

gpicview rln_data_plot_sel.png

#Tidy up
rm -rf header.dat
rm -rf tmp.star
rm -rf relion_star_plot_data
mkdir relion_star_plot_data
mv columndata.dat relion_star_plot_data
mv columndatasel.dat relion_star_plot_data
mv rln_data_plot.png relion_star_plot_data
mv rln_data_plot_sel.png relion_star_plot_data
mv star_sel.star relion_star_plot_data
echo ''
echo 'Tidying up...'
echo 'Created folder with data and plots in current working directory called relion_star_plot_data'
echo ''
echo 'Done!'
