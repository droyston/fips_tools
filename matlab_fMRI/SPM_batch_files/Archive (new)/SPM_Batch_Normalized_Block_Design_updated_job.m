% Script for fMRI SPM Analysis Performing Preprocessing, Modeling, and Co-registering
%
% Requires Master_Processing_Parameter.mat from fMRI_Script_RunFunctionalAnalysis.m (requires: MRI_Info.study_path and MRI_Info.file4spm_processing); MRI_Info.T1_file is optional, defaults finding T1.nii within MRI_Info.study_path)
%
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%
% 2012-07-12 (Foldes and Randazzo)
% UPDATES:
% 2012-08-07 SF: Made more robust to any experiment and differnt file organizations, added SUMA Coreg, uses MRI_Info struct
% 2012-12-04 Foldes: Will automatically SEARCH for *T1.nii file from MRI_Info.study_path. T1-path is now the T1 file name w/ path. Also removed SUMA coreg b/c it is redundent (just copy regular coreg)
% 2013-02-01 Alan: Generates nii file list. Hardcoded to be 90 for now.
% 2013-11-14 Randazzo: Updated for normalized analysis
% 2014-03-07 Randazzo: Renamed to SPM_Batch_Normalized_Block_Design in accordance with Individual Block Design and revised code to be compatible with Script_Run_fMRI_Analysis
% 2015-03-20 Royston: Updated to new settings and SPM12 Segment/Normalize

%%

% Loading parameters for this evaluation (see fMRI_Script_RunFunctionalAnalysis.m)
load('Master_Processing_Parameter.mat'); % Loads MRI_Info

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

%% ---PREPROCESS---

%% REALIGN

% number of files in NII (2014-01-06)
nFiles =length(spm_vol(current_epi));
tempFile = cell(nFiles,1);
for i = 1:nFiles
    niiStr = sprintf('.nii,%d',i);
    tempStr = [file_path filesep file_name niiStr];
    tempFile{i} = tempStr;
end


matlabbatch{1}.spm.spatial.realign.estimate.data = {tempFile}';

matlabbatch{1}.spm.spatial.realign.estimate.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.weight = '';

% matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
% matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
% matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
% matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 0;
% matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
% matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
% matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = {''};
% matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
% matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
% matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
% matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
% matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r1';

%% COREGISTER

matlabbatch{2}.spm.spatial.coreg.estimate.ref = {[file_path filesep file_name '.nii,1']};
matlabbatch{2}.spm.spatial.coreg.estimate.source = {[MRI_Info.T1_file ',1']}; % <-- VARIABLE
matlabbatch{2}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];


%% SEGMENTATION
% updated

matlabbatch{3}.spm.spatial.preproc.channel.vols(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{3}.spm.spatial.preproc.channel.biasreg = 0.0001;
matlabbatch{3}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{3}.spm.spatial.preproc.channel.write = [0 1];
matlabbatch{3}.spm.spatial.preproc.tissue(1).tpm = {'C:\Users\hrnel\Documents\MATLAB\spm12\tpm\TPM.nii,1'};
matlabbatch{3}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{3}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(2).tpm = {'C:\Users\hrnel\Documents\MATLAB\spm12\tpm\TPM.nii,2'};
matlabbatch{3}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{3}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(3).tpm = {'C:\Users\hrnel\Documents\MATLAB\spm12\tpm\TPM.nii,3'};
matlabbatch{3}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{3}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(4).tpm = {'C:\Users\hrnel\Documents\MATLAB\spm12\tpm\TPM.nii,4'};
matlabbatch{3}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{3}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(5).tpm = {'C:\Users\hrnel\Documents\MATLAB\spm12\tpm\TPM.nii,5'};
matlabbatch{3}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{3}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(6).tpm = {'C:\Users\hrnel\Documents\MATLAB\spm12\tpm\TPM.nii,6'};
matlabbatch{3}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{3}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{3}.spm.spatial.preproc.warp.cleanup = 0;
matlabbatch{3}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{3}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{3}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{3}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{3}.spm.spatial.preproc.warp.write = [0 1];


%% NORMALIZE 

matlabbatch{4}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
matlabbatch{4}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Realign: Estimate: Realigned Images (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','cfiles'));
matlabbatch{4}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -50
                                                          78 76 85];
matlabbatch{4}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
matlabbatch{4}.spm.spatial.normalise.write.woptions.interp = 4;

%% SMOOTHING

matlabbatch{5}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{5}.spm.spatial.smooth.fwhm = [6 6 6];
matlabbatch{5}.spm.spatial.smooth.dtype = 0;
matlabbatch{5}.spm.spatial.smooth.im = 0;
matlabbatch{5}.spm.spatial.smooth.prefix = 's';


%% fMRI MODEL SPECIFICATION

matlabbatch{6}.spm.stats.fmri_spec.dir = {file_path};
matlabbatch{6}.spm.stats.fmri_spec.timing.units = 'scans';
matlabbatch{6}.spm.stats.fmri_spec.timing.RT = MRI_Info.ExpDef_TR; % <-- VARIABLE;
matlabbatch{6}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{6}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{6}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
matlabbatch{6}.spm.stats.fmri_spec.sess.scans(1) = cfg_dep('Smooth: Smoothed Images', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{6}.spm.stats.fmri_spec.sess.cond.name = 'Task';
matlabbatch{6}.spm.stats.fmri_spec.sess.cond.onset = MRI_Info.ExpDef_event_onsets;% <-- VARIABLE
matlabbatch{6}.spm.stats.fmri_spec.sess.cond.duration = MRI_Info.ExpDef_event_duration;% <-- VARIABLE
matlabbatch{6}.spm.stats.fmri_spec.sess.cond.tmod = 0;
matlabbatch{6}.spm.stats.fmri_spec.sess.cond.pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{6}.spm.stats.fmri_spec.sess.cond.orth = 1;
matlabbatch{6}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{6}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{6}.spm.stats.fmri_spec.sess.multi_reg(1) = cfg_dep('Realign: Estimate: Realignment Param File (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rpfile'));
matlabbatch{6}.spm.stats.fmri_spec.sess.hpf = 60;
matlabbatch{6}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{6}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{6}.spm.stats.fmri_spec.volt = 1;
matlabbatch{6}.spm.stats.fmri_spec.global = 'None';
matlabbatch{6}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{6}.spm.stats.fmri_spec.mask = {''};
matlabbatch{6}.spm.stats.fmri_spec.cvi = 'AR(1)';


%% MODEL ESTIMATION

matlabbatch{7}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{7}.spm.stats.fmri_est.write_residuals = 0;



%% MODEL (Contrast Manager)
matlabbatch{8}.spm.stats.con.spmmat(1) = cfg_dep;
matlabbatch{8}.spm.stats.con.spmmat(1).tname = 'Select SPM.mat';
matlabbatch{8}.spm.stats.con.spmmat(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{8}.spm.stats.con.spmmat(1).tgt_spec{1}(1).value = 'mat';
matlabbatch{8}.spm.stats.con.spmmat(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{8}.spm.stats.con.spmmat(1).tgt_spec{1}(2).value = 'e';
matlabbatch{8}.spm.stats.con.spmmat(1).sname = 'Model estimation: SPM.mat File';
matlabbatch{8}.spm.stats.con.spmmat(1).src_exbranch = substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{8}.spm.stats.con.spmmat(1).src_output = substruct('.','spmmat');
matlabbatch{8}.spm.stats.con.consess{1}.tcon.name = 'Move';
matlabbatch{8}.spm.stats.con.consess{1}.tcon.convec = [1 0 0 0 0 0 0 0];
matlabbatch{8}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{8}.spm.stats.con.consess{2}.fcon.name = 'MotionArtifact';
matlabbatch{8}.spm.stats.con.consess{2}.fcon.convec = {
                                                       [0 1 0 0 0 0 0 0
                                                       0 0 1 0 0 0 0 0
                                                       0 0 0 1 0 0 0 0]
                                                       }';
matlabbatch{8}.spm.stats.con.consess{2}.fcon.sessrep = 'none';
matlabbatch{8}.spm.stats.con.delete = 0;

