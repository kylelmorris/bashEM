#!/bin/bash
#
## See Relion FAQ
## http://www2.mrc-lmb.cam.ac.uk/relion/index.php/Grouping_procedure
#

echo "Usage $ make_split_mic *.star"

star=$1

echo "Input star file:" $star

relion_star_printtable $star data_ _rlnDefocusU _rlnMicrographName | sort | uniq -f 1 | awk '{print $2, $1}' > split_mics_defocus.dat

echo "Made split_mics_defocus.dat containing micrgraphs organised by defocus"
echo "Introduce spaces where you want your groups to be and then run:"
echo ""
echo "relion_make_grouped_star.sh on split_mics_defocus.dat to make your grouped *.star file"
