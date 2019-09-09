% 2019-09-08 Dylan Royston
% Updated shell script to run file-conversion, organization, and preprocessing through SPM12 and Freesurfer
%
%   SEE: FIPS_r2c_Run_All.m
%
% Uses Freesurfer for cortical reconstruction, SPM for fMRI preprocessing/analysis
% Can pick and choose which processing to do
%
% Step 1: Converts Raw to DICOM and NIFTI
% Step 2: Freesurfer reconstruction of surface, BEMs, and SUMA. REQUIRES: convert
% Step 3: fMRI analysis with SPM job. REQUIRES: convert, FS (needs a T1)
% Step 4: Convert SPM files to SUMA files. REQUIRES: FS, SPM
%
% Paths are modular
%
% Adapted from SCRIPT_run_fMRI_analysis (2014-01-09 [Foldes])
% UPDATES:
% 
%%
clear
clc

%% Processing Flags

Flags.convert =     0; % Step 1: Converts Raw to DICOM and NIFTI
Flags.FS =          0; % Step 2: Freesurfer reconstruction. REQUIRES: convert
Flags.SPM =         1; % Step 3: fMRI analysis with SPM job. REQUIRES: convert, FS (needs a T1)
Flags.SPM2SUMA =    0; % Step 4: Convert SPM files to SUMA files. REQUIRES: FS, SPM

Flags.CM =          1;% 0 for dumb conversion, 1 for smart CM SPM processing


%% PARAMETERS

% % MRI_Info is a container for all information needed for fMRI processing in this code.
% MRI_Info = MRI_Info_Class;

subjects_to_process =             {'all'};

% start setting paths depending on OS
if isunix
    MRI_Info.study_path_design =    'project_path/SUBJECT_DATA_STORAGE/[subject_id]';
    subjects_dir =                   'project_path/SUBJECT_DATA_STORAGE';
else
    MRI_Info.study_path_design =    'project_path\[subject_id]';
end% IF isunix

% 2019-07-12 Royston: if passed 'all' subjects, rewrite subjects_to_process as all subject IDs in directory
if length(subjects_to_process) == 1
    
    if strcmp(subjects_to_process{1}, 'all')
        
        all_folder_details =          dir(subjects_dir);
        all_names =                   {all_folder_details(:).name};
        
        valid_subjects =              FUNC_find_string_in_cell(all_names, 'CM');
        
        subjects_to_process =         all_names(valid_subjects);
        
    end
    
end


for i = 1 : length(subjects_to_process)

clearvars -except Flags subjects_to_process i subjects_dir delimiter

% MRI_Info is a container for all information needed for fMRI processing in this code.
MRI_Info = MRI_Info_Class;

MRI_Info.study_path_design =    fullfile(subjects_dir, [subject_id]');
    
MRI_Info.subject_id =           subjects_to_process{i};
% Base Path Design (use [] for accessing MRI_Info property names)



MRI_Info.epi_run_list =          {'all'};

MRI_Info.spm_job =              'FIPS_r2c_batch_norm_smooth.m'; % full path or must be in Matlab path


% extracts onset times/names from specific Covert Mapping paradigms
if Flags.CM == 1
    
    % adds paradigm names for EPrime log extraction
    % 2016-09-07 Royston
    
    onset_times =    {};

    if strcmp( MRI_Info.epi_run_list, 'all')

       folder_names =   {};
       log_file_name =  {};
       
       strings_in.subject_id =  MRI_Info.subject_id;
       subject_path =           str_from_design(strings_in, MRI_Info.study_path_design);
       subject_dir =            [subject_path '/NIFTI'];
       
%        cd(subject_path);
       
       subject_folders =        dir(subject_dir);
       task_counter =           0;
       
       for file_idx = 3 : length(subject_folders) 
           
           
           curr_name =                  subject_folders(file_idx).name;
           
           string_test =                strsplit(curr_name, '_');
           
           if length(string_test) > 1% if the folder name contains underscores, meaning it's a task folder
           
               % 2017-06-21 Royston: added checks for excluding non-task folders
               if ~isempty( strfind(curr_name, 'Motor') ) || ~isempty( strfind(curr_name, 'Sensory') )
                   
                   % 2019-07-12 Royston: only process folder if it doesn't already contain an spmT contrast
                   task_files =             dir([subject_dir delimiter curr_name]);
                   filenames =              {task_files(:).name};
                   is_processed =           FUNC_find_string_in_cell(filenames, 'spmT');
                   
                   if isempty(is_processed)
                       task_counter =                   task_counter + 1;
                       folder_names{task_counter} =     curr_name;
                   end
                   
               end% strcmp
           
           end% length(string_test)
           
       end% file_idx
       
       MRI_Info.epi_run_list = folder_names;
       
    end% if all
    
    % for each paradigm in the run list, get onset times from the appropriate EPrime log (needs consistent names)
    for paradigm_idx = 1 : length(MRI_Info.epi_run_list)
        
        strings_in.subject =        MRI_Info.subject_id;
        strings_in.paradigm =       MRI_Info.epi_run_list(paradigm_idx);
        paradigm =                  strings_in.paradigm;
        
        % OS path switch
        if isunix
            log_path_design =           'project_path/SUBJECT_DATA_STORAGE/[subject]/EPrime Logs';
        else
            log_path_design =           'project_path\SUBJECT_DATA_STORAGE\[subject]\EPrime Logs';
        end% IF isunix
        
        log_path =                  str_from_design(strings_in, log_path_design);
        log_data =                  dir(log_path);
        log_names =                 {log_data(:).name};
        log_names =                 log_names(3:end);
        log_counter =               0;

        num_tasks =                 length(MRI_Info.epi_run_list);
%         num_tasks =                 length(folder_names);
        
        current_onsets =            zeros(5, 5);
        
        paradigm_parts =            strsplit(paradigm{:}, '_');
        
        % if a task is _extra, just use the first part
        if length(paradigm_parts) > 3
            new_string =                paradigm{:};
            log_idx =                   FUNC_find_string_in_cell( log_names, new_string(1:end-6) );
        else
            log_idx =                   FUNC_find_string_in_cell(log_names, paradigm);
        end% IF length
        
       
        if length(log_idx) > 1
            temp_logs =             {log_names{log_idx}};
            
            % finds trial numbers on repeated log names
            for itemp = 1 : length(temp_logs)
                parts =                 strsplit(temp_logs{itemp}, '-');
                test_nums =             strsplit(parts{3}, '.');
                check_nums(itemp) =     str2num(test_nums{1});
            end
            
            [higher_val, high_idx] =         max(check_nums);
            [lower_val, low_idx] =           min(check_nums);
            
            % assigns higher trial num to repeated task
            is_extra =              strfind(paradigm{1}, 'extra');
            if is_extra
                desired_log =           log_idx(high_idx);
            else
                desired_log =           log_idx(low_idx);
            end
            
            log_idx = desired_log;
            
        end
        
        target_log =                    log_names{log_idx};
        
        if isunix
            full_name =                     [log_path '/' target_log];
        else
            full_name =                     [log_path '\' target_log];
        end% IF isunix
        
        current_onsets =                eprimeparse(full_name);
        onset_times{paradigm_idx} =     current_onsets;
                
                
                    
        anat_only = ~exist('onset_times', 'var');
        
        if anat_only
            onset_times{paradigm_idx} = [NaN];%2016-06-15 Royston
        end
        
        
    end% paradigm_idx loop
    
    MRI_Info.ExpDef_TR =                2;% length of TR (in sec)
    MRI_Info.ExpDef_event_onsets =      onset_times;% cell array of n*5 onset time matrices
    MRI_Info.ExpDef_event_duration =    5;% number of TRs in 'move' condition (10 sec)
    
else% smart-onset flag
    % hard-coded values for old MEG-NF data
    
    % Experimental Design Info
    MRI_Info.ExpDef_TR =             2; % TR 'Interscan interval'
    MRI_Info.ExpDef_event_onsets =   [10 30 50 70]; % vector of when conditions/events happen, in scan # (hardcoded, but can be changed)
    MRI_Info.ExpDef_event_duration = 10; % num scans for the event/condition to happen
    
end

MRI_Info.FS_script =            'FIPS_r2c_FreesurferReconstruction.sh'; % Relative paths if in Matlab Path
MRI_Info.SPM2SUMA_script =      'FIPS_r2c_SPM2SUMA.sh';

%% =======================================================
%  ===PROCESSING==========================================
%  =======================================================

if ~isempty(MRI_Info.epi_run_list)
    MRI_Info = FIPS_r2c_Run_All(MRI_Info,Flags);
else
    disp(['*** NO BLANK TASKS, SKIPPING SUBJECT ' subjects_to_process{i} ' ***']);
end

end% subjects