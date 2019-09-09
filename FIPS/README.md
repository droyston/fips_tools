# Functional (mr)Imaging Processing and Analysis Systems
Analysis code for processing and analyzing functional MRI data

## Module Documentation

FIPS_raw2clean : Converts and processes raw MRI files using Freesurfer and SPM12
- FIPS_SHELL_raw2clean : Shell script for initializing target data variables and execute subfunctions
	- FIPS_r2c_Run_All : Executes preprocessing BASH scripts and SPM processing
		- FIPS_r2c_raw2nifti : Converts raw files into NIFTI
		- FIPS_r2c_FS_recon : Reconstructs cortical surface from T1 anatomical image using Freesurfer
		- FIPS_r2c_SPM_Job_Wrapper: Executes SPM preprocessing and GLM analysis
		- FIPS_r2c_SPM2SUMA: Converts SPM functional contrasts into SUMA surface files

