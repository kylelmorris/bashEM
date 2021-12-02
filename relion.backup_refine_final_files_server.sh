#!/bin/bash
#

server=$1
dir=$2
dirout=$3
port=$4

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] ; then

  echo ""
  echo "Variables empty, usage is $(basename $0) (1) (2)"
  echo ""
  echo "(1) = Server"
  echo "(2) = Refine3D directory in"
  echo "(3) = Backup directory out"
  echo "(4) = port number for scp (optional)"
  exit

fi

if [[ -z $3 ]] ; then
  port=22
fi

# Get directory full path
#cwd=$(pwd)
#dirin=$(cd ${dir}; pwd -P) #This is the true path, ignoring symbolic links
#dirname=$(cd ${dir}; pwd) #This is the path including symbolic links
#cd ${cwd}
dirin=$dir
dirname=$dir

# Directory and folder names
ext=$(echo ${dirin##*.})
name=$(basename $dirin .${ext})
dir=$(dirname $dirin)
rlnpath=$(echo $dirname | sed -n -e 's/^.*Refine3D//p')

#Report what's going to happen
echo ''
echo '#########################################################################'
echo ''
echo 'Refine3D directory name to be backed up:'
echo "Refine3D${rlnpath}"
echo ''
echo 'Refine3D directory to be backed up (ignoring symbolic links):'
echo ${dirin}
echo ''
echo 'Backup location is:'
echo ${dirout}
echo ''
echo 'The following directory structure will be created:'
echo "Refine3D${rlnpath}"
echo ''
echo '#########################################################################'
echo ''
echo 'Hit Enter to continue or ctrl-c to quit...'
read p

#Set up directory on local
mkdir -p ${dirout}/Refine3D${rlnpath}

#Write a README to the backup location with the original location of the files
echo "host information (local):" > $dirout/README
hostname -s >> $dirout/README
echo "host information (remote):" >> $dirout/README
echo $server -s >> $dirout/README
echo "" >> $dirout/README
echo "Refine3D location:" >> $dirout/README
echo $(ls -d -1 $dirout) >> $dirout/README
echo "" >> $dirout/README

#Copy files from specified Refine3D directory to backup location
#rsync -aP --rsh=\'ssh -p ${port}\' $dirin/run.job \
rsync -aP $server:"$dirin/run_model.star \
$dirin/run.out \
$dirin/run_class001_angdist.bild \
$dirin/run_class001.mrc \
$dirin/run_data.star \
$dirin/run.err \
$dirin/run_half1_class001_unfil.mrc \
$dirin/run_half2_class001_unfil.mrc \
$dirin/*pipeline* \
$dirin/note.txt" \
${dirout}/Refine3D${rlnpath}

#Copy run note details to README
cat $dirout/note.txt >> $dirout/README
mv $dirin/README ${dirout}/Refine3D${rlnpath}

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
