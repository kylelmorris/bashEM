#!/bin/sh
#

dir=$1

if [[ -z $1 ]] ; then

  echo ""
  echo "Variables empty, usage is: "
  echo ""
  echo "$(basename $0) (1)"
  echo ""
  echo "(1) = Relion job directory to query run time"
  echo ""
  exit

fi

# https://stackoverflow.com/questions/12199631/convert-seconds-to-hours-minutes-seconds
convertsecs() {
 ((h=${1}/3600))
 ((m=(${1}%3600)/60))
 ((s=${1}%60))
 printf "%02d:%02d:%02d\n" $h $m $s
}

# Report information
echo
echo "Command for job: ${dir}/note.txt"
cat ${dir}/note.txt

# Get time in seconds of initial file write and last run output
stime=$(stat -c %Y $dir/job.star)
etime=$(stat -c %Y $dir/run.out)

# Report information
echo
echo "Time query on job: ${dir}"
echo

# Time comparison and conversion to hh:mm:ss
time=$(( ($etime - $stime) ))
echo "$(convertsecs $time) (hh:mm:ss)"
