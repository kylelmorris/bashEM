#!/bin/bash
#

starin=$1

if [[ -z $1 ]] ; then
  echo ""
  echo "Variables empty, usage is relion_star_plot.sh (1)"
  echo ""
  echo "(1) = star in"
  echo ""

  exit
fi

#Detect if CtfFigureOfMerit column exists
Cmax=$(grep rlnCtfMaxResolution $starin)
if [[ -z $Cmax ]] ; then
  echo "No rlnCtfMaxResolution column detected in star file"
  Cmaxflag=0
else
  echo "rlnCtfMaxResolution column detected in star file"
  Cmaxflag=1
fi

#Detect if phaseshift column exists
VPP=$(grep rlnPhaseShift $starin)
if [[ -z $VPP ]] ; then
  echo "No rlnPhaseShift column detected in star file, assuming not VPP data"
  VPPflag=0
else
  echo "rlnPhaseShift column detected in star file, assuming data is from VPP"
  VPPflag=1
fi

#Get data tables
if [[ $VPPflag == 0 ]] && [[ $Cmaxflag == 0  ]]; then
  relion_star_printtable $starin data_ rlnDefocusU rlnDefocusV rlnDefocusAngle rlnCtfFigureOfMerit > starprinttable.dat
fi

if [[ $VPPflag == 1 ]] && [[ $Cmaxflag == 1  ]]; then
  relion_star_printtable $starin data_ rlnDefocusU rlnDefocusV rlnDefocusAngle rlnCtfFigureOfMerit rlnCtfMaxResolution rlnPhaseShift > starprinttable.dat
fi

if [[ $VPPflag == 0 ]] && [[ $Cmaxflag == 1  ]]; then
  relion_star_printtable $starin data_ rlnDefocusU rlnDefocusV rlnDefocusAngle rlnCtfFigureOfMerit rlnCtfMaxResolution rlnPhaseShift > starprinttable.dat
fi

#Awk to create astigmatism column and populate data
if [[ $VPPflag == 0 ]] && [[ $Cmaxflag == 0  ]] ; then
  awk '{print $1,$2,$3,$2-$1,$4,0,0}' starprinttable.dat > tmp.dat
  mv tmp.dat starprinttable.dat
fi
if [[ $VPPflag == 1 ]] && [[ $Cmaxflag == 1  ]] ; then
  awk '{print $1,$2,$3,$2-$1,$4,$5,$6}' starprinttable.dat > tmp.dat
  mv tmp.dat starprinttable.dat
fi
if [[ $VPPflag == 0 ]] && [[ $Cmaxflag == 1  ]] ; then
  awk '{print $1,$2,$3,$2-$1,$4,$5,0}' starprinttable.dat > tmp.dat
  mv tmp.dat starprinttable.dat
fi

#Create Micrograph column and populate
cat -n starprinttable.dat | awk '$1=$1' > tmp.dat
mv tmp.dat starprinttable.dat

#Convert to .csv
cat starprinttable.dat | tr -s '[:blank:]' ',' > tmp.dat
mv tmp.dat starprinttable.dat

#Add header for .csv
(echo "Micrograph,DefocusU,DefocusV,DefocusA,Astigmatism,CtfFigureOfMerit,CtfMaxResolution,PhaseShift" ; cat starprinttable.dat) > tmp.dat
mv tmp.dat defocus.csv

#Tidy up
#rm -rf starprinttable.dat
#rm -rf defocus.dat

#Run python plotting script
relion_plot_star_metrics.py

#Move plots
file=$(basename $starin .star)
dir=$(echo "${file}_plots")
mkdir $dir
mv relion_star_plot* $dir
mv defocus.csv $dir

#Open plots
cd $dir
open relion_star_plot_all_data.png
open relion_star_plot_all_dist.png
eog relion_star_plot_all_data.png &
eog relion_star_plot_all_dist.png &

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
