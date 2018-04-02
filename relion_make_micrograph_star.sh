#!/usr/bin/env bash
#

#echo $BASH_VERSION

noDW="$1"
DW="$2"
dir="$3"

if [[ -z $1 ]] || [[ -z $2 ]] ; then

  echo ""
  echo "Variables empty, usage is $0 (1) (2)"
  echo ""
  echo "(1) = non-dose weighted suffix (must be unique i.e. 'Micrographs/*cor.mrc')"
  echo "(2) = dose-weighted suffix (must be unique i.e. 'Micrographs/*cor2_DW.mrc')"
  echo "Important note! You must use '' if using a wildcard"
  echo ""

  exit
fi

# Create star file header
relion_star_loopheader rlnMicrographName rlnMicrographNameNoDW > header.dat

# Create non-dose weighted mic list
ls $noDW > noDW.dat
echo "Found non-dose weighted $(wc -l noDW.dat | awk '{print $1}') micrographs"
echo ""

# Create dose weighted mic list
ls $DW > DW.dat
echo "Found dose weighted $(wc -l DW.dat | awk '{print $1}') micrographs"
echo ""

# Paste mic columns together
paste DW.dat noDW.dat > miclist.dat

# Tidy up
rm -rf noDW.dat
rm -rf DW.dat

# Combine header and mic list
cat header.dat miclist.dat > micrographs.star

# Tidy up more
rm -rf *dat

# Report back
echo "Done! Created micrographs.star in current working directory"
echo ""
