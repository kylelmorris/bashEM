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

# As of Relion3 star file formatting changed
# Use relion.star_extract_data.sh to extract data and header lines
# Assumes all of bashEM repository is in $PATH
relion.star_extract_data.sh ${starin}



#Get column name
star_col_df=$(grep "rlnDefocusU" .mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')

#Report column numbers
echo "Found columns rlnDefocusU:   " $star_col_df

# Directory and folder names of star file
ext=$(echo ${starin##*.})
name=$(basename $starin .${ext})
dir=$(dirname $starin)

# Output star file
starout=${dir}/${name}_filtered.${ext}

#Filter by defocus values
awk -v low=${dfUlow} -v high=${dfUhigh} -v col=${star_col_df} ' $col > low && $col < high ' .mainDataLine.dat > .mainDataLine_filtered.dat

#Make new star file
cat .opticsDataLines.dat .mainDataHeader.dat .mainDataLine.dat > $starout

#Tidy up
rm -rf *dat

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
