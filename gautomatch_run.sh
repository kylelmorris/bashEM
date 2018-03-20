#!/bin/bash
#

dir=$(pwd)
gautomatch="/mount/local/app/Gautomatch/bin/Gautomatch-v0.53_sm_20_cu7.5_x86_64"

$gautomatch --apixM 1.58 --diameter 150 --lp 20 *.mrc

echo ""
echo "Particle picking complete"
echo ""
echo "Transferring coordinates"
echo ""
mkdir ../ManualPick/manual_pick/Micrographs
scp -r *automatch.star ../ManualPick/manual_pick/Micrographs/
cd ../ManualPick/manual_pick/Micrographs/
find . -depth -name '*automatch.star*' -execdir bash -c 'for f; do mv -i "$f" "${f//automatch.star/manualpick.star}"; done' bash {} +
find . -depth -name '*_inv*' -execdir bash -c 'for f; do mv -i "$f" "${f//_inv/}"; done' bash {} +
cd $dir
echo "Done!!"
