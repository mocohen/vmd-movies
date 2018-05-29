# Make movie with two different views of a trajectory
#
# Created By Morris Sharp


############## Set input variables #######################
if { [llength $argv] !=  5} {
        puts "Usage: vmd -e make_movie.tcl membrane.pdb membrane.dcd defects.xyz output_dir trajectory_number"
        exit
}

puts "set input variables"
set memb_pdb [lindex $argv 0] 
set memb_dcd [lindex $argv 1]
set defect_xyz [lindex $argv 2] 
set out_dir [lindex $argv 3] 
set traj_num  [lindex $argv 4] 
puts "finished setting input variables"


# load membrane pdb for stucture
mol load pdb $memb_pdb 
# load membrane dcd
mol addfile $memb_dcd waitfor all

#delete first frame, which is pdb 
animate delete  beg 0 end 0 skip 0 0


#load defect xyz
mol new $defect_xyz type xyz waitfor all

set step_size 1
set first_frame 0
set num_frames [molinfo 1 get numframes]

# since you are likely splitting this up into multiple small runs, figure out what frame number you are at
set firstFrame [ expr $traj_num * $num_frames ]



# create representations for the membrane
# VDW representation, with AOShiny
# Head group bead
mol delrep 0 0
mol representation VDW 2.600000 32.000000
mol color ColorID 1
mol selection {name H}
mol material AOShiny
mol addrep 0

# mid group bead
mol representation VDW 2.100000 32.000000
mol color ColorID 6
mol selection {name M}
mol material AOShiny
mol addrep 0

# Tail groups
mol representation VDW 1.700000 32.000000
mol color ColorID 2
mol selection {not name H and not name M and not name S}
mol material AOShiny
mol addrep 0



# Create representations for defect trajectory
#
mol delrep 0 1
mol representation VDW 1.000000 32.000000
mol color ColorID 7
mol selection {not within 1 of index 7999}
mol material AOShiny
mol addrep 1


# make sure to center the view on the defects
mol showrep 0 0 0
mol showrep 0 1 0
mol showrep 0 2 0
display resetview
mol showrep 0 0 1
mol showrep 0 1 1
mol showrep 0 2 1
 


for {set f $first_frame} {$f < [expr $num_frames / $step_size] } {incr f} {
	# calculate and set frame number
	set dcdFrame [expr $f * $step_size]
        set theFrame [expr $dcdFrame + $firstFrame]
        molinfo 0 set frame $dcdFrame
        molinfo 1 set frame $dcdFrame
        puts "working on frame $theFrame"
        
		

	# center membrane
	set sel_P [atomselect 0 "name H"]
        set centerOfP [measure center $sel_P]
        set x [expr -1.0*[lindex $centerOfP 0]]
        set y [expr -1.0*[lindex $centerOfP 1]]
        set z [expr -1.0*[lindex $centerOfP 2]]
        set all [atomselect 0 "all"]
        set move_vec [list $x $y $z] 
        $all moveby $move_vec


	# make sure show the defects on the membrane
        mol showrep 1 0 1
	# make sure snapshot is of top of membrane

	#render image with defects
        set theFile [format "$out_dir/vmdscene.%05d.tga" $theFrame]        
        render snapshot $theFile
        
	# You can also render the image with Tachyon, which is much higher quality
	# Just be aware that it will take a lot longer
	# set theFile [format "$out_dir/vmdscene.%05d.tga" $theFrame]        
        # render TachyonInternal $theFile

	# don't show defects in image
        mol showrep 1 0 0 
	# render image without defects
        set theFile [format "$out_dir/vmdscene.nodefect.%05d.tga" $theFrame]
        render snapshot $theFile

}

exit
