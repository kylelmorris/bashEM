#!/bin/bash
#

starin=$1
dfUlow=$2
dfUhigh=$3

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]]; then

  echo ""
  echo "Variables empty, usage is $(basename $0) (1) (2) (3)"
  echo ""
  echo "(1) = star to filter"
  echo "(2) = lowest defocus (Angstroms)"
  echo "(2) = highest defocus (Angstroms)"
  echo ""
  exit

fi

#Get header of star1
awk '{if (NF > 3) exit; print }' < ${starin} > star1header.dat

#Get datalines of star1 and remove blank lines
diff star1header.dat ${starin} | awk '!($1="")' > star1lines.dat
sed '/^\s*$/d' star1lines.dat > tmp.dat
mv tmp.dat star1lines.dat

#Get column name
star_col_df=$(grep "rlnDefocusU" star1header.dat | awk '{print $2}' | sed 's/#//g')

#Report column numbers
echo "Found columns rlnDefocusU:   " $star_col_df

#Get filename
file=$(basename $starin .star)
starout=${file}_filtered.star

#Filter by defocus values
awk -v low=${dfUlow} -v high=${dfUhigh} -v col=${star_col_df} ' $col > low && $col < high ' star1lines.dat > star1linesout.dat

#Make new star file
cat star1header.dat star1linesout.dat > $starout

#Tidy up
rm -rf *dat

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
