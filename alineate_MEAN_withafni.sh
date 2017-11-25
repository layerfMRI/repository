#!/bin/bash



echo "fange an"
master=MEAN_no_touch.nii
echo "es wird alles an $master ausgerichted"

3dQwarp -allineate -blur 0 0 -base $master -source MEAN_right.nii                             -prefix   warped_MEAN_right.nii -overwrite
3dNwarpApply -nwarp                         warped_MEAN_right_WARP.nii -source VASO_right.nii -prefix warped_VASO_right.nii -overwrite
3dNwarpApply -nwarp                         warped_MEAN_right_WARP.nii -source BOLD_right.nii -prefix warped_BOLD_right.nii -overwrite
3dNwarpApply -nwarp                         warped_MEAN_right_WARP.nii -source T1_right.nii -prefix warped_T1_right.nii -overwrite

3dNwarpApply -nwarp                         warped_MEAN_right_WARP.nii -source dVASO_right.nii -prefix warped_dVASO_right.nii -overwrite
3dNwarpApply -nwarp                         warped_MEAN_right_WARP.nii -source dBOLD_right.nii -prefix warped_dBOLD_right.nii -overwrite


3dQwarp -allineate -blur 0 0 -base $master -source MEAN_left.nii                            -prefix   warped_MEAN_left.nii -overwrite
3dNwarpApply -nwarp                         warped_MEAN_left_WARP.nii -source VASO_left.nii -prefix warped_VASO_left.nii -overwrite
3dNwarpApply -nwarp                         warped_MEAN_left_WARP.nii -source BOLD_left.nii -prefix warped_BOLD_left.nii -overwrite
3dNwarpApply -nwarp                         warped_MEAN_left_WARP.nii -source T1_left.nii -prefix warped_T1_left.nii -overwrite


3dNwarpApply -nwarp                         warped_MEAN_left_WARP.nii -source dVASO_left.nii -prefix warped_dVASO_left.nii -overwrite
3dNwarpApply -nwarp                         warped_MEAN_left_WARP.nii -source dBOLD_left.nii -prefix warped_dBOLD_left.nii -overwrite

3dQwarp -allineate -blur 0 0 -base $master -source MEAN_no_touch.nii                                -prefix warped_MEAN_no_touch.nii   -overwrite
3dNwarpApply -nwarp                         warped_MEAN_no_touch_WARP.nii -source VASO_no_touch.nii -prefix warped_VASO_no_touch.nii -overwrite
3dNwarpApply -nwarp   	                     warped_MEAN_no_touch_WARP.nii -source BOLD_no_touch.nii -prefix warped_BOLD_no_touch.nii -overwrite
3dNwarpApply -nwarp   	                     warped_MEAN_no_touch_WARP.nii -source T1_no_touch.nii -prefix warped_T1_no_touch.nii -overwrite

3dNwarpApply -nwarp                         warped_MEAN_no_touch_WARP.nii -source dVASO_no_touch.nii -prefix warped_dVASO_no_touch.nii -overwrite
3dNwarpApply -nwarp   	                     warped_MEAN_no_touch_WARP.nii -source dBOLD_no_touch.nii -prefix warped_dBOLD_no_touch.nii -overwrite

echo "und tschuess"

#the following does not perform well
#3dWarpDrive -base  MEAN_no_touch.nii -cubic -input  MEAN_right.nii -prefix warp_drive_touch.nii -bilinear_general -overwrite
