#!/bin/bash
#

grep voxel run.out | awk '{print $9}' | cat -n | awk '{print $1*0.25+3.4, $2}' > resmapvoxels.dat

gnuplot <<- EOF
set boxwidth 0.25
set style fill solid
set term png
set output "resmap.png"
plot "resmapvoxels.dat" with boxes
EOF

eog resmap.png
