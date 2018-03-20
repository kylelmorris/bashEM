#!/bin/bash
#

pdb=$1
map=$2
half1=$3
half2=$4

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]] ; then

  echo ""
  echo "Variables empty, usage is phenix.map_model_fsc.sh (1) (2) (3) (4) (5)"
  echo ""
  echo "(1) = pdb"
  echo "(2) = map"
  echo "(3) = half map 1"
  echo "(4) = half map 2"
  echo '(5) = pixel size'
  echo ""
  exit

fi

if [ -e "fsc_model.mtriage.log" ] ; then
  echo 'fsc_model.mtriage log exist, would you like to recalculate (y) or only plot (n)?'
  echo ''
  read p
  if [[ $p == "y" ]] ; then
    echo "OK, removing existing logs and calculating using phenix.mtriage"
    echo ''
    rm -rf *mtriage.log
    # Run FSC and map model FSC
    phenix.mtriage model_file_name=$pdb map_file_name=$map half_map_file_name_1=$half1 half_map_file_name_2=$half2
  elif [[ $p == "n" ]] ; then
    echo "OK, just plotting existing results..."
    echo ''
  else
    echo 'Input error, exiting...'
    exit
  fi
fi

# Plot range

echo 'Plotting...'

# Plot FSC and map model FSC
gnuplot <<- EOF
set xlabel "Resolution (1/Å)"
set ylabel "FSC"
set yrange [0:1]
set xrange [0:0.467]
labels = "map model"
set style line 1 lt 5 lw 1 lc rgb "red"     #Lines
set style line 2 lt 5 lw 2 lc rgb "navy"    #FSC_corrected
set style line 3 lt 5 lw 2 lc rgb "orange"     #FSC_UnmaskedMaps
set style line 4 lt 5 lw 2 lc rgb "red"     #FSC_MaskedMaps
set style line 5 lt 3 lw 2 lc rgb "black"    #FSC_Phase_Randomised

set term png
set output "fsc_plot.mtriage.png"
set title "FSC plot by phenix.mtriage"
#set label "  $fscres A" at $fscx,$fscy point pointtype 1
set arrow 1 ls 1 from graph 0,first 0.143 to graph 1,first 0.143 nohead

plot "fsc_half_maps.mtriage.log" using 1:2 title ''.word(labels,1).'' with lines ls 2, \
     "fsc_model.mtriage.log" using 1:2 title ''.word(labels,2).'' with lines ls 3
EOF

gpicview fsc_plot.mtriage.png &
