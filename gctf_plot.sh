#!/bin/bash
#

#Version 1.2

# Files to plot, accepts wild card
filein=$1
nooutput="n"

if [[ -z $1 ]] ; then
  echo ""
  echo "Variables empty, usage is gctf_plot.sh (1) (options)"
  echo ""
  echo "(1) = File in - '' i.e. mic_0001_EPA.log or \"*EPA.log\" for all in cwd"
  echo ""

  exit
fi

# Populate filelist
ls $filein > filelist.dat

if [[ $(echo "$filein") == "*EPA.log" ]]; then
  echo "*EPA.log detected, Will not show graphical output every time"
  nooutput="y"
  echo $nooutput
fi

#Loops through using filelist.dat
i=1
while read p; do
  j=$(echo "$i"p)
  name=$(sed -n ${j} filelist.dat)
  basename=${name%_EPA.log}
  gctflog=${basename}'_gctf.log'
  pngout=${basename}'_gctf_plot.png'

  echo "Working on file:" $pngout
  grep Resolution $name > header.dat

  grep -v Resolution $name | awk '{print 1/$1,$2,$3,$4,$5}' > plot.dat
  cat header.dat plot.dat > gctfplot.dat

  #Gather values
  defocus=$(grep Final ${gctflog} | awk '{print $1,$2,$3}' | tail -n 1)
  ctfvalidation=$(grep -A 6 'Differences from Original Values' ${gctflog} | tail -n 5 | awk '{print $1,$6,$7}')
  EPA=$(grep limit ${gctflog} | awk '{print $7}')
  phase=$(grep Final ${gctflog} | awk '{print $4}' | tail -n 1)

gnuplot <<- EOF
set title "EPA res limit: $EPA\n Phase estimate: $phase\n DefocusUVA: $defocus" font "Arial-Bold, 14"
set xlabel "Spatial Frequency (1/A)"
set ylabel "CTF model"
set y2label "CTF data"
set style line 1 lt 2 lw 2 pt 3 ps 0.5
set term png size 1500,800
set size ratio 0.6
set yrange [-0.5:1.5]
set ytics
set y2tics
set output "gctf_plot.png"
plot "gctfplot.dat" using 1:2 with lines axes x1y1 title "CTF model", \
     "gctfplot.dat" using 1:4 with lines axes x1y2 title "CTF data"
     #"gctfplot.dat" using 1:5 with lines axes x1y1
EOF

  #Tidy up
  rm -rf plot.dat
  rm -rf header.dat
  mv gctf_plot.png ${pngout}

  echo "Saved plot to: "${pngout}

  #Report values
  echo "Defocus estimation: "$defocus
  echo "Validation:         "$ctfvalidation
  echo "EPA res limit:      "$EPA
  echo "Phase estimation:   "$phase
  echo ''

  if [[ $nooutput == "y" ]]; then
    echo "Batch mode - Skipping display of gctf output"
  else
    echo "Displaying gctf output using gpicview"
    gpicview ${pngout}
  fi

  i=$((i+1))
done < filelist.dat

# Tidy up
rm -rf filelist.dat
