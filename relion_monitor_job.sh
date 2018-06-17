#!/bin/bash
#

jobin=$1
lines=$2

if [[ -z $1 ]] ; then

  echo ""
  echo "Variables empty, usage is ${0} (1) (2)"
  echo ""
  echo "(1) = job directory name"
  echo "(2) = Number of output lines (optional)"
  exit

fi

if [[ -s ${jobin}/run.err ]]
  echo "No errors found, continuing..."
else
  cat ${jobin}/run.err
  echo ""
  echo "Errors found in run.err, do you want to continue?"
  echo "Enter or ctrl-c"
  read p
fi

if [[ -z $lines ]] ; then
  lines=100
fi

tail -f -n ${lines} ${jobin}/run.out
