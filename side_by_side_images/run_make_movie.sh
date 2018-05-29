#!/bin/bash


vmd=/Users/morris/software/VMD.1.9.3.app/Contents/MacOS/startup.command
mkdir movie

# loop over trajectories you want to do this for.
# or just do it for one trajectory

#for i in `seq 1 50`
#do
i=0
  $vmd -startup startup.tcl -e make_movie.tcl -args trajectory_files/dopc.mapped.withres.pdb trajectory_files/${i}.dcd trajectory_files/defects.${i}.xyz movie/ $i
#done

# loop over the number of snapshots you have
# paste each pair of images side by side
for i in $(seq -f "%05g" 0 49)
do
    convert +append movie/vmdscene.${i}.tga movie/vmdscene.nodefect.${i}.tga movie/final.${i}.png
done

# combine all images into a movie
ffmpeg -framerate 5 -i movie/final.%05d.png -c:v libx264 -r 30 -pix_fmt yuv420p movie.mp4

rm -rf movie/

