% 2017-03-28 Dylan Royston
%
% Script to examine raw BOLD time-series as a data quality check
%
%
%
%
%
%
%
%% 1. Set up variables for processing
clear;
clc;

display('*** INITIALIZING VARIABLES ***');


% file path to subject folders
study_path =        'R:\data_generated\human\covert_mapping\SUBJECT DATA STORAGE\[subject_id]\NIFTI\[current_paradigm]';

% list of subjects to process
subject_list =          {'CMC01', 'CMC03', 'CMC04', 'CMC05', 'CMC07', 'CMC09', 'CMC10', 'CMC11', 'CMC12', 'CMC13', 'CMC14', 'CMC15', 'CMC17'};
% subject_list =          {'CMS01', 'CMS02', 'CMS03'};

num_subjects =          length(subject_list);


% list of conditions to process
paradigms = {'Motor_covert_fingers', 'Motor_covert_hand', 'Motor_covert_wrist', 'Motor_overt',...
    'Sensory_covert_fingers', 'Sensory_covert_wrist'};

num_paradigms = length(paradigms);

plaintext_paradigms = {'Motor Covert Fingers', 'Motor Covert Hand', 'Motor Covert Wrist', 'Motor Overt',...
    'Sensory Covert Fingers', 'Sensory Covert Wrist'};
%


% ALL
% paradigms = {'Motor_covert_fingers', 'Motor_covert_hand', 'Motor_covert_wrist', 'Motor_overt',...
%     'Sensory_covert_fingers', 'Sensory_covert_wrist',...
%     'Sensory_overt_fingers', 'Sensory_overt_hand', 'Sensory_overt_wrist'};

% plaintext_paradigms = {'Motor Covert Fingers', 'Motor Covert Hand', 'Motor Covert Wrist', 'Motor Overt',...
%     'Sensory Covert Fingers', 'Sensory Covert Wrist',...
%     'Sensory Overt Fingers', 'Sensory Overt Hand', 'Sensory Overt Wrist'};


% paradigms = {'Motor_covert_hand', 'Motor_covert_wrist', 'Motor_overt','Sensory_covert_wrist'};

% plaintext_paradigms = {'Motor Covert Hand', 'Motor Covert Wrist', 'Motor Overt','Sensory Covert Wrist'};

% establishes custom class/structure for subject/condition/ROI data structure
ROI_stats =             ROI_stats_class;

% Sets which ROIs to be analyzed (calibrated for MNI regions
% Individual data can be analyzed similarly but may require inverse-normalization transformation matrix
ROI_list =              {'MNI_Precentral_L_ROI', 'MNI_Postcentral_L_ROI', 'MNI_Supp_Motor_Area_L_ROI', 'MNI_Parietal_Combined_L', ...
    'MNI_Precentral_R', 'MNI_Postcentral_R', 'MNI_Supp_Motor_Area_R', 'MNI_Parietal_Combined_R'};

plaintext_ROIs =        {'L Precentral', 'L Postcentral', 'L SMA', 'L PPC', 'R Precentral', 'R Postcentral', 'R SMA', 'R PPC'};

num_ROI =               length(ROI_list);

ROI_path =              'R:\data_generated\human\covert_mapping\CM Analysis Tools\ROI\marsbar-aal-0.2_NIFTIS\';

motor_ROI_path =        [ROI_path ROI_list{1} '.nii'];

%%

for subject_idx = 1 : num_subjects
    
    figure; hold on;
    
    clearvars curr_data
    for task_idx = 1 : num_paradigms
        
        curr_data.subject_id =          subject_list{subject_idx};
        curr_data.current_paradigm =    paradigms{task_idx};
        
        task_path =         str_from_design(curr_data, study_path);
        
        task_files =        dir(task_path);
        task_file_names =   {task_files(:).name};
        
%         task_wepi =         cellfun(@strfind, task_file_names, 'w*');
        task_wepi =             task_file_names(FUNC_find_string_in_cell(task_file_names, 'w') );
        warped =            task_wepi{ strncmpi(task_wepi, 'w', 1) };
        
        warped_path =       [task_path '\' warped];
        
        % currently throwing 'nifti is corrupted' message from load_nii_hdr
        task_time_series =      extract_stats_from_epi(motor_ROI_path, warped_path);
        % need to get to the raw time series of M1/S1 during at least simple, maybe all conditions
        
        
        
        
        
        
        
    end
    
    
    
    
    
    
end












