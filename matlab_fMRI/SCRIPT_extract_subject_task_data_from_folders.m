% 2017-03-16 Dylan Royston
%
% Script to run through Covert Mapping subject folders and extract folder names to determine data coverage
%
%
%
%
%
%
%
%% extract task names from subject folders

clear; clc;


if isunix
    directory =                 '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE';
    
    delimiter =                 '/';
else
    
end


subject_folders =           dir(directory);
name_list =                 {subject_folders(:).name};
subject_folder_names =      char(subject_folders.name);

subject_idx =               0;
subject_task_names =        {};
subject_nums =              {};

for file_idx = 3 : length(subject_folders)
    
    current_name =              subject_folders(file_idx).name;
    
    is_subject =                strfind(current_name, 'CM');
    
    if is_subject == 1
        
        subject_idx =                       subject_idx + 1;
        subject_nums{subject_idx} =         current_name;
        
        
        curr_folder_files =                 dir([directory delimiter current_name]);
        curr_folder_names =                 {curr_folder_files(:).name};
        
        info_present =                      strfind(curr_folder_names, 'INFO');
        info_names =                        {curr_folder_files( find(not(cellfun('isempty', info_present) ) ) ).name};
        
        subject_info{subject_idx} =         info_names;
        
        subject_data_path =                 [directory delimiter current_name delimiter 'NIFTI'];
        
        current_subject_tasks =             dir(subject_data_path);
        subject_task_names{subject_idx} =   {current_subject_tasks(:).name};
        
    end
    
end


%% compile task names into data coverage table


main_task_list = {'Motor_covert_fingers', 'Motor_covert_hand', 'Motor_covert_wrist', 'Motor_overt',...
    'Sensory_covert_fingers', 'Sensory_overt_fingers', 'Sensory_covert_wrist', 'Sensory_overt_wrist',...
    'Sensory_overt_hand', 'Sensory_covert_fingers_extra', 'Sensory_overt_fingers_extra'};

text_task_list = {'Motor Covert Fingers', 'Motor Covert Hand', 'Motor Covert Wrist', 'Motor Overt',...
    'Sensory Covert Fingers', 'Sensory Overt Fingers', 'Sensory Covert Wrist', 'Sensory Overt Wrist',...
    'Sensory Overt Hand', 'Sensory Covert Fingers Extra', 'Sensory Overt Fingers Extra'};

num_subjects =      length(subject_nums);
num_tasks =         length(main_task_list);

data_coverage =     zeros(num_tasks+1, num_subjects+1);

for subject_idx = 1 : num_subjects
    
    clearvars tactor_loc info_names tactor_info curr_info
    curr_subject =  subject_nums{subject_idx};
    
    curr_tasks =    subject_task_names{subject_idx};
    
    curr_info =     subject_info{subject_idx};
    tactor_info =   strfind(curr_info, 'INFO_tactor_location');
    info_names =    curr_info( find(not(cellfun('isempty', tactor_info) ) ) );
    
    switch info_names{:}
        case 'INFO_tactor_location_hand'
            tactor_loc =    1;
        case 'INFO_tactor_location_clavicle'
            tactor_loc =    2;
    end
        
    
    for task_idx = 1 : num_tasks
        
        curr_target_task =      main_task_list{task_idx};
        string_present =        strfind(curr_tasks, curr_target_task);
        index =                 find(not(cellfun('isempty', string_present) ) );
        
        % 2017-06-30 Royston: added check to swap color idx for extra runs (since they're always the opposite, by definition)
        if ~isempty(strfind(curr_target_task, 'extra') )
            switch tactor_loc
                case 1
                    curr_tactor_loc = 2;
                case 2
                    curr_tactor_loc = 1;
            end
        else
            curr_tactor_loc = tactor_loc;
        end
        
        if ~isempty(index)
            
            % 2019-07-16 Royston: patching to indicate if folder contains raw and finished SPM images
            task_files =        dir( [directory delimiter curr_subject delimiter 'NIFTI' delimiter curr_target_task] );
            task_filenames =    {task_files(:).name};
            
            is_finished =       ~isempty( FUNC_find_string_in_cell(task_filenames, 'spm') );

            if is_finished
                data_coverage(task_idx, subject_idx) = curr_tactor_loc;
            else
                data_coverage(task_idx, subject_idx) = -1;
            end
        end
        
    end%task_idx
    
end%subject_idx


%% plot coverage table

figure; 
pcolor(data_coverage);
colormap(bone);
y_tick_locs = get(gca, 'YTick') + 0.5;
x_tick_locs = get(gca, 'XTick');

set(gca, 'YTick', 1.5:num_tasks+1 );
set(gca, 'YTickLabel', text_task_list);

set(gca, 'XTick', 1.5:num_subjects+1);
set(gca, 'XTickLabel', subject_nums);
set(gca, 'XTickLabelRotation', 45);

num_controls =      length(find(not(cellfun('isempty', (strfind(subject_nums, 'CMC')) ) ) ) );
num_SCI =           length(find(not(cellfun('isempty', (strfind(subject_nums, 'CMS')) ) ) ) );

hold on;
line([num_controls+1 num_controls+1], [1 num_tasks+1], 'Color', 'r', 'LineWidth', 2);

title_string = sprintf('Subject data coverage \n AB= %i || SCI= %i', num_controls, num_SCI);
title(title_string);


set(gcf, 'Position', [437 170 1448 808]);


