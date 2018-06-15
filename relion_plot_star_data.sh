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
echo "-t - thresold for filtering data (format: -5:7)"
echo ""
echo "-m manual column entry         (type column manually)"
echo "------------------------------------------------------------------"

flagcheck=0

while getopts ':-i:lspm:x:y:t:' flag; do
  case "${flag}" in
    i) starin=$OPTARG
    flagcheck=0 ;;
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
    t) threshold=$OPTARG
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

#Get input star file basename
file=$(basename $starin .star)

#Remove existing analysis
rm -rf relion_star_plot_data

#Get column number in sar file
echo 'star file in:' $starin
echo 'Column name to plot:' $columnname
echo 'xrange:' $xrange
echo 'yrange:' $yrange
echo ''
column=$(grep ${columnname} ${starin} | awk '{print $2}' | sed 's/#//g')
columnname=$(grep ${columnname} ${starin} | awk '{print $1}' | sed 's/#//g')
echo $columnname 'is column number:' $column
echo ''

#Send column data to file, filter out empty lines and number particles for plotting
awk -v column=$column -v starin=$starin {'print $column'} $starin | grep -v '^$' | cat -n > ${columnname}.dat
echo 'Number of particles to plot data for:' $(wc -l ${columnname}.dat | awk '{print $1}')

#Filter star file by threshold
if [[ -z $threshold ]] ; then
  cat $starin > tmp.star

  awk '{if (NF > 3) exit; print }' < $starin > header.dat
  cat header.dat tmp.star > star_sel.star
  ## Get lines only containing images with stats above threshold
  awk -v column=$column {'print $column'} star_sel.star | grep -v '^$' | cat -n > ${columnname}.dat
  # Get number of particles selected from class
  echo 'Number of particles:' $(wc -l ${columnname}.dat | awk {'print $1'})

#gnuplot
gnuplot <<- EOF
set xlabel "Image number"
set ylabel "${columnname}"
set xrange [$xrange]
set yrange [$yrange]
set key outside
set term png size 1200,600
set output "rln_data_plot.png"
plot "${columnname}.dat"
EOF

  mkdir relion_star_plot_data
  mv ${columnname}.dat relion_star_plot_data
  mv rln_data_plot.png relion_star_plot_data

  gpicview relion_star_plot_data/rln_data_plot.png
  open relion_star_plot_data/rln_data_plot.png

else

  echo ""
  echo "Threshold was set to: ${threshold}"
  thresholdlow=$(echo ${threshold} | cut -d: -f1)
  thresholdhigh=$(echo ${threshold} | cut -d: -f2)
  echo "Threshold low is:  ${thresholdlow}"
  echo "Threshold high is: ${thresholdhigh}"

  awk -v threshold=$thresholdhigh -v column=$column '$column < threshold' $starin > tmp.star
  awk -v threshold=$thresholdlow -v column=$column '$column > threshold' tmp.star > tmp1.star
  mv tmp1.star tmp.star

  awk '{if (NF > 3) exit; print }' < $starin > header.dat
  cat header.dat tmp.star > star_sel.star
  ## Get lines only containing images with stats within threshold
  awk -v column=$column {'print $column'} star_sel.star | grep -v '^$' | cat -n > ${columnname}_sel.dat
  # Get number of particles selected from class
  echo 'Number of particles to extract within threshold:' $(wc -l ${columnname}_sel.dat | awk {'print $1'})

#gnuplot
gnuplot <<- EOF
set xlabel "Image number"
set ylabel "${columnname}"
set xrange [$xrange]
set yrange [$yrange]
set key outside
set term png size 1200,600
set output "rln_data_plot.png"
plot "${columnname}.dat"
EOF

  mkdir relion_star_plot_data
  mv ${columnname}.dat relion_star_plot_data
  mv rln_data_plot.png relion_star_plot_data

#gnuplot
gnuplot <<- EOF
set xlabel "Image number"
set ylabel "${columnname}"
set xrange [$xrange]
set yrange [$yrange]
set key outside
set term png size 1200,600
set output "rln_data_plot_sel.png"
plot "${columnname}_sel.dat"
EOF

  mv ${columnname}_sel.dat relion_star_plot_data
  mv rln_data_plot_sel.png relion_star_plot_data
  mv star_sel.star relion_star_plot_data/${file}_sel.star

  gpicview relion_star_plot_data/rln_data_plot_sel.png
  open relion_star_plot_data/rln_data_plot_sel.png

fi

#Tidy up
rm -rf header.dat
rm -rf tmp.star
rm -rf star_sel.star

echo ''
echo 'Tidying up...'
echo 'Created folder with data and plots in current working directory called relion_star_plot_data'
echo ''
echo 'Done!'
