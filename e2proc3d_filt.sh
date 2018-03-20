#!/bin/bash
#

for (( i=1; i<=31; i++ ))
do
  j=$(printf "%02d" $i)
  e2proc3d.py rctrecon_${j}.hdf rctrecon_${j}_filt.mrc --process=filter.lowpass.gauss:cutoff_abs=0.05
 
done

