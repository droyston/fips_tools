% 2016-07-18 Dylan Royston
%
% Updated script to analyze fMRI-MI dataset
% Code based on SCRIPT_Analyze_covert_mapping
%
%
% === UPDATES ===
% 2016-07-26 Royston: finished primary build, generates line-scatter and sig-starred bar plots
% 2016-07-29 Royston: added significant voxel count analysis; variables are hard-coded names until it's necessary to fix that
%
%%

clear;
clc;

display('*** INITIALIZING VARIABLES ***');

% flags
figure_flag =           1;% 0 = don't save, 1 = save
ROI_path_flag =         0;% 0 = standardized, 1 = custom
analysis_method =       'mean';% can be 'indiv' for individual subjects, or 'mean' for across-subject analysis
% flag for whether to load subject's dominant handedness data (1 = yes)
dominance_flag =        1;
age_match =             0;
% plot flags
bar_plots =         0;
scatter_plots =     1;

reprocess_data =    0;

% file path to subject folders
study_path =        'R:\data_generated\human\fMRI_motor_imagery\New subject data storage\[subject_id]\NIFTI\[current_paradigm]';

% list of subjects to process
% subject_list =          {'NS12'};
% subject_list =          {'NC01', 'NC02', 'NC03', 'NC04', 'NC05', 'NC06', 'NC07', 'NC08', 'NC09', 'NC10', 'NC11', 'NC12', 'NC13', 'NC14'};
% subject_list =              {'NS01', 'NS02', 'NS03', 'NS04', 'NS06', 'NS07', 'NS12', 'NS13'};

% subject_list =          {'NC01', 'NC02', 'NC03', 'NC04', 'NC05', 'NC06', 'NC07', 'NC08', 'NC09', 'NC10', 'NC11', 'NC12', 'NC13', 'NC14',...
%     'NS01', 'NS02', 'NS03', 'NS04', 'NS06', 'NS07', 'NS12', 'NS13'};

subject_list =          {'NC02', 'NC03', 'NC04', 'NC06', 'NC07', 'NC09', 'NC10', 'NC11', 'NC12', 'NC13', 'NC14'};
% subject_list = {'NC02', 'NC07'};


% list of conditions to process
% if dominance_flag ==1, organize_extracted_fmri_stats looks for a [side]_ prefix to read in L/R tasks appropriately
paradigms = {'RT_hand_grasp_attempted', 'LT_hand_grasp_attempted'};

plaintext_paradigms = {'RT. Hand Grasp Attempted', 'LT. Hand Grasp Attempted'};

% establishes custom class/structure for subject/condition/ROI data structure
ROI_stats =             ROI_stats_class;

% Sets which ROIs to be analyzed (calibrated for MNI regions
% Individual data can be analyzed similarly but may require inverse-normalization transformation matrix
ROI_list =              {'MNI_Precentral_L_ROI', 'MNI_Postcentral_L_ROI', 'MNI_Supp_Motor_Area_L_ROI', 'MNI_Parietal_Sup_L', ...
    'MNI_Precentral_R', 'MNI_Postcentral_R', 'MNI_Supp_Motor_Area_R', 'MNI_Parietal_Sup_R'};

plaintext_ROIs =        {'L Precentral', 'L Postcentral', 'L SMA', 'L PPC', 'R Precentral', 'R Postcentral', 'R SMA', 'R PPC'};


ROI_path = 'C:\hst2\Analysis Code\Dylan\NeuROImaging\ROI\marsbar-aal-0.2_NIFTIS\';





num_subjects =      length(subject_list);
num_paradigms =     length(paradigms);
num_ROI =           length(ROI_list);



%% 2. Automatically age-match controls to SCI subjects
display('*** AGE-MATCHING AND PULLING EVALUATION STATS ***');

if age_match == 1
    % gets functional evaluation stats from existing Excel
    testload =          Load_Function_Screening('R:\data_generated\human\fMRI_motor_imagery\Neurofeedback_Function_Screening.xls');
    DB_vals =           testload(DB_find_idx(testload,'session','Baseline'));
    
    for i=1:length(subject_list)
        subjects_eval(i) =       DB_vals( DB_find_idx( DB_vals, 'subject', subject_list{i} ) );
        ages(i) =                subjects_eval(i).Age;
    end
    
    [closest_val, closest_idx] =    find_age_matches(ages, ages);
    subject_list =                  subject_list(closest_idx);
    
    clear subjects_eval ages
    
    for i=1:length(subject_list)
        subjects_eval(i) =        DB_vals( DB_find_idx( DB_vals, 'subject', subject_list{i} ) );
        ages(i) =                 subjects_eval(i).Age;
    end
end

if age_match == 0
    testload =          Load_Function_Screening('R:\data_generated\human\fMRI_motor_imagery\Neurofeedback_Function_Screening.xls');
    DB_vals =           testload(DB_find_idx(testload,'session','Baseline'));
    
    for i=1:length(subject_list)
        subjects_eval(i) =        DB_vals( DB_find_idx( DB_vals, 'subject', subject_list{i} ) );
    end
    
end



%% Hand dominance checks
% 2015-09-28

if dominance_flag == 1
    
    for s=1:length(subject_list)
        
        switch subjects_eval(s).Dominant_Hand
            case 'Right'
                handedness{s} = 'RT';
            case 'Left'
                handedness{s} = 'LT';
        end% switch
        
    end% subject loop
    
end% if

%% ======================================== Stat extraction =================================================

save_path = 'R:\data_generated\human\fMRI_motor_imagery\New subject data storage\HAND_DOMINANCE_DATA\';

display('*** EXTRACTING STATS FROM CONTRAST FILES ***')

for subject_idx = 1 : num_subjects
    
% sets up inputs for organization function
metadata_struct.subject_list =         subject_list(subject_idx);
metadata_struct.dominance_flag =       dominance_flag;
metadata_struct.handedness =           handedness;
metadata_struct.paradigms =            paradigms;
metadata_struct.ROI_list =             ROI_list;
metadata_struct.ROI_path =             ROI_path;
metadata_struct.study_path =           study_path;

loaded_data =       Load_Preproc_fMRI_Data(metadata_struct, save_path);

if reprocess_data == 0
    reprocess_data =    loaded_data.reprocess_data;
end

    
if reprocess_data == 1
    
    display('*** EXTRACTING STATS FROM CONTRAST FILES ***')
    
    % extracts and organizes data from spmT contrast files
    data_struct =     organize_extracted_fmri_stats(metadata_struct);
    Save_Preproc_fMRI_Data(data_struct, metadata_struct, save_path, reprocess_data);
    
else
    data_struct =       loaded_data.data_struct;
end


% hard-coded transformations, not needed for anything
% x_transform =                       output_struct.x_transform;
% y_transform =                       output_struct.y_transform;
% z_transform =                       output_struct.z_transform;

% organizes function outputs, indexed by ROI/subject/paradigm/condition
master_list(subject_idx, :) =                       data_struct.master_list;
ROI_peak_vals(:, subject_idx, :) =                  data_struct.ROI_peak_vals;
ROI_peak_locs(:, subject_idx, :) =                  data_struct.ROI_peak_locs;
ROI_active_count(:, subject_idx, :) =               data_struct.ROI_active_count;
ROI_active_vals(:, subject_idx, :) =                data_struct.ROI_active_vals;
ROI_active_locs(:, subject_idx, :) =                data_struct.ROI_active_locs;
ROI_sig_count(:, subject_idx, :) =                  data_struct.ROI_sig_count;
ROI_sig_vals(:, subject_idx, :) =                   data_struct.ROI_sig_vals;
ROI_sig_locs(:, subject_idx, :) =                   data_struct.ROI_sig_locs;

end

% organizes function outputs, indexed by ROI/subject/paradigm/condition
% master_list =                    data_struct.master_list;
% ROI_peak_vals =                  data_struct.ROI_peak_vals;
% ROI_peak_locs =                  data_struct.ROI_peak_locs;
% ROI_active_count =               data_struct.ROI_active_count;
% ROI_active_vals =                data_struct.ROI_active_vals;
% ROI_active_locs =                data_struct.ROI_active_locs;
% ROI_sig_count =                  data_struct.ROI_sig_count;
% ROI_sig_vals =                   data_struct.ROI_sig_vals;
% ROI_sig_locs =                   data_struct.ROI_sig_locs;

%% Handedness activity

clearvars right_handed_data left_handed_data right_subjects left_subjects

right_subjects = 0;
left_subjects = 0;

for subject_idx = 1 : num_subjects
        
        if strcmp(handedness{subject_idx}, 'RT')
            
            right_subjects = right_subjects + 1;
            
            right_handed_data(right_subjects, 1, 1, :) = ROI_peak_vals(:, subject_idx, 1);
            right_handed_data(right_subjects, 1, 2, :) = ROI_sig_count(:, subject_idx, 1);
            
            right_handed_data(right_subjects, 2, 1, :) = ROI_peak_vals(:, subject_idx, 2);
            right_handed_data(right_subjects, 2, 2, :) = ROI_sig_count(:, subject_idx, 2);
        else
            
            left_subjects = left_subjects + 1;
            left_handed_data(left_subjects, 1, 1, :) = ROI_peak_vals(:, subject_idx, 1);
            left_handed_data(left_subjects, 1, 2, :) = ROI_sig_count(:, subject_idx, 1);
            
            left_handed_data(left_subjects, 2, 1, :) = ROI_peak_vals(:, subject_idx, 2);
            left_handed_data(left_subjects, 2, 2, :) = ROI_sig_count(:, subject_idx, 2);
            
        end
end


group_data{1} = right_handed_data;
group_data{2} = left_handed_data;

group_names{1} = 'Right Dominant';
group_names{2} = 'Left Dominant';


%% Plot peak activations


for group_idx = 1 : 2
    
    current_group_data =       group_data{group_idx};
    reduced_group_data =        squeeze(current_group_data);
    
    figure; hold on;
    
    % assign ROI-specific line details
    h1 = subplot(4, 2, 1);
    curr_data = squeeze( current_group_data(:, 1, 1, :) );
    boxplot(curr_data(:, [1 5]));
    title('RT Grasp')
    set(gca, 'XTickLabels', {'Left M1', 'Right M1'});
    
    h2 = subplot(4, 2, 2);
    curr_data = squeeze( current_group_data(:, 2, 1, :) );
    boxplot(curr_data(:, [1 5]));
    title('LT Grasp')
    set(gca, 'XTickLabels', {'Left M1', 'Right M1'});
    
    
    h3 = subplot(4, 2, 3);
    curr_data = squeeze( current_group_data(:, 1, 1, :) );
    boxplot(curr_data(:, [2 6]));
    title('RT Grasp')
    set(gca, 'XTickLabels', {'Left S1', 'Right S1'});
    
    
    h4 = subplot(4, 2, 4);
    curr_data = squeeze( current_group_data(:, 2, 1, :) );
    boxplot(curr_data(:, [2 6]));
    title('LT Grasp')
    set(gca, 'XTickLabels', {'Left S1', 'Right S1'});
    
    %
    h5 = subplot(4, 2, 5);
    curr_data = squeeze( current_group_data(:, 1, 1, :) );
    boxplot(curr_data(:, [3 7]));
    title('RT Grasp')
    set(gca, 'XTickLabels', {'Left SMA', 'Right SMA'});
    
    h6 = subplot(4, 2, 6);
    curr_data = squeeze( current_group_data(:, 2, 1, :) );
    boxplot(curr_data(:, [3 7]));
    title('LT Grasp')
    set(gca, 'XTickLabels', {'Left SMA', 'Right SMA'});
    
    
    h7 = subplot(4, 2, 7);
    curr_data = squeeze( current_group_data(:, 1, 1, :) );
    boxplot(curr_data(:, [4 8]));
    title('RT Grasp')
    set(gca, 'XTickLabels', {'Left PPC', 'Right PPC'});
    
    
    h8 = subplot(4, 2, 8);
    curr_data = squeeze( current_group_data(:, 2, 1, :) );
    boxplot(curr_data(:, [4 8]));
    title('LT Grasp')
    set(gca, 'XTickLabels', {'Left PPC', 'Right PPC'});
    
    linkaxes([h1, h2, h3, h4, h5, h6, h7, h8], 'y');
    ylim([0 25])
    
    suplabel(group_names{group_idx}, 't');
    suplabel('Peak T Value', 'y');
    
end% group loop


%% Hand-dominance reorganization
% 2015-10-05 update



if dominance_flag == 1
    
    display('*** REORGANIZING STATISTICS ***');
    
    num_to_swap = length(ROI_list)/2;
    
    swapped_idx = zeros(1, num_subjects);
    
    % AB loop
    for s=1:length(subject_list)
        
        
        if strcmp(handedness(s), 'LT')
            
            swapped_idx(s) = 1;
            
            % shuffles Left ROI data into "dominant" (first 4) positions
            dominance_peak_vals(1:num_to_swap, s, :) =            ROI_peak_vals((num_to_swap+1):length(ROI_list), s, :);
            dominance_peak_locs(1:num_to_swap, s, :) =            ROI_peak_locs((num_to_swap+1):length(ROI_list), s, :);
            dominance_active_count(1:num_to_swap, s, :) =         ROI_active_count((num_to_swap+1):length(ROI_list), s, :);
            dominance_active_vals(1:num_to_swap, s, :) =          ROI_active_vals((num_to_swap+1):length(ROI_list), s, :);
            dominance_active_locs(1:num_to_swap, s, :) =          ROI_active_locs((num_to_swap+1):length(ROI_list), s, :);
            dominance_sig_count(1:num_to_swap, s, :) =            ROI_sig_count((num_to_swap+1):length(ROI_list), s, :);
            dominance_sig_locs(1:num_to_swap, s, :) =             ROI_sig_locs((num_to_swap+1):length(ROI_list), s, :);
            
            dominance_peak_vals((num_to_swap+1):length(ROI_list), s, :) =            ROI_peak_vals(1:num_to_swap, s, :);
            dominance_peak_locs((num_to_swap+1):length(ROI_list), s, :) =            ROI_peak_locs(1:num_to_swap, s, :);
            dominance_active_count((num_to_swap+1):length(ROI_list), s, :) =         ROI_active_count(1:num_to_swap, s, :);
            dominance_active_vals((num_to_swap+1):length(ROI_list), s, :) =          ROI_active_vals(1:num_to_swap, s, :);
            dominance_active_locs((num_to_swap+1):length(ROI_list), s, :) =          ROI_active_locs(1:num_to_swap, s, :);
            dominance_sig_count((num_to_swap+1):length(ROI_list), s, :) =            ROI_sig_count(1:num_to_swap, s, :);
            dominance_sig_locs((num_to_swap+1):length(ROI_list), s, :) =             ROI_sig_locs(1:num_to_swap, s, :);
            
            % replaces ROI variables with shuffled "dominant" organization, so I don't have to replace all following vars
            ROI_peak_vals(:, s, :) =            dominance_peak_vals(:, s, :);
            ROI_peak_locs(:, s, :) =            dominance_peak_locs(:, s, :);
            ROI_active_count(:, s, :) =         dominance_active_count(:, s, :);
            ROI_active_vals(:, s, :) =          dominance_active_vals(:, s, :);
            ROI_active_locs(:, s, :) =          dominance_active_locs(:, s, :);
            ROI_sig_count(:, s, :) =            dominance_sig_count(:, s, :);
            ROI_sig_locs(:, s, :) =             dominance_sig_locs(:, s, :);
        end
        
    end
    

    
end



%% put dominant grasp in task-1 slot

clearvars right_handed_data left_handed_data right_subjects left_subjects

right_subjects = 0;
left_subjects = 0;

for subject_idx = 1 : num_subjects
        
        if strcmp(handedness{subject_idx}, 'RT')
            
            right_subjects = right_subjects + 1;
            
            right_handed_data(right_subjects, 1, 1, :) = ROI_peak_vals(:, subject_idx, 1);
            right_handed_data(right_subjects, 1, 2, :) = ROI_sig_count(:, subject_idx, 1);
            
            right_handed_data(right_subjects, 2, 1, :) = ROI_peak_vals(:, subject_idx, 2);
            right_handed_data(right_subjects, 2, 2, :) = ROI_sig_count(:, subject_idx, 2);
        else
            
            left_subjects = left_subjects + 1;
            left_handed_data(left_subjects, 2, 1, :) = ROI_peak_vals(:, subject_idx, 1);
            left_handed_data(left_subjects, 2, 2, :) = ROI_sig_count(:, subject_idx, 1);
            
            left_handed_data(left_subjects, 1, 1, :) = ROI_peak_vals(:, subject_idx, 2);
            left_handed_data(left_subjects, 1, 2, :) = ROI_sig_count(:, subject_idx, 2);
            
        end
end


group_data{1} = right_handed_data;
group_data{2} = left_handed_data;

group_names{1} = 'Right Dominant';
group_names{2} = 'Left Dominant';



%% 

task_names = {'Dominant hand', 'Nondominant hand'};

ROI_to_plot = [1 5 2 6 3 7 4 8];
    plaintext_ROIs =    {'Dom M1', 'Non-dom M1', 'Dom S1', 'Non-dom S1',...
        'Dom SMA', 'Non-dom SMA', 'Dom PPC', 'Non-dom PPC'};
% ROI_to_plot(2, :) = [5 1 6 2];

num_plot_ROI = length(ROI_to_plot);

paired_data = {};

for task_idx = 1 : 2% dominant, nondominant
    
    cluster_idx = 0;
    
    for ROI_idx = 1 : num_plot_ROI
        
        
        for group_idx = 1 : 2
            
            curr_ROI = ROI_to_plot(ROI_idx);

            cluster_idx = cluster_idx + 1;
            
            paired_data{cluster_idx} = group_data{group_idx}(:, task_idx, 1, curr_ROI);
            
            
        end
        
        cluster_idx = cluster_idx + 1;
        
        
    end
    
    pairs1 = 1:3:cluster_idx;
    pairs2 = 2:3:cluster_idx;
    pairs_to_compare = sort([pairs1 pairs2], 'ascend');
    
    for pair_idx = 1 : num_plot_ROI
        
        sig_test(pair_idx) = ranksum( paired_data{pairs1(pair_idx)}, paired_data{pairs2(pair_idx)} );
        
        plot_pairs{pair_idx} = [pairs1(pair_idx) pairs2(pair_idx)];
        
    end
    
    Plot_Bars( {}, paired_data, 'Color', [[0.5 0.5 0.5]; [1 0 0]] )
    label_ticks = 1.5:3:cluster_idx;
    set(gca, 'XTick', label_ticks);
    set(gca, 'XTickLabel', plaintext_ROIs);
    ylabel('Peak T Value')
    title(task_names{task_idx});
    legend('Right-handed', 'Left-handed')
    
    x = refline(0, 3);
    set(x, 'LineStyle', '--')
    set(x, 'Color', 'b')
    
    sigstar(plot_pairs, sig_test)
    
    limits(task_idx, :) =  get(gca, 'YLim');
    max_lim =       max(limits(:, 2));
    if max_lim > max(limits(task_idx, :))
        set(gca, 'YLim', [0 max_lim])
    end
    
    y = line([12 12], [0 max_lim]);
    
    set(gcf, 'OuterPosition', [480 213 1142 778])% [left bottom width height]
    
    
    
end


















