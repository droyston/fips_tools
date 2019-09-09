#!/bin/bash

# 2019-09-08 Dylan Royston
#
#
# Script to run SUMA 
# Adapted from 2012-08-06 (Foldes)
#
# UPDATES:
# 2012-12-11 Foldes: Updated
# 2014-04-04 Foldes: Path case structure
# 2017-11-06 Royston: updating for initial testing of new Linux fMRI environment

# --------------------------
# ---ENTER FILE INFO HERE---
# --------------------------

# EXAMPLE: /home/foldes/Data/subjects/NC07/Initial/ => ${SUBJECTS_DIR}/${SUBJECT_ID}/${SESSION_TYPE}/
#export SUBJECT_ID='MNI_N27'
#export SESSION_TYPE='SCI_motor_overt'
#export SUBJECT_ID='NS12'
export SUBJECT_ID='SCI_all_MO'
export SESSION_TYPE='Somatomapping'


# ---------------
# ---Set Paths---
# ---------------
# Set computer specific paths for MRI analysis (Freesurfer and Afni/SUMA)
# NOTE: Paths might need to be adjusted for different computers (e.g. PERL)
case $HOSTNAME in
  	(FoldesPC)
  	echo "FoldesPC"
  	export SUBJECTS_DIR=/project
	export FREESURFER_HOME=/usr/local/freesurfer
	export AFNI_HOME=/usr/lib/afni/
	export PERL5LIB=$PERL5LIB:$FREESURFER_HOME/mni/lib/perl5/5.8.5
	;;

  	(rnel-ws3l)
  	echo "RNEL_DAR_linux"
    export SUBJECTS_DIR=/project

	export FREESURFER_HOME=/usr/local/freesurfer
	export AFNI_HOME=/home/dar147/abin
	export PERL5LIB=$PERL5LIB:$FREESURFER_HOME/mni/lib/perl5/5.8.5
  	;;
  	(*)   echo "YOU NEED TO SET PATHS FOR THIS COMPUTER. SEE: Set_Paths_FS_ANFI.sh";;
esac

export PATH=$PATH:$FREESURFER_HOME/bin:$FREESURFER_HOME/mni/bin
export PATH=$PATH:$AFNI_HOME:$AFNI_HOME/bin


# Subject specific path
export SUBJECT_PATH=${SUBJECTS_DIR}/${SUBJECT_ID}
export SUBJECT_PATH=${SUBJECTS_DIR}/MNI_N27
export TASK_PATH=${SUBJECTS_DIR}/${SUBJECT_ID}/

# ---------------
#---START SUMA---
# ---------------

cd ${TASK_PATH}

afni -niml &

suma -spec ${SUBJECT_PATH}/Freesurfer_Reconstruction/SUMA/MNI_N27_both.spec -sv MNI_N27/Freesurfer_Reconstruction/SUMA/MNI_N27_SurfVol+orig.BRIK &
#suma -spec ${SUBJECT_PATH}/Freesurfer_Reconstruction_Rad/SUMA/${SUBJECT_ID}_both.spec -sv ${SUBJECT_PATH}/Freesurfer_Reconstruction_Rad/SUMA/${SUBJECT_ID}_SurfVol+orig.BRIK &

# ---NOTES---
# b, F6
# r supposed to record
