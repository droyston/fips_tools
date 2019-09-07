%
%
% 2016-03-08 Dylan Royston
%
% Batch job file created for Covert Mapping automated pre-processing
% Uses switch-case to input condition onsets/contrasts
% Most settings are hard-coded to SPM default values, variables are noted as such
% 
% === UPDATES ===
% 2016-06-21 Royston: updated Segment file paths (which are hard-coded for
%                     some reason) to direct to server files
% 2016-10-03 Royston: reverting some changes that apparently randomly injected themselves on 2016-09-07
%
%
% === TO DO ===
% - Determine if Segment can be skipped if already done (need deformation matrices for following dependency?)
%
%%


% Loading parameters for this evaluation (see fMRI_Script_RunFunctionalAnalysis.m)
load('Master_Processing_Parameter.mat'); % Loads MRI_Info_current

[file_path,file_name] = fileparts(current_epi);

% Figure out the T1 
if isempty(MRI_Info_current.T1_file)
    % Search for the T1 from the study path
    possible_T1s = search_dir(MRI_Info_current.study_path,'*T1.nii');
    if isempty(possible_T1s)
        error('No T1 found')
    end
    T1_guess = cell2mat(possible_T1s(1));
    
    if MRI_Info_current.T1_auto_find == 1
        MRI_Info_current.T1_file = T1_guess;
    else
        [FileName,PathName] = uigetfile('*.nii','Select T1 (No T1 file given in MRI_Info_current.T1_file)',T1_guess);
        MRI_Info_current.T1_file = [PathName filesep FileName];
    end
    
    if isempty(MRI_Info_current.T1_file)
        error('NO T1.nii FOUND')
    end
end


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

%% COREGISTER


matlabbatch{2}.spm.spatial.coreg.estimate.ref = {[file_path filesep file_name '.nii,1']}; % <-- VARIABLE
matlabbatch{2}.spm.spatial.coreg.estimate.source = {[MRI_Info_current.T1_file ',1']};
matlabbatch{2}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

%% SEGMENTATION

if isunix
    tpm_path = '/home/dar147/spm12/tpm/TPM.nii';
else
    tpm_path = 'R:\data_generated\human\covert_mapping\CM_Analysis_Tools\spm12\tpm\TPM.nii';
end

matlabbatch{3}.spm.spatial.preproc.channel.vols(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{3}.spm.spatial.preproc.channel.biasreg = 0.0001;
matlabbatch{3}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{3}.spm.spatial.preproc.channel.write = [0 1];
matlabbatch{3}.spm.spatial.preproc.tissue(1).tpm = {[tpm_path ',1']};
matlabbatch{3}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{3}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(2).tpm = {[tpm_path ',2']};
matlabbatch{3}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{3}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(3).tpm = {[tpm_path ',3']};
matlabbatch{3}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{3}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(4).tpm = {[tpm_path ',4']};
matlabbatch{3}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{3}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(5).tpm = {[tpm_path ',5']};
matlabbatch{3}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{3}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(6).tpm = {[tpm_path ',6']};
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



%% SMOOTH

matlabbatch{5}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{5}.spm.spatial.smooth.fwhm = [6 6 6];
matlabbatch{5}.spm.spatial.smooth.dtype = 0;
matlabbatch{5}.spm.spatial.smooth.im = 0;
matlabbatch{5}.spm.spatial.smooth.prefix = 's';



%% fMRI MODEL SPECIFICATION

matlabbatch{6}.spm.stats.fmri_spec.dir = {file_path};
matlabbatch{6}.spm.stats.fmri_spec.timing.units = 'scans';

matlabbatch{6}.spm.stats.fmri_spec.timing.RT = MRI_Info_current.ExpDef_TR; % <-- VARIABLE;

matlabbatch{6}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{6}.spm.stats.fmri_spec.timing.fmri_t0 = 1;

matlabbatch{6}.spm.stats.fmri_spec.sess.scans(1) = cfg_dep('Smooth: Smoothed Images', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));


num_conditions = size(MRI_Info_current.ExpDef_event_onsets, 1);

switch num_conditions
    case 4% COVERT
        
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).name = 'Simple';
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).onset = MRI_Info_current.ExpDef_event_onsets(1, :);%<-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).orth = 1;
        
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(2).name = 'Goal';
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(2).onset = MRI_Info_current.ExpDef_event_onsets(2, :);%<-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(2).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(2).orth = 1;
        
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(3).name = 'Audio';
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(3).onset = MRI_Info_current.ExpDef_event_onsets(3, :);%<-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(3).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(3).orth = 1;
        
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(4).name = 'Stim';
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(4).onset = MRI_Info_current.ExpDef_event_onsets(4, :);%<-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(4).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(4).orth = 1;

    case 5% OVERT MOTOR
        
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).name = 'Lips';
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).onset = MRI_Info_current.ExpDef_event_onsets(1, :);%<-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).orth = 1;
        
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(2).name = 'Wrist';
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(2).onset = MRI_Info_current.ExpDef_event_onsets(2, :);%<-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(2).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(2).orth = 1;
        
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(3).name = 'Hand';
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(3).onset = MRI_Info_current.ExpDef_event_onsets(3, :);%<-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(3).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(3).orth = 1;
        
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(4).name = 'Fingers';
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(4).onset = MRI_Info_current.ExpDef_event_onsets(4, :);%<-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(4).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(4).orth = 1;
        
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(5).name = 'Ankle';
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(5).onset = MRI_Info_current.ExpDef_event_onsets(5, :);%<-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(5).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(5).tmod = 0;
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(5).orth = 1;
        
    case 1% OVERT SENSORY
        
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).name = 'Stim';
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).onset = MRI_Info_current.ExpDef_event_onsets(1, :);%<-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{6}.spm.stats.fmri_spec.sess.cond(1).orth = 1;

end% switch

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
matlabbatch{7}.spm.stats.fmri_est.method.Classical = 1;


%% MODEL (contrast manager)



matlabbatch{8}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));

switch num_conditions
    case 4
        
        matlabbatch{8}.spm.stats.con.consess{1}.tcon.name = 'Simple';
        matlabbatch{8}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0];
        matlabbatch{8}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        
        matlabbatch{8}.spm.stats.con.consess{2}.tcon.name = 'Goal';
        matlabbatch{8}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0];
        matlabbatch{8}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        
        matlabbatch{8}.spm.stats.con.consess{3}.tcon.name = 'Audio';
        matlabbatch{8}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0];
        matlabbatch{8}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        
        matlabbatch{8}.spm.stats.con.consess{4}.tcon.name = 'Stim';
        matlabbatch{8}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1];
        matlabbatch{8}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
        

    case 5
        
        matlabbatch{8}.spm.stats.con.consess{1}.tcon.name = 'Lips';
        matlabbatch{8}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0 0];
        matlabbatch{8}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        
        matlabbatch{8}.spm.stats.con.consess{2}.tcon.name = 'Wrist';
        matlabbatch{8}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0 0];
        matlabbatch{8}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        
        matlabbatch{8}.spm.stats.con.consess{3}.tcon.name = 'Hand';
        matlabbatch{8}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0 0];
        matlabbatch{8}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        
        matlabbatch{8}.spm.stats.con.consess{4}.tcon.name = 'Fingers';
        matlabbatch{8}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1 0];
        matlabbatch{8}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
        
        matlabbatch{8}.spm.stats.con.consess{5}.tcon.name = 'Ankle';
        matlabbatch{8}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 1];
        matlabbatch{8}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
        
        
    case 1
        
        matlabbatch{8}.spm.stats.con.consess{1}.tcon.name = 'Stim';
        matlabbatch{8}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0];
        matlabbatch{8}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        
end

matlabbatch{8}.spm.stats.con.delete = 0;



