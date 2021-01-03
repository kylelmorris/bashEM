#!/usr/bin/env bash
#

# Get PDBs in directory
ls *pdb > .filelist.dat

# Get map
mapin=$1
pdbin=$2

# Test for input variables
if [[ -z $1 ]] || [[ -z $2 ]] ; then
  echo ""
  echo "Variables empty, usage is $(basename $0) (1) (2)"
  echo ""
  echo "(1) = map"
  echo "(2) = model"
  echo "(3) = flip map? y/n (Requires Relion)"
  echo ""

  exit
fi

# Directory and folder names
dir=$(dirname $pdbin)
# model
ext=$(echo ${pdbin##*.})
name=$(basename $pdbin .${ext})
nameflip=$(echo $name"_zflip")
# map
ext=$(echo ${mapin##*.})
name=$(basename $mapin .${ext})
mapflip=$(echo $name"_zflip")

# Source situs
module load situs
# Test if Situs is sourced and available
command -v colores >/dev/null 2>&1 || { echo >&2 "Situs does not appear to be installed or loaded..."; exit 1; }

# Work with Relion if map flip is requested
if [[ -z $3 ]] ; then
  echo 'Map flip not requested, Relion not required...'
else
  # Test if Relion is sourced and available
  command -v relion >/dev/null 2>&1 || { echo >&2 "Relion does not appear to be installed or loaded..."; exit 1; }
  relion_image_handler --i ${mapin} --o ${mapflip} --flipZ
fi

#For saving data
mkdir $name

#Do fitting
colores ${mapin} ${pdbin}

exit

#Organise results
scp -r ${mapin} ${name}
scp -r ${mapflip} ${name}
mv col_* $name
