#!/bin/bash
#

# Variables
starin=$1
apix=$2
threads=$3
file=${starin%.star}

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]]; then

  echo ""
  echo "Variables empty, usage is relion_reconstruct_halfmaps.sh (1) (2) (3)"
  echo ""
  echo "(1) = Autorefine *_data.star file in"
  echo "(2) = Pixel size (apix)"
  echo "(3) = Number of threads for reconstruction"
  exit

fi

echo "Input star file: ${starin}"
echo "File basename:   ${file}"
echo "Pixel size:      ${apix}"
echo "Threads:         ${threads}"
echo "Press Enter to continue..."
echo ""
read p

# Make sure directory is clean
rm -rf star1header.dat
rm -rf tmp.dat
rm -rf star1header_trim.dat
rm -rf star1header_trimcol.dat
rm -rf star1lines.dat
rm -rf star1datalines.dat
rm -rf star1datalineshalf1.dat
rm -rf star1datalineshalf2.dat

###############################################################################
# Get column number and data for rlnRandomSubset from starin
###############################################################################
rndsubcol=$(grep "rlnRandomSubset" $starin | awk '{print $2}' | sed 's/#//g')

echo "${starin} particle file columns:"
echo "rlnRandomSubset: $rndsubcol"
echo ""

###############################################################################
# Split starin into header and data lines
###############################################################################
awk '{if (NF > 3) exit; print }' < ${starin} > star1header.dat
awk '{print $1,$2}' star1header.dat | sed '1,4d' > tmp.dat
mv tmp.dat star1header_trim.dat
awk '{print $1}' star1header_trim.dat > star1header_trimcol.dat
diff star1header.dat ${starin} | awk '!($1="")' > star1lines.dat
sed '1d' star1lines.dat > tmp.dat
mv tmp.dat star1datalines.dat

###############################################################################
# Split datalines into half datasets
###############################################################################

awk -v rndsubcol=$rndsubcol '$rndsubcol == 1 {print}' star1datalines.dat > star1datalineshalf1.dat
awk -v rndsubcol=$rndsubcol '$rndsubcol == 2 {print}' star1datalines.dat > star1datalineshalf2.dat
half1no=$(wc -l star1datalineshalf1.dat | awk '{print $1}')
half2no=$(wc -l star1datalineshalf2.dat | awk '{print $1}')

cat star1header.dat star1datalineshalf1.dat > ${file}_half1.star
cat star1header.dat star1datalineshalf2.dat > ${file}_half2.star

# Report useful stuff
echo "Input *_data.star file:    ${starin}"
echo "Input number of ptcls:     $(wc -l star1datalines.dat | awk '{print $1}')"
echo ""
echo "Split ${file}.star into half datasets as per rlnRandomSubset"
echo "See ${file}_half1.star and ${file}_half2.star"
echo ""
echo "${file}_half1.star ptcls: $(wc -l star1datalineshalf1.dat | awk '{print $1}')"
echo "${file}_half2.star ptcls: $(wc -l star1datalineshalf2.dat | awk '{print $1}')"
echo "Sum of half ptcls:         $(bc <<< "scale=1; $half1no+$half2no")"
echo ""

# Make sure directory is clean
rm -rf star1header.dat
rm -rf tmp.dat
rm -rf star1header_trim.dat
rm -rf star1header_trimcol.dat
rm -rf star1lines.dat
rm -rf star1datalines.dat
rm -rf star1datalineshalf1.dat
rm -rf star1datalineshalf2.dat

echo "Proceeding to reconstruct half-maps to Nyquist..."

# Reconstruct half maps to Nyquist
relion_reconstruct --i ${file}_half1.star --o ${file}_half1_class001_unfil.mrc --angpix $2 --j $3 --ctf --fsc > ${file}_half1_reconstruct.log &
echo "$ relion_reconstruct --i ${file}_half1.star --o ${file}_half1_class001_unfil.mrc --angpix ${2} --j ${3} --ctf --fsc > ${file}_half1_reconstruct.log &"

relion_reconstruct --i ${file}_half2.star --o ${file}_half2_class001_unfil.mrc --angpix $2 --j $3 --ctf --fsc > ${file}_half2_reconstruct.log &
echo "$ relion_reconstruct --i ${file}_half2.star --o ${file}_half2_class001_unfil.mrc --angpix ${2} --j ${3} --ctf --fsc > ${file}_half2_reconstruct.log &"

# Useful message
echo ""
echo "Script complete but relion_reconstruct will run in the background"
echo "Use top --> k --> PID if you need to kill"
echo ""
echo "Files written will be:"
echo "${file}_half1.star"
echo "${file}_half1_class001_unfil.mrc"
echo "${file}_half1_reconstruct.log"
echo "${file}_half2.star"
echo "${file}_half2_class001_unfil.mrc"
echo "${file}_half2_reconstruct.log"
echo ""
echo "Check progress by:"
echo "tail -f ${file}_half1_reconstruct.log"
echo "tail -f ${file}_half2_reconstruct.log"
echo ""
echo "Exiting..."
