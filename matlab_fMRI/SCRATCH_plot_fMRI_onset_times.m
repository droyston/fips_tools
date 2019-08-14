% 2019-07-08 Dylan Royston
%
% Quick script to plot onset times for all subjects in a condition, to see if there are any drift issues that could
% contribute to confusing data
%
%
%
%
%
%
%
%%

clear; clc;

subject_list =      {'CMC01', 'CMC03', 'CMC04', 'CMC05', 'CMC06', 'CMC07', 'CMC08', 'CMC09', 'CMC10', 'CMC11', 'CMC12',...
                     'CMC13', 'CMC14', 'CMC15', 'CMC17', 'CMC18', 'CMC19', 'CMC20', 'CMC22', 'CMC23', 'CMC24', 'CMC25',...
                     'CMC26', 'CMC27', 'CMS01', 'CMS02', 'CMS03', 'CMS04', 'CMS06', 'CMS07', 'CMS09', 'CMS10', 'CMS12', 'CMS13'};

% task_list =         {'Sensory_overt_fingers'};
task_list =         {'Motor_overt'};
% task_list =         'all';

num_subjects =      length(subject_list);
num_tasks =         length(task_list);


%%

for i=1 : length(subject_list)
     
    
    subject_id = subject_list{i};
    
    % start setting paths depending on OS
    if isunix
        study_path_design =    '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/[subject_id]';
        
    else
        study_path_design =    'R:\data_generated\human\covert_mapping\SUBJECT_DATA_STORAGE\[subject_id]\';
    end% IF isunix
    
    
    % extracts onset times/names from specific Covert Mapping paradigms
    
    % adds paradigm names for EPrime log extraction
    % 2016-09-07 Royston
    
    onset_times =    {};
    
    % for each paradigm in the run list, get onset times from the appropriate EPrime log (needs consistent names)
    for paradigm_idx = 1 : num_tasks
       
        paradigm = task_list(paradigm_idx);
        
        % OS path switch
        if isunix
            %             log_path_design =           '/home/dar147/Desktop/test_data/[subject_id]/EPrime Logs';
            log_path_design =           '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/[subject_id]/EPrime Logs';
        else
            log_path_design =           'R:\data_generated\human\covert_mapping\SUBJECT_DATA_STORAGE\[subject]\EPrime Logs';
        end% IF isunix
        
        strings_in.subject_id =     subject_id;
        
        log_path =                  str_from_design(strings_in, log_path_design);
        log_data =                  dir(log_path);
        log_names =                 {log_data(:).name};
        log_names =                 log_names(3:end);
        log_counter =               0;
        
        
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
        
        
        subject_onsets{paradigm_idx, i} = current_onsets;
        
        
    end% paradigm_idx loop
    
    
    
    
    
    
end% i




%%

color_range = jet(num_subjects);

figure; hold on;

for task_idx = 1 : num_tasks
    
    for subj_idx = 1 : num_subjects
        
        current_numbers =   subject_onsets{task_idx, subj_idx};
        
        dimensions =        size(current_numbers);
        
        if isempty(find(dimensions == 1))
            linear_nums =       sort(current_numbers(:), 'ascend');
        else
            linear_nums =       current_numbers;
        end
        
        line([linear_nums linear_nums], [0 1], 'Color', color_range(subj_idx, :) );
        
    end
    
    curr_lims = xlim;
    xlim([0 curr_lims(2)+10]);
    
end














