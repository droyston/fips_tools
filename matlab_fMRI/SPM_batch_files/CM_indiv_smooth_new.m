%
%
%
%
%
%
%
%
%
%
%
%
%%

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

% number of files in NII (2014-01-06)
nFiles =length(spm_vol(current_epi));
tempFile = cell(nFiles,1);
for i = 1:nFiles
    niiStr = sprintf('.nii,%d',i);
    tempStr = [file_path filesep file_name niiStr];
    tempFile{i} = tempStr;
end

%% 

matlabbatch{1}.spm.spatial.realign.estwrite.data = {tempfile}';

matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = {''};
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r1';

%%

matlabbatch{2}.spm.spatial.smooth.data(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
matlabbatch{2}.spm.spatial.smooth.fwhm = [6 6 6];
matlabbatch{2}.spm.spatial.smooth.dtype = 0;
matlabbatch{2}.spm.spatial.smooth.im = 0;
matlabbatch{2}.spm.spatial.smooth.prefix = 's';

%%

matlabbatch{3}.spm.stats.fmri_spec.dir = {file_path};
matlabbatch{3}.spm.stats.fmri_spec.timing.units = 'scans';
matlabbatch{3}.spm.stats.fmri_spec.timing.RT = MRI_Info.current.ExpDef_TR;% <--- VARIABLE
matlabbatch{3}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{3}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
matlabbatch{3}.spm.stats.fmri_spec.sess.scans(1) = cfg_dep('Smooth: Smoothed Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
num_conditions = size(MRI_Info_current.ExpDef_event_onsets, 1);

switch num_conditions
    case 4% COVERT
        
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).name = 'Simple';
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).onset = MRI_Info_current.ExpDef_event_onsets(1, :);%<-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).orth = 1;
        
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(2).name = 'Goal';
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(2).onset = MRI_Info_current.ExpDef_event_onsets(2, :);%<-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(2).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(2).orth = 1;
        
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(3).name = 'Audio';
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(3).onset = MRI_Info_current.ExpDef_event_onsets(3, :);%<-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(3).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(3).orth = 1;
        
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(4).name = 'Stim';
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(4).onset = MRI_Info_current.ExpDef_event_onsets(4, :);%<-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(4).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(4).orth = 1;

    case 5% OVERT MOTOR
        
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).name = 'Lips';
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).onset = MRI_Info_current.ExpDef_event_onsets(1, :);%<-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).orth = 1;
        
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(2).name = 'Wrist';
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(2).onset = MRI_Info_current.ExpDef_event_onsets(2, :);%<-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(2).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(2).orth = 1;
        
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(3).name = 'Hand';
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(3).onset = MRI_Info_current.ExpDef_event_onsets(3, :);%<-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(3).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(3).orth = 1;
        
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(4).name = 'Fingers';
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(4).onset = MRI_Info_current.ExpDef_event_onsets(4, :);%<-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(4).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(4).orth = 1;
        
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(5).name = 'Ankle';
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(5).onset = MRI_Info_current.ExpDef_event_onsets(5, :);%<-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(5).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(5).tmod = 0;
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(5).orth = 1;
        
    case 1% OVERT SENSORY
        
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).name = 'Stim';
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).onset = MRI_Info_current.ExpDef_event_onsets(1, :);%<-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).duration = MRI_Info_current.ExpDef_event_duration;% <-- VARIABLE
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{3}.spm.stats.fmri_spec.sess.cond(1).orth = 1;

end% switch

matlabbatch{3}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{3}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{3}.spm.stats.fmri_spec.sess.multi_reg = {''};
matlabbatch{3}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{3}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{3}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{3}.spm.stats.fmri_spec.volt = 1;
matlabbatch{3}.spm.stats.fmri_spec.global = 'None';
matlabbatch{3}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{3}.spm.stats.fmri_spec.mask = {''};
matlabbatch{3}.spm.stats.fmri_spec.cvi = 'AR(1)';

%%

matlabbatch{4}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{4}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{4}.spm.stats.fmri_est.method.Classical = 1;

%%

matlabbatch{5}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));

switch num_conditions
    case 4
        
        matlabbatch{5}.spm.stats.con.consess{1}.tcon.name = 'Simple';
        matlabbatch{5}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0];
        matlabbatch{5}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        
        matlabbatch{5}.spm.stats.con.consess{2}.tcon.name = 'Goal';
        matlabbatch{5}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0];
        matlabbatch{5}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        
        matlabbatch{5}.spm.stats.con.consess{3}.tcon.name = 'Audio';
        matlabbatch{5}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0];
        matlabbatch{5}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        
        matlabbatch{5}.spm.stats.con.consess{4}.tcon.name = 'Stim';
        matlabbatch{5}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1];
        matlabbatch{5}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
        
        matlabbatch{5}.spm.stats.con.consess{5}.fcon.name = 'Movement artifact';
        matlabbatch{5}.spm.stats.con.consess{5}.fcon.weights = [0 0 0 0 1 1 1];
        matlabbatch{5}.spm.stats.con.consess{5}.fcon.sessrep = 'none';

    case 5
        
        matlabbatch{5}.spm.stats.con.consess{1}.tcon.name = 'Lips';
        matlabbatch{5}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0 0];
        matlabbatch{5}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        
        matlabbatch{5}.spm.stats.con.consess{2}.tcon.name = 'Wrist';
        matlabbatch{5}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0 0];
        matlabbatch{5}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        
        matlabbatch{5}.spm.stats.con.consess{3}.tcon.name = 'Hand';
        matlabbatch{5}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0 0];
        matlabbatch{5}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        
        matlabbatch{5}.spm.stats.con.consess{4}.tcon.name = 'Fingers';
        matlabbatch{5}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1 0];
        matlabbatch{5}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
        
        matlabbatch{5}.spm.stats.con.consess{5}.tcon.name = 'Ankle';
        matlabbatch{5}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 1];
        matlabbatch{5}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
        
        matlabbatch{5}.spm.stats.con.consess{6}.fcon.name = 'Movement artifact';
        matlabbatch{5}.spm.stats.con.consess{6}.fcon.weights = [0 0 0 0 0 1 1 1];
        matlabbatch{5}.spm.stats.con.consess{6}.fcon.sessrep = 'none';
        
    case 1
        
        matlabbatch{5}.spm.stats.con.consess{1}.tcon.name = 'Stim';
        matlabbatch{5}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0];
        matlabbatch{5}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        
end

matlabbatch{5}.spm.stats.con.delete = 0;



