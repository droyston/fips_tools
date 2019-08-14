% Programatic Batch for SPM for standard individual fMRI analysis
%   SPM Analysis Performing Preprocessing, Modeling, and Co-registering
% 
% REQUIRES:
%   Master_Processing_Parameter.mat must have MRI_Info and current_epi
%   current_epi:                Full path to the current epi
%   MRI_Info.
%   .T1_file:                   [OPTIONAL] Name and path for the T1.nii. If empty, will use a GUI.
%   .T1_auto_find:              [OPTIONAL] If =1, will look through MRI_Info.study_path for a T1.nii
%   SPM variables:
%       .ExpDef_TR =             0; % TR 'Interscan interval'
%       .ExpDef_event_onsets =   [0]; % vector of when conditions/events happen, in scan # (hardcoded, but can be changed)
%       .ExpDef_event_duration = 0; % num scans for the event/condition to happen
%
% OUTPUT
%   coregspmT_0001.img
%   SPM.mat
%
% LATER
%   Include stimulus timing etc
%
% 2012-07-12 (Foldes and Randazzo)
% UPDATES:
% 2012-08-07 SF: Made more robust to any experiment and differnt file organizations, added SUMA Coreg, uses MRI_Info struct
% 2012-12-04 Foldes: Will automatically SEARCH for *T1.nii file from MRI_Info.study_path. T1-path is now the T1 file name w/ path. Also removed SUMA coreg b/c it is redundent (just copy regular coreg)
% 2013-02-01 Alan: Generates nii file list. Hardcoded to be 90 for now.
% 2013-12-02 Randazzo: findFiles
% 2014-01-01 Foldes: MAJOR Branch
% 2014-01-06 Foldes: Finds number of nii files, uses task design, T1 found here
% 2015-01-12 Royston: Coregister step copied from SPM_Batch_Individual_Block_Design.m, transplanted due to bug



%%

% Loading parameters for this evaluation (see fMRI_Script_RunFunctionalAnalysis.m)
load('Master_Processing_Parameter.mat'); % Loads MRI_Info and current_epi

[file_path,file_name] = fileparts(current_epi);

% Figure out the T1 
if isempty(MRI_Info.T1_file)
    % Search for the T1 from the study path
    possible_T1s = search_dir(MRI_Info.study_path,'*T1.nii');
    if isempty(possible_T1s)
        error('No T1 found')
    end
    T1_guess = cell2mat(possible_T1s(1));
    
    if MRI_Info.T1_auto_find == 1
        MRI_Info.T1_file = T1_guess;
    else
        [FileName,PathName] = uigetfile('*.nii','Select T1 (No T1 file given in MRI_Info.T1_file)',T1_guess);
        MRI_Info.T1_file = [PathName filesep FileName];
    end
    
    if isempty(MRI_Info.T1_file)
        error('NO T1.nii FOUND')
    end
end

%%
% Loop through all *.nii files

% number of files in NII (2014-01-06)
nFiles =length(spm_vol(current_epi));
tempFile = cell(nFiles,1);
for i = 1:nFiles
    niiStr = sprintf('.nii,%d',i);
    tempStr = [file_path filesep file_name niiStr];
    tempFile{i} = tempStr;
end

matlabbatch{3}.spm.spatial.coreg.estwrite.scans = tempFile;

% COREGISTER
matlabbatch{6}.spm.spatial.coreg.estwrite.ref = {[MRI_Info.T1_file ',1']}; % <-- VARIABLE
matlabbatch{6}.spm.spatial.coreg.estwrite.source = {[file_path filesep 'mean' file_name '.nii,1']};
matlabbatch{6}.spm.spatial.coreg.estwrite.other = {[file_path filesep 'spmT_0001.img,1']}; % <--- This could be a stats image dependency, but only works if hardcoded to spmT filename due to bug
matlabbatch{6}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{6}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{6}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{6}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{6}.spm.spatial.coreg.estwrite.roptions.interp = 1;
matlabbatch{6}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{6}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{6}.spm.spatial.coreg.estwrite.roptions.prefix = 'coreg';


