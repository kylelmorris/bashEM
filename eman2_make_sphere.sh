#!/bin/bash
#

#28mini
box=500
apix=1.705
outerR=210
innerR=153
innerRmask=$(echo ${innerR}+20 | bc)

#Create filled volume
echo ""
echo "+++ e2proc3d.py :${box}:${box}:${box}:${apix} volume.hdf"
e2proc3d.py :${box}:${box}:${box}:${apix} volume.hdf
echo "Created filled volume"

#Create sphere
echo ""
echo "+++ e2proc3d.py volume.hdf sphere.hdf --process testimage.circlesphere:fill=1:radius=${outerR}"
e2proc3d.py volume.hdf sphere.hdf --process testimage.circlesphere:fill=1:radius=${outerR}
echo "Created sphere"

#Mask to create shell
echo ""
echo "+++ e2proc3d.py sphere.hdf shell.hdf --process mask.sharp:inner_radius=${innerR}"
e2proc3d.py sphere.hdf shell.hdf --process mask.sharp:inner_radius=${innerR}
echo "Created shell"

#Convert to mrc file
echo ""
echo "+++ e2proc3d.py shell.hdf shell.mrc"
e2proc3d.py shell.hdf shell.mrc
echo "Created shell mrc file"

#Mask to soften shell
echo ""
echo "+++ e2proc3d.py shell.mrc shell_soft.mrc --process mask.gaussian:outer_radius=${outerR} --process mask.gaussian:inner_radius=${innerRmask}"
e2proc3d.py shell.mrc shell_soft.mrc --process mask.gaussian:outer_radius=${outerR} --process mask.gaussian:inner_radius=${innerRmask}

echo "Softened shell by gaussian masking"

#Mask to soften shell using relion and eman2
#e2proc3d.py shell.mrc shell_invert.mrc --mult=-1
#echo "+++ relion_mask_create --i shell.mrc --o shell_mask.mrc --ini_threshold 1 --width_soft_edge 5"
#relion_mask_create --i shell_invert.mrc --o shell_mask.mrc --ini_threshold 1 --width_soft_edge 5
#echo "Created soft mask file"
#echo "+++ relion_image_handler --i shell.mrc --multiply shell_mask.mrc --o shell_soft.mrc"
#relion_image_handler --i shell.mrc --multiply shell_mask.mrc --o shell_soft.mrc
#echo "Created soft shell reference"

echo ""
echo "Done!"

