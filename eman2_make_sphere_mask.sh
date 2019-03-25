#!/bin/bash
#

echo "Usage is eman2_make_sphere_mask (1) (2) (3) (4) (5)"
echo "(1): Box size"
echo "(2): apix"
echo "(3): diameter (Å)"
echo "(4): extend mask (px)"
echo "(5): soften mask (px)"
echo "Enter or ctrl-c"
read p

#variables
box=$1
apix=$2
d=$3
ex=$4
soft=$5

#Calculate radius in pixels
outerD=$(echo "scale=0; ${d}/${apix}" | bc)
outerR=$(echo "scale=0; ${outerD}/2" | bc)
echo ""
echo "Diameter in pixels will be: ${outerD}"
echo ""

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

#Convert to mrc file
echo ""
echo "+++ e2proc3d.py sphere.hdf sphere.mrc"
e2proc3d.py sphere.hdf sphere.mrc
echo "Created sphere mrc file"

#Correct that eman fails to write the pixel size
#relion_image_handler --i sphere.mrc --angpix 1 --rescale_angpix ${apix}

#Mask to soften sphere using relion and eman2
echo ""
echo "Softened sphere and creating binary mask"
echo "+++ relion_mask_create --i sphere.mrc --o sphere_mask.mrc --ini_threshold 1 --extend_inimask $ex --width_soft_edge $soft"
relion_mask_create --i sphere.mrc --o sphere_mask.mrc --ini_threshold 1 --extend_inimask $ex --width_soft_edge $soft
echo "Created soft mask file"

#Mask to soften sphere
#echo ""
#echo "+++ e2proc3d.py sphere.mrc sphere_soft.mrc --process mask.gaussian:outer_radius=${outerR}"
#e2proc3d.py sphere.mrc sphere_soft.mrc --process mask.gaussian:outer_radius=${outerR}

#Tidy up
rm -rf sphere.hdf
rm -rf volume.hdf
rm -rf sphere.mrc
mv sphere_mask.mrc sphere_mask_d${d}A_e${ex}_s${soft}.mrc

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
