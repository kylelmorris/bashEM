#!/bin/bash
#

# Test if eman is sourced and available
command -v e2proc2d.py >/dev/null 2>&1 || { echo >&2 "Eman does not appear to be installed or loaded..."; exit 1; }

mapin=$1
sampling=$2
lp=$3

if [[ -z $1 ]] || [[ -z $2 ]] ; then
  echo ""
  echo "Variables empty, usage is $(basename $0) (1) (2) (3)"
  echo ""
  echo "(1) = mapin"
  echo "(2) = angular sampling (deg)"
  echo "(3) = low pass filter (Å - optional)"
  echo ""

  exit
fi

# Make 2D projections of EM density map using eman2
e2project3d.py ${mapin} --outfile=projections_${sampling}.hdf --orientgen=eman:delta=${sampling} --sym=c1 --projector=standard --verbose=1 -f

# Low pass filter the projections
lowpass=$(echo "scale=3; 1/$lp" | bc)
e2proc2d.py projections_${sampling}.hdf projections_LP_${lp}.hdf --process filter.lowpass.gauss:cutoff_freq=${lowpass}

# Convert to mrc
#e2proc2d.py projections.hdf projections.mrc
#e2proc2d.py projections_LP_${lp}.hdf projections_LP_${lp}.mrc

# Tidy up
#rm -rf *.hdf
