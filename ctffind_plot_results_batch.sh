#!/bin/bash
#

#Written by Kyle Morris Hurley Lab UCB

#This script will batch plot the results from ctffind4 on all files in the current working directory

#Note that ctffind4 and ctffind_plot_results.sh need to be in your $PATH

# Iterate over *_avrot.txt files in current working directory
for f in *avrot.txt ; do

  echo 'Working on file: '$f
  ctffind_plot_results.sh $f

done
