#!/bin/sh
#

dir=$1

# https://stackoverflow.com/questions/12199631/convert-seconds-to-hours-minutes-seconds
convertsecs() {
 ((h=${1}/3600))
 ((m=(${1}%3600)/60))
 ((s=${1}%60))
 printf "%02d:%02d:%02d\n" $h $m $s
}

# Get time in seconds of initial file write and last run output
stime=$(stat -c %Y $dir/job.star)
etime=$(stat -c %Y $dir/run.out)

# Report information
echo "Time query on job: ${dir}"

# Time comparison and conversion to hh:mm:ss
time=$(( ($etime - $stime) ))
echo "$(convertsecs $time) (hh:mm:ss)"

# Report information
echo
echo "Job command:"
cat ${dir}/note.txt
