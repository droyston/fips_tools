% Script to run Analysis for fMRI data or pieces of analysis
%   SEE: Run_fMRI_Analysis.m
%
% Uses SPM for fMRI analysis and Freesurfer for reconstruction
% Can pick and choose which processing to do
%
% Step 1: Converts Raw to DICOM and NIFTI
% Step 2: Freesurfer reconstruction of surface, BEMs, and SUMA. REQUIRES: convert
% Step 3: fMRI analysis with SPM job. REQUIRES: convert, FS (needs a T1)
% Step 4: Convert SPM files to SUMA files. REQUIRES: FS, SPM
%
% Paths are modular
%
% 2014-01-09 [Foldes]
% UPDATES:
% 2014-04-03 Foldes: Clean up, defaults in MRI_Info_Class, etc
% 2015-03-17 Royston: Added subjects_to_process loop for multiple subject processing
% 2016-03-07 Royston: Updated to work with Covert Mapping paradigms (EPrime log look-up and model specifications)
% 2016-09-07 Royston: updated "all" check in CM to pull tasks from pre-curated subject folder
% 2019-07-12 Royston: re-adding some lost patches to enable smarter processing of "all" files (only unfinished tasks)

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
% subjects_to_process =             {'CMS01'};%, 'CMC09', 'CMC10', 'CMC11', 'CMS01'};
% subjects_to_process =           {'CMS12'};
% subjects_to_process =           {'CMC18', 'CMC19', 'CMC22', 'CMC23', 'CMC24', 'CMC25', 'CMC26', 'CMC27', 'CMS04', 'CMS07'};
% subjects_to_process =           {'CMS10', 'CMS13','CMC18', 'CMC19', 'CMC22', 'CMC23', 'CMC24', 'CMC25', 'CMC26', 'CMC27' };
% subjects_to_process =           {'NC01', 'NC02', 'NC03', 'NC04', 'NC05', 'NC06', 'NC07', 'NC08', 'NC09', 'NC10', 'NC11', 'NC12', 'NC13', 'NC14', 'NS01', 'NS02', 'NS03', 'NS04', 'NS06', 'NS07'};
% subjects_to_process =           {'NS01_initial', 'NS01_followup','NS02_initial', 'NS02_followup', 'NS03_initial', 'NS03_followup', 'NS04_initial', 'NS04_followup', 'NS06_initial', 'NS06_followup', 'NS07_initial', 'NS07_followup', 'NS12', 'NS13'};



% start setting paths depending on OS
if isunix
%     MRI_Info.study_path_design =    '/home/dar147/Desktop/test_data/[subject_id]';
%     MRI_Info.study_path_design =    '/home/dar147/data/rnel-fs-1/data_generated/human/covert_mapping/SUBJECT_DATA_STORAGE/[subject_id]/INDIVIDUAL';
    MRI_Info.study_path_design =    '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/[subject_id]';

    subjects_dir =                   '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE';
    
    delimiter =                     '/';
    
else
%     MRI_Info.study_path_design =    'R:\data_generated\human\covert_mapping\SUBJECT_DATA_STORAGE\[subject_id]';
    MRI_Info.study_path_design =    'R:\data_generated\human\craniux\new_imaging\[subject_id]';
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
% cd('R:\data_generated\human\covert_mapping\SUBJECT DATA STORAGE');

% MRI_Info is a container for all information needed for fMRI processing in this code.
MRI_Info = MRI_Info_Class;

MRI_Info.study_path_design =    [subjects_dir delimiter '[subject_id]'];
    
MRI_Info.subject_id =           subjects_to_process{i};
% Base Path Design (use [] for accessing MRI_Info property names)


% MRI_Info.study_path_design =    'R:\data_generated\human\fMRI_motor_imagery\New subject data storage\[subject_id]';

MRI_Info.epi_run_list =             {'all'};
% MRI_Info.epi_run_list =             {'ankle', 'elbow', 'fingers', 'grasp', 'wrist'};
% MRI_Info.epi_run_list =               {'grasp'};
% MRI_Info.epi_run_list =             {'Motor_covert_fingers', 'Motor_covert_hand', 'Motor_covert_wrist', 'Sensory_covert_fingers', 'Sensory_covert_wrist', 'Sensory_overt_fingers', 'Sensory_overt_wrist'};
% MRI_Info.epi_run_list =                 {'Motor_covert_fingers_sub'};

MRI_Info.spm_job =              'CM_norm_smooth.m'; % full path or must be in Matlab path
% MRI_Info.spm_job =              'CM_indiv_smooth_Fang.m'; % full path or must be in Matlab path
% MRI_Info.spm_job =              'SPM_Batch_Individual_Block_Design.m';


% extracts onset times/names from specific Covert Mapping paradigms
if Flags.CM == 1
    
    % adds paradigm names for EPrime log extraction
    % 2016-09-07 Royston
    
    onset_times =    {};

    if strcmp( MRI_Info.epi_run_list, 'all')
%        MRI_Info.epi_run_list = {'Motor_covert_hand', 'Motor_covert_fingers', 'Motor_covert_wrist', 'Motor_overt', ...
%            'Sensory_covert_fingers', 'Sensory_covert_wrist', 'Sensory_overt_fingers', 'Sensory_overt_wrist'};


       folder_names =   {};
       log_file_name =  {};
       
       strings_in.subject_id =     MRI_Info.subject_id;
       subject_path =           str_from_design(strings_in, MRI_Info.study_path_design);
       subject_dir =           [subject_path '/NIFTI'];
       
%        cd(subject_path);
       
       subject_folders =          dir(subject_dir);
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
%             log_path_design =           '/home/dar147/Desktop/test_data/[subject_id]/EPrime Logs';
            log_path_design =           '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/[subject]/EPrime Logs';
        else
            log_path_design =           'R:\data_generated\human\covert_mapping\SUBJECT_DATA_STORAGE\[subject]\EPrime Logs';
        end% IF isunix
        
        log_path =                  str_from_design(strings_in, log_path_design);
        log_data =                 dir(log_path);
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
            
            [higher_val, high_idx] =          max(check_nums);
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
    
else% CM flag
    % hard-coded values for old MEG-NF data
    
    % Experimental Design Info
    MRI_Info.ExpDef_TR =             2; % TR 'Interscan interval'
    MRI_Info.ExpDef_event_onsets =   [10 30 50 70]; % vector of when conditions/events happen, in scan # (hardcoded, but can be changed)
    MRI_Info.ExpDef_event_duration = 10; % num scans for the event/condition to happen
    
end

MRI_Info.FS_script =            'FreesurferReconstruction.sh'; % Relative paths if in Matlab Path
MRI_Info.SPM2SUMA_script =      'SPM2SUMA.sh';

%% =======================================================
%  ===PROCESSING==========================================
%  =======================================================

if ~isempty(MRI_Info.epi_run_list)
    MRI_Info = Run_fMRI_Analysis(MRI_Info,Flags);
else
    disp(['*** NO BLANK TASKS, SKIPPING SUBJECT ' subjects_to_process{i} ' ***']);
end

end% subjects