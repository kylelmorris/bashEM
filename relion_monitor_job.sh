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

if [[ -z $lines ]] ; then
  lines=10
fi


tail -f -n ${lines} ${jobin}/run.out
