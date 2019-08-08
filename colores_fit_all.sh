#!/usr/bin/env bash
#

# Get PDBs in directory
ls *pdb > .filelist.dat

# Get map
mapin=$1

# Source eman2
module load situs
# Test if eman2 is sourced and available
command -v colores >/dev/null 2>&1 || { echo >&2 "Situs does not appear to be installed or loaded..."; exit 1; }

# Test for input variables
if [[ -z $1 ]] ; then
  echo ""
  echo "Variables empty, usage is $(basename $0) (1)"
  echo ""
  echo "(1) = map"
  echo ""

  exit
fi

while read p ; do
  # Directory and folder names
  ext=$(echo ${p##*.})
  name=$(basename $p .${ext})
  dir=$(dirname $p)
  #Skip existing completed
  #if [ -d "$name" ]; then
  #  echo "Skipping, $dir exists..."
  #  continue
  #fi
  #For saving data
  mkdir $name
  #Do fitting
  colores ${mapin} ${pdb}
  #Organise results
  mv col_* $name
done < .filelist.dat
