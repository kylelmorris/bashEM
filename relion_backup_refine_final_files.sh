#!/bin/bash
#

dirin=$1
dirout=$2

if [[ -z $1 ]] || [[ -z $2 ]] ; then

  echo ""
  echo "Variables empty, usage is ${0} (1) (2)"
  echo ""
  echo "(1) = Refine3D directory in"
  echo "(2) = rsync backup directory out"
  exit

fi

#Write a README to the backup location with the original location of the files
echo "host information:" > $dirout/README
hostname -s >> $dirout/README
hostname -I >> $dirout/README
echo "" >> $dirout/README
echo "Refine3D location" >> $dirout/README
echo $(ls -d -1 $PWD/$dirin) >> $dirout/README
echo "" >> $dirout/README
cat $dirin/note.txt >> $dirout/README

#Copy files from specified Refine3D directory to backup location
rsync -aP $dirin/run.job $dirout
rsync -aP $dirin/run_model.star $dirout
rsync -aP $dirin/run.out $dirout
rsync -aP $dirin/run_sampling.star $dirout
rsync -aP $dirin/run_class001_angdist.bild $dirout
rsync -aP $dirin/run_class001.mrc $dirout
rsync -aP $dirin/run_data.star $dirout
rsync -aP $dirin/run.err $dirout
rsync -aP $dirin/run_half1_class001_unfil.mrc $dirout
rsync -aP $dirin/run_half2_class001_unfil.mrc $dirout
rsync -aP $dirin/*pipeline* $dirout
rsync -aP $dirin/note.txt $dirout
