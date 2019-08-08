#!/usr/bin/env bash
#

# Get PDBs in directory
ls *pdb > .filelist.dat

# Get map
mapin=$1
pdbin=$2

# Source eman2
module load situs
# Test if eman2 is sourced and available
command -v colores >/dev/null 2>&1 || { echo >&2 "Situs does not appear to be installed or loaded..."; exit 1; }

# Test for input variables
if [[ -z $1 ]] || [[ -z $2 ]] ; then
  echo ""
  echo "Variables empty, usage is $(basename $0) (1) (2)"
  echo ""
  echo "(1) = map"
  echo "(1) = model"
  echo ""

  exit
fi

# Directory and folder names
ext=$(echo ${pdbin##*.})
name=$(basename $pdbin .${ext})
dir=$(dirname $pdbin)

#For saving data
mkdir $name
#Do fitting
colores ${mapin} ${pdbin}
#Organise results
mv col_* $name
