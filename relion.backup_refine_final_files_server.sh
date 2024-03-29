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
rlnpath=$(echo $dirname | sed -n -e 's/^.*Refine3D//p' | cut -d'/' -f2-)

#Set up directory on local
mkdir -p ${dirout}/Refine3D/${rlnpath}

##Write a README to the backup location with the original location of the files
# Remote host
echo "host information (local):" > ${dirout}/Refine3D/${rlnpath}/README
hostname -s >> ${dirout}/Refine3D/${rlnpath}/README
echo "" >> ${dirout}/Refine3D/${rlnpath}/README
# Remote host
echo "host information (remote):" >> ${dirout}/Refine3D/${rlnpath}/README
echo $server -s >> ${dirout}/Refine3D/${rlnpath}/README
echo "" >> ${dirout}/Refine3D/${rlnpath}/README
# Remote host directory, use this to get true path
echo "Relion Refine3D directory location:" >> ${dirout}/Refine3D/${rlnpath}/README
dirbackup=$(ssh $server readlink -f $dirin)
echo $dirbackup >> ${dirout}/Refine3D/${rlnpath}/README
echo "" >> ${dirout}/Refine3D/${rlnpath}/README
# Remote directory name
echo "Refine3D directory name:" >> ${dirout}/Refine3D/${rlnpath}/README
echo "Refine3D/${rlnpath}" >> ${dirout}/Refine3D/${rlnpath}/README
echo "" >> ${dirout}/Refine3D/${rlnpath}/README

#Report what's going to happen
echo ''
echo '#########################################################################'
echo ''
echo 'Refine3D directory name to be backed up:'
echo "Refine3D/${rlnpath}"
echo ''
echo 'Refine3D directory to be backed up (ignoring symbolic links):'
echo ${dirbackup}
echo ''
echo 'Backup location is:'
echo ${dirout}
echo ''
echo 'The following directory structure will be created:'
echo "Refine3D/${rlnpath}"
echo ''
echo '#########################################################################'
echo ''
echo 'Hit Enter to continue or ctrl-c to quit...'
read p

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
${dirout}/Refine3D/${rlnpath}

#Copy run note details to README
cat ${dirout}/Refine3D/${rlnpath}/note.txt >> ${dirout}/Refine3D/${rlnpath}/README

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
