% 2015-10-26 Dylan Royston
%
% Rewritten from Analyze_ROI_stats.m to be dedicated Covert Mapping Analysis
%
%
%
%
%
% === UPDATES ===
% 2016-02-18 Royston: Implemented multi-subject mean analysis (reorganized plotting section)
% 2016-07-05 Royston: started addition of across-enrichment scatter/line plot
% 2016-07-06 Royston: added preprocessed data load/save protocol
% 2017-03-15 Royston: added %change-from-simple to per-subject figures (which were added previously)
% 2017-03-28 Royston: added per-subject %change plots for data quality check
%
%
%
% === TO DO ===
% Figures:
%   - Add save functionality, change figure titles to conditions so they save correctly
%   - Group overt condition with relevant covert bars
%   - Add L/R vertical refline
% Data:
%   - Implement voxel count plots
%   - Significance checks for enrichment conditions
%
%   - Rebuild 'mean' data loading so it pulls from individual preprocessed data rather than manually processing
%   - Decide how to structure code to deal with partial data sets
%   - Structure preprocessed data so all ROIs are extracted and can be loaded separately
%

%% 1. Set up variables for processing
clear;
clc;

display('*** INITIALIZING VARIABLES ***');

% flags
figure_flag =           1;% 0 = don't save, 1 = save
ROI_path_flag =         0;% 0 = standardized, 1 = custom
% analysis_method =       'mean';% can be 'indiv' for individual subjects, or 'mean' for across-subject analysis
analysis_method =       'indiv';% can be 'indiv' for individual subjects, or 'mean' for across-subject analysis
reprocess_data =        0;


% plot flags
bar_plots =         0;
scatter_plots =     1;
stat_to_plot =      'peak';
% stat_to_plot =      'vol';


% file path to subject folders
if isunix
    %     study_path =        '/home/dar147/Desktop/test_data/[subject_id]/NIFTI/[current_paradigm]';
    study_path =        '/home/dar147/data/rnel-fs-1/data_generated/human/covert_mapping/SUBJECT_DATA_STORAGE/[subject_id]/NIFTI/[current_paradigm]';
else
    study_path =        'R:\data_generated\human\covert_mapping\SUBJECT_DATA_STORAGE\[subject_id]\NIFTI\[current_paradigm]';
end
% study_path =        'R:\data_generated\human\covert_mapping\SUBJECT DATA STORAGE\[subject_id]\FunctionalData\[current_paradigm]';

% study_path =        'C:\Users\hrnel\Documents\MATLAB\fMRI Analysis\fMRI Analysis Storage\Renamed Folders\[subject_id]\NIFTI\[current_paradigm]\';

% list of subjects to process
% subject_list =          {'CMC01', 'CMC03', 'CMC04', 'CMC05', 'CMC07', 'CMC10', 'CMC11', 'CMC12', 'CMC13', 'CMC14', 'CMC15', 'CMC17',...
%                         'CMC18', 'CMC19', 'CMC22', 'CMC23', 'CMC24', 'CMC25', 'CMC26', 'CMC27',...
%                         'CMS01', 'CMS02', 'CMS03', 'CMS04', 'CMS07', 'CMS13'};
subject_list =          {'CMC01', 'CMC03', 'CMC04', 'CMC05', 'CMC07', 'CMC10', 'CMC12', 'CMC13', 'CMC14',...
                        'CMC18', 'CMC23', 'CMC24', 'CMC25', 'CMC26', 'CMC27',...
                        'CMS01', 'CMS02', 'CMS03', 'CMS04', 'CMS06', 'CMS07', 'CMS13'};




% subject_list =          {'CMC01', 'CMC03', 'CMC05', 'CMC07', 'CMC10', 'CMC12', 'CMC13', 'CMC14', 'CMC17'};

% subject_list =          {'CMC10', 'CMC11', 'CMC12', 'CMC13', 'CMC14', 'CMC15', 'CMC17'};
% subject_list =          {'CMS01', 'CMS02', 'CMS03'};
% subject_list =          {'CMC03'};
% subject_list =          {'CMC03', 'CMC17'};


% subject_list =          {'NC01', 'NC02', 'NC03', 'NC04', 'NC05', 'NC06', 'NC07', 'NC08', 'NC09', 'NC10', 'NC11', 'NC12', 'NC13', 'NC14'};

num_subjects =          length(subject_list);

% paradigms = {'Motor_covert_fingers'};
% plaintext_paradigms = {'Motor Covert Fingers'};


% list of conditions to process
% paradigms = {'Motor_covert_fingers', 'Motor_covert_hand', 'Motor_covert_wrist', 'Motor_overt',...
%     'Sensory_covert_fingers', 'Sensory_covert_wrist'};

paradigms = {'Motor_overt'};

num_paradigms = length(paradigms);
%
% plaintext_paradigms = {'Motor Covert Fingers', 'Motor Covert Hand', 'Motor Covert Wrist', 'Motor Overt',...
%     'Sensory Covert Fingers', 'Sensory Covert Wrist'};
% plaintext_paradigms = {'Sensory Overt Fingers'};
%


% ALL
% paradigms = {'Motor_covert_fingers', 'Motor_covert_hand', 'Motor_covert_wrist', 'Motor_overt',...
%     'Sensory_covert_fingers', 'Sensory_covert_wrist',...
%     'Sensory_overt_fingers', 'Sensory_overt_hand', 'Sensory_overt_wrist'};

% plaintext_paradigms = {'Motor Covert Fingers', 'Motor Covert Hand', 'Motor Covert Wrist', 'Motor Overt',...
%     'Sensory Covert Fingers', 'Sensory Covert Wrist',...
%     'Sensory Overt Fingers', 'Sensory Overt Hand', 'Sensory Overt W% 
% for cond_idx = 1 : 5
%     
%     
%     current_
% 
%     
%     
%     
%     
%     
% end


% paradigms = {'Motor_covert_hand', 'Motor_covert_wrist', 'Motor_overt','Sensory_covert_wrist'};

% plaintext_paradigms = {'Motor Covert Hand', 'Motor Covert Wrist', 'Motor Overt','Sensory Covert Wrist'};

% establishes custom class/structure for subject/condition/ROI data structure
ROI_stats =             ROI_stats_class;

% Sets which ROIs to be analyzed (calibrated for MNI regions
% Individual data can be analyzed similarly but may require inverse-normalization transformation matrix
% ROI_list =              {'MNI_Precentral_L_ROI', 'MNI_Postcentral_L_ROI', 'MNI_Supp_Motor_Area_L_ROI', 'MNI_Parietal_Combined_L', ...
%     'MNI_Precentral_R', 'MNI_Postcentral_R', 'MNI_Supp_Motor_Area_R', 'MNI_Parietal_Combined_R'};
% ROI_list = {'MNI_Precentral_L_ROI', 'MNI_Postcentral_L_ROI'};

% ROI_list = {'masked_hand_knob_10mm_resave', 'm1_midline_resave'};
ROI_list = {'all_m1_dilated'};


% plaintext_ROIs =        {'L Precentral', 'L Postcentral', 'L SMA', 'L PPC', 'R Precentral', 'R Postcentral', 'R SMA', 'R PPC'};
% plaintext_ROIs =        {'Motor cortex', 'Somatosensory cortex'};
% plaintext_ROIs =            {'Hand knob', 'Midline'};
plaintext_ROIs =            {'Motor cortex'};

num_ROI =               length(ROI_list);

if isunix
    ROI_path =              '/home/dar147/data/rnel-fs-1/data_generated/human/covert_mapping/CM_Analysis_Tools/ROI/marsbar-aal-0.2_NIFTIS/';
    ROI_path =              '/home/dar147/data/rnel-fs-1/data_generated/human/covert_mapping/CM_Analysis_Tools/ROI/Custom ROIs/';
else
%     ROI_path =              'R:\data_generated\human\covert_mapping\CM_Analysis_Tools\ROI\marsbar-aal-0.2_NIFTIS\';
        ROI_path =              'R:\data_generated\human\covert_mapping\CM_Analysis_Tools\ROI\Custom ROIs\';
end

% ======================================== Stat extraction =================================================


% % 2016-07-06 Royston: implementing data-saving and loading protocol
if isunix
    save_path =         '/home/dar147/data/rnel-fs-1/data_generated/human/covert_mapping/SUBJECT_DATA_STORAGE/PROCESSED_DATA/';
else
    save_path =         'R:\data_generated\human\covert_mapping\SUBJECT_DATA_STORAGE\PROCESSED_DATA\';
end


% sets up inputs for organization function
metadata_struct.subject_list =         subject_list;
metadata_struct.paradigms =            paradigms;
metadata_struct.ROI_list =             ROI_list;
metadata_struct.ROI_path =             ROI_path;
metadata_struct.study_path =           study_path;
metadata_struct.subj_thresh =          [5.0393 4.8459 4.6165 4.8746 5.0260 4.9083 ...
                                        5.1143 4.7825 4.8378 4.8417 4.9849 4.8168 5.0126 4.9026 4.9161...
                                        5.0704 4.9617 5.0661 4.8525 4.8611 4.9508 4.7406];
loaded_data =       Load_Preproc_fMRI_Data(metadata_struct, save_path);

if ~exist('reprocess_data', 'var')
    reprocess_data =    loaded_data.reprocess_data;
end

if reprocess_data == 1
    
    display('*** EXTRACTING STATS FROM CONTRAST FILES ***')
    
    % extracts and organizes data from spmT contrast files
    data_struct =     organize_extracted_fmri_covert_mapping_stats(metadata_struct);
        Save_Preproc_fMRI_Data(data_struct, metadata_struct, save_path, reprocess_data);
    
else
    data_struct =       loaded_data.data_struct;
end

% hard-coded transformations, not needed for anything
% x_transform =                       output_struct.x_transform;
% y_transform =                       output_struct.y_transform;
% z_transform =                       output_struct.z_transform;

% organizes function outputs, indexed by ROI/subject/paradigm/condition
master_list =                    data_struct.master_list;
ROI_peak_vals =                  data_struct.ROI_peak_vals;
ROI_peak_locs =                  data_struct.ROI_peak_locs;
ROI_active_count =               data_struct.ROI_active_count;
ROI_active_vals =                data_struct.ROI_active_vals;
ROI_active_locs =                data_struct.ROI_active_locs;
ROI_sig_count =                  data_struct.ROI_sig_count;
ROI_sig_vals =                   data_struct.ROI_sig_vals;
ROI_sig_locs =                   data_struct.ROI_sig_locs;
paradigm_design =                data_struct.paradigm_design;




%% nested boxplot with SCI points
% debugging version

tasks_to_plot =         [1 2 3 4 5];

cond_labels =           {'Lips', 'Wrist', 'Hand', 'Fingers', 'Ankle'};
cond_labels_to_use =    cond_labels(tasks_to_plot);
num_conditions =        length(cond_labels_to_use);

variable_of_interest =  ROI_peak_vals;
data_dimensions =       size(variable_of_interest);
num_AB =                length(FUNC_find_string_in_cell(subject_list, 'CMC') );
num_SCI =               num_subjects - num_AB;

for subj_idx = 1 : num_SCI
    sci_labels{subj_idx} =            subject_list{15+subj_idx}([4 5]);
end

figure;
for roi_idx = 1 : num_ROI
    
    subplot(num_ROI, 1, roi_idx);
    % AB plot
    hold on;
    curr_colorbar =         jet(num_AB);
    all_cond_vals =         [];
    condition_vals =        squeeze( variable_of_interest(roi_idx, 1:num_AB, :, tasks_to_plot) );
    all_cond_vals =         condition_vals(:);
    
    group =                 [];
    for cond_idx = 1 : num_conditions
        current_group =         cond_idx * ones (1, num_AB);
        group =                 [group current_group];
    end
    
    boxplot(all_cond_vals, group);
    
    
    % SCI plot
    num_SCI =               num_subjects - num_AB;
    all_cond_vals =         [];
    condition_vals =        squeeze( variable_of_interest(roi_idx, num_AB+1:num_subjects, :, tasks_to_plot) );
    all_cond_vals =         condition_vals(:);
    
    group =                 [];
    for cond_idx = 1 : num_conditions
        current_group =         cond_idx * ones (1, num_SCI);
        group =                 [group current_group];
        
%         scatter(current_group, condition_vals(:, cond_idx), 'k');
    end
    
    
    hold on;
    scatter(group, all_cond_vals, [], 'k');
%     text(group, all_cond_vals, )
    
%     scatter(group, all_cond_vals, [], 'k', 'filled');
    
    
    threshold_line =    refline(0, 5.5);
    set(threshold_line, 'Color', 'k');
    set(threshold_line, 'LineStyle', '--');
    
    ylim([0 20]);
    xlim([0.5 num_conditions+0.5]);
%     set(gca, 'XTick', [1 2 3 4 5]);
    set(gca, 'XTick', 1:num_conditions);

    set(gca, 'XTickLabel', cond_labels_to_use);
    xlabel('Task');
    ylabel('Peak T');
    title(plaintext_ROIs{roi_idx});
    set(gcf, 'Position', [1340 86 463 872]);
    
    current_axes = get(gca, 'Children');
    
    box_vars = findall(gca,'Tag','Box');
    hLegend = legend( [box_vars(1) current_axes(2)], {['AB (n=' num2str(num_AB) ')'], ['SCI (n=' num2str(num_SCI) ')']}, 'Location', 'NW');
    
    for cond_idx = 1 : num_conditions
        current_group =         cond_idx * ones (1, num_SCI);
        text(current_group, condition_vals(:, cond_idx), sci_labels, 'Position', [1 0], 'FontWeight', 'bold');
        text(current_group(5), condition_vals(5, cond_idx), sci_labels(5), 'FontWeight', 'bold', 'Color', 'r');

    end
    
%     legend('SCI subjects');
    suplabel('Activation Strength', 't');
    
end% roi_idx

% nested boxplot with SCI points

cond_labels =           {'Lips', 'Wrist', 'Hand', 'Fingers', 'Ankle'};
variable_of_interest =  ROI_sig_count;
data_dimensions =       size(variable_of_interest);

figure;
for roi_idx = 1 : num_ROI
    
    subplot(num_ROI, 1, roi_idx);
    % AB plot
    hold on;
%     num_AB =                12;
    curr_colorbar =         jet(num_AB);
    all_cond_vals =         [];
    condition_vals =        squeeze( variable_of_interest(roi_idx, 1:num_AB, :, tasks_to_plot) ) * 100;
    all_cond_vals =         condition_vals(:);
    
    group =                 [];
    for cond_idx = 1 : num_conditions
        current_group =         cond_idx * ones (1, num_AB);
        group =                 [group current_group];
    end
    
    boxplot(all_cond_vals, group);
    
    
    % SCI plot
    all_cond_vals =         [];
    condition_vals =        squeeze( variable_of_interest(roi_idx, num_AB+1:num_subjects, :, tasks_to_plot) ) * 100;
    all_cond_vals =         condition_vals(:);
    
    group =                 [];
    for cond_idx = 1 : num_conditions
        current_group =         cond_idx * ones (1, num_SCI);
        group =                 [group current_group];
    end
    
    hold on;
    scatter(group, all_cond_vals, [], 'k');
%     scatter(group, all_cond_vals, [], 'k', 'filled');
    
%     ylim([0 100]);
    xlim([0.5 num_conditions+0.5]);
%     set(gca, 'XTick', [1 2 3 4 5]);
    set(gca, 'XTick', 1:num_conditions);

    set(gca, 'XTickLabel', cond_labels_to_use);
    xlabel('Task');
    ylabel('% ROI sig');
    title(plaintext_ROIs{roi_idx});
    set(gcf, 'Position', [1340 86 463 872]);

    current_axes = get(gca, 'Children');
    
    box_vars = findall(gca,'Tag','Box');
    hLegend = legend( [box_vars(1) current_axes(1)], {['AB (n=' num2str(num_AB) ')'], ['SCI (n=' num2str(num_SCI) ')']}, 'Location', 'NW');
    suplabel('Activation Volume', 't');
    
    for cond_idx = 1 : num_conditions
        current_group =         cond_idx * ones (1, num_SCI);
        text(current_group, condition_vals(:, cond_idx), sci_labels, 'FontWeight', 'bold');
        text(current_group(5), condition_vals(5, cond_idx), sci_labels(5), 'FontWeight', 'bold', 'Color', 'r');
    end
    
end% roi_idx



%% nested boxplot with SCI points
% publication version

tasks_to_plot =         [2 3 5];

cond_labels =           {'Lips', 'Wrist', 'Hand', 'Fingers', 'Ankle'};
cond_labels_to_use =    cond_labels(tasks_to_plot);
num_conditions =        length(cond_labels_to_use);

variable_of_interest =  ROI_peak_vals;
data_dimensions =       size(variable_of_interest);
num_AB =                length(FUNC_find_string_in_cell(subject_list, 'CMC') );
num_SCI =               num_subjects - num_AB;

for subj_idx = 1 : num_SCI
    sci_labels{subj_idx} =            subject_list{15+subj_idx}([4 5]);
end

figure;
for roi_idx = 1 : num_ROI
    
%     subplot(num_ROI, 1, roi_idx);
    % AB plot
    hold on;
    curr_colorbar =         jet(num_AB);
    all_cond_vals =         [];
    condition_vals =        squeeze( variable_of_interest(roi_idx, 1:num_AB, :, tasks_to_plot) );
    all_cond_vals =         condition_vals(:);
    
    group =                 [];
    for cond_idx = 1 : num_conditions
        current_group =         cond_idx * ones (1, num_AB);
        group =                 [group current_group];
    end
    
    boxplot(all_cond_vals, group);
    
    
    % SCI plot
    num_SCI =               num_subjects - num_AB;
    all_cond_vals =         [];
    condition_vals =        squeeze( variable_of_interest(roi_idx, num_AB+1:num_subjects, :, tasks_to_plot) );
    all_cond_vals =         condition_vals(:);
    
    group =                 [];
    for cond_idx = 1 : num_conditions
        current_group =         cond_idx * ones (1, num_SCI);
        group =                 [group current_group];
        
%         scatter(current_group, condition_vals(:, cond_idx), 'k');
    end
    
    
    hold on;
%     scatter(group, all_cond_vals, [], 'k');
%     text(group, all_cond_vals, )
    
    scatter(group, all_cond_vals, [], 'k', 'filled');
    
    
    threshold_line =    refline(0, 5.5);
    set(threshold_line, 'Color', 'k');
    set(threshold_line, 'LineStyle', '--');
    
    ylim([0 20]);
    xlim([0.5 num_conditions+0.5]);
%     set(gca, 'XTick', [1 2 3 4 5]);
    set(gca, 'XTick', 1:num_conditions);

    set(gca, 'XTickLabel', cond_labels_to_use);
    xlabel('Task');
    ylabel('Peak T');
    title(plaintext_ROIs{roi_idx});
    set(gcf, 'Position', [2282 410 558 500]);
    
    current_axes = get(gca, 'Children');
    
    box_vars = findall(gca,'Tag','Box');
    hLegend = legend( [box_vars(1) current_axes(2)], {['AB (n=' num2str(num_AB) ')'], ['SCI (n=' num2str(num_SCI) ')']}, 'Location', 'NW');
    
%     for cond_idx = 1 : num_conditions
%         current_group =         cond_idx * ones (1, num_SCI);
%         text(current_group, condition_vals(:, cond_idx), sci_labels, 'Position', [1 0], 'FontWeight', 'bold');
%         text(current_group(5), condition_vals(5, cond_idx), sci_labels(5), 'FontWeight', 'bold', 'Color', 'r');
% 
%     end
    
%     legend('SCI subjects');
%     suplabel('Activation Strength', 't');
    
end% roi_idx

sci_median = median(condition_vals);
for cond_idx = 1 : num_conditions
    line([cond_idx-0.2 cond_idx+0.2], [sci_median(cond_idx) sci_median(cond_idx)], 'Color', 'g');
end

title('Activation Strength');

% nested boxplot with SCI points


cond_labels =           {'Lips', 'Wrist', 'Hand', 'Fingers', 'Ankle'};
variable_of_interest =  ROI_sig_count;
data_dimensions =       size(variable_of_interest);



figure;
for roi_idx = 1 : num_ROI
    
%     subplot(num_ROI, 1, roi_idx);
    % AB plot
    hold on;
%     num_AB =                12;
    curr_colorbar =         jet(num_AB);
    all_cond_vals =         [];
    condition_vals =        squeeze( variable_of_interest(roi_idx, 1:num_AB, :, tasks_to_plot) ) * 100;
    all_cond_vals =         condition_vals(:);
    
    group =                 [];
    for cond_idx = 1 : num_conditions
        current_group =         cond_idx * ones (1, num_AB);
        group =                 [group current_group];
    end
    
    boxplot(all_cond_vals, group);
    
    
    % SCI plot
    all_cond_vals =         [];
    condition_vals =        squeeze( variable_of_interest(roi_idx, num_AB+1:num_subjects, :, tasks_to_plot) ) * 100;
    all_cond_vals =         condition_vals(:);
    
    group =                 [];
    for cond_idx = 1 : num_conditions
        current_group =         cond_idx * ones (1, num_SCI);
        group =                 [group current_group];
    end
    
    hold on;
%     scatter(group, all_cond_vals, [], 'k');
    scatter(group, all_cond_vals, [], 'k', 'filled');
    
%     ylim([0 100]);
    xlim([0.5 num_conditions+0.5]);
%     set(gca, 'XTick', [1 2 3 4 5]);
    set(gca, 'XTick', 1:num_conditions);

    set(gca, 'XTickLabel', cond_labels_to_use);
    xlabel('Task');
    ylabel('% ROI sig');
    title(plaintext_ROIs{roi_idx});
    set(gcf, 'Position', [2856 410 558 500]);

    current_axes = get(gca, 'Children');
    
    box_vars = findall(gca,'Tag','Box');
    hLegend = legend( [box_vars(1) current_axes(1)], {['AB (n=' num2str(num_AB) ')'], ['SCI (n=' num2str(num_SCI) ')']}, 'Location', 'NW');
%     suplabel('Activation Volume', 't');
    
%     for cond_idx = 1 : num_conditions
%         current_group =         cond_idx * ones (1, num_SCI);
%         text(current_group, condition_vals(:, cond_idx), sci_labels, 'FontWeight', 'bold');
%         text(current_group(5), condition_vals(5, cond_idx), sci_labels(5), 'FontWeight', 'bold', 'Color', 'r');
%     end
    title('Activation Volume');

end% roi_idx
sci_median = median(condition_vals);
for cond_idx = 1 : num_conditions
    line([cond_idx-0.2 cond_idx+0.2], [sci_median(cond_idx) sci_median(cond_idx)], 'Color', 'g');
end

%% side by side scatters

tasks_to_plot =         [1 2 3 4 5];

cond_labels =           {'Lips', 'Wrist', 'Hand', 'Fingers', 'Ankle'};
cond_labels_to_use =    cond_labels(tasks_to_plot);
num_conditions =        length(cond_labels_to_use);

variable_of_interest =  ROI_peak_vals;
data_dimensions =       size(variable_of_interest);
num_AB =                length(FUNC_find_string_in_cell(subject_list, 'CMC') );
num_SCI =               num_subjects - num_AB;

for subj_idx = 1 : num_SCI
    sci_labels{subj_idx} =            subject_list{15+subj_idx}([4 5]);
end

for subj_idx = 1 : num_AB
    ab_labels{subj_idx} =               subject_list{subj_idx}([4 5]);
end

figure;
for roi_idx = 1 : num_ROI
    
%     subplot(num_ROI, 1, roi_idx);
    % AB plot
    hold on;
    curr_colorbar =         jet(num_AB);
    all_cond_vals =         [];
    condition_vals =        squeeze( variable_of_interest(roi_idx, 1:num_AB, :, tasks_to_plot) );
    all_cond_vals =         condition_vals(:);
    
    group =                 [];
    for cond_idx = 1 : num_conditions
        current_group =         cond_idx * ones (1, num_AB);
        group =                 [group current_group];
        text(current_group-0.2, condition_vals(:, cond_idx), ab_labels, 'FontWeight', 'bold', 'Color', 'k');
    end
    
    scatter( group-0.2, all_cond_vals, [], 'k');

    ab_median = median(condition_vals);
    for cond_idx = 1 : num_conditions
        line([cond_idx-0.25 cond_idx-0.15], [ab_median(cond_idx) ab_median(cond_idx)], 'Color', 'c', 'LineWidth', 3);
    end
%     boxplot(all_cond_vals, group);
    
    
    % SCI plot
    num_SCI =               num_subjects - num_AB;
    all_cond_vals =         [];
    condition_vals =        squeeze( variable_of_interest(roi_idx, num_AB+1:num_subjects, :, tasks_to_plot) );
    all_cond_vals =         condition_vals(:);
    
    group =                 [];
    for cond_idx = 1 : num_conditions
        current_group =         cond_idx * ones (1, num_SCI);
        group =                 [group current_group];
                text(current_group+0.2, condition_vals(:, cond_idx), sci_labels, 'FontWeight', 'bold', 'Color', 'k');
%         scatter(current_group, condition_vals(:, cond_idx), 'k');
    end
    
    
    hold on;
%     scatter(group, all_cond_vals, [], 'k');
%     text(group, all_cond_vals, )
    
    scatter(group+0.2, all_cond_vals, [], 'r', 'filled');
    sci_median = median(condition_vals);
    for cond_idx = 1 : num_conditions
        line([cond_idx+0.15 cond_idx+0.25], [sci_median(cond_idx) sci_median(cond_idx)], 'Color', 'b', 'LineWidth', 3);
    end
    
    threshold_line =    refline(0, 5.5);
    set(threshold_line, 'Color', 'k');
    set(threshold_line, 'LineStyle', '--');
    
    ylim([0 20]);
    xlim([0.5 num_conditions+0.5]);
%     set(gca, 'XTick', [1 2 3 4 5]);
    set(gca, 'XTick', 1:num_conditions);

    set(gca, 'XTickLabel', cond_labels_to_use);
    xlabel('Task');
    ylabel('Peak T');
    title(plaintext_ROIs{roi_idx});
    set(gcf, 'Position', [1340 86 463 872]);
    
    current_axes = get(gca, 'Children');
    
    box_vars = findall(gca,'Tag','Box');
%     hLegend = legend( [box_vars(1) current_axes(2)], {['AB (n=' num2str(num_AB) ')'], ['SCI (n=' num2str(num_SCI) ')']}, 'Location', 'NW');
    
%     for cond_idx = 1 : num_conditions
%         current_group =         cond_idx * ones (1, num_SCI);
%         text(current_group, condition_vals(:, cond_idx), sci_labels, 'Position', [1 0], 'FontWeight', 'bold');
%         text(current_group(5), condition_vals(5, cond_idx), sci_labels(5), 'FontWeight', 'bold', 'Color', 'r');
% 
%     end
    
%     legend('SCI subjects');
%     suplabel('Activation Strength', 't');
    
end% roi_idx

% nested boxplot with SCI points

cond_labels =           {'Lips', 'Wrist', 'Hand', 'Fingers', 'Ankle'};
variable_of_interest =  ROI_sig_count;
data_dimensions =       size(variable_of_interest);

for cond_idx = 1 : num_conditions-1
    line([cond_idx+0.5 cond_idx+0.5], [0 20], 'Color', 'k');
end




variable_of_interest =  ROI_sig_count;
data_dimensions =       size(variable_of_interest);
num_AB =                length(FUNC_find_string_in_cell(subject_list, 'CMC') );
num_SCI =               num_subjects - num_AB;


figure;
for roi_idx = 1 : num_ROI
    
%     subplot(num_ROI, 1, roi_idx);
    % AB plot
    hold on;
    curr_colorbar =         jet(num_AB);
    all_cond_vals =         [];
    condition_vals =        squeeze( variable_of_interest(roi_idx, 1:num_AB, :, tasks_to_plot) );
    all_cond_vals =         condition_vals(:);
    
    group =                 [];
    for cond_idx = 1 : num_conditions
        current_group =         cond_idx * ones (1, num_AB);
        group =                 [group current_group];
        text(current_group-0.2, condition_vals(:, cond_idx), ab_labels, 'FontWeight', 'bold', 'Color', 'k');
    end
    
    scatter( group-0.2, all_cond_vals, [], 'k');

    ab_median = median(condition_vals);
    for cond_idx = 1 : num_conditions
        line([cond_idx-0.25 cond_idx-0.15], [ab_median(cond_idx) ab_median(cond_idx)], 'Color', 'c', 'LineWidth', 3);
    end
%     boxplot(all_cond_vals, group);
    
    
    % SCI plot
    num_SCI =               num_subjects - num_AB;
    all_cond_vals =         [];
    condition_vals =        squeeze( variable_of_interest(roi_idx, num_AB+1:num_subjects, :, tasks_to_plot) );
    all_cond_vals =         condition_vals(:);
    
    group =                 [];
    for cond_idx = 1 : num_conditions
        current_group =         cond_idx * ones (1, num_SCI);
        group =                 [group current_group];
                text(current_group+0.2, condition_vals(:, cond_idx), sci_labels, 'FontWeight', 'bold', 'Color', 'k');
%         scatter(current_group, condition_vals(:, cond_idx), 'k');
    end
    
    
    hold on;
%     scatter(group, all_cond_vals, [], 'k');
%     text(group, all_cond_vals, )
    
    scatter(group+0.2, all_cond_vals, [], 'r', 'filled');
    sci_median = median(condition_vals);
    for cond_idx = 1 : num_conditions
        line([cond_idx+0.15 cond_idx+0.25], [sci_median(cond_idx) sci_median(cond_idx)], 'Color', 'b', 'LineWidth', 3);
    end
    
    threshold_line =    refline(0, 5.5);
    set(threshold_line, 'Color', 'k');
    set(threshold_line, 'LineStyle', '--');
    
    ylim([0 0.5]);
    xlim([0.5 num_conditions+0.5]);
%     set(gca, 'XTick', [1 2 3 4 5]);
    set(gca, 'XTick', 1:num_conditions);

    set(gca, 'XTickLabel', cond_labels_to_use);
    xlabel('Task');
    ylabel('%ROI sig');
    title(plaintext_ROIs{roi_idx});
    set(gcf, 'Position', [1340 86 463 872]);
    
    current_axes = get(gca, 'Children');
    
    box_vars = findall(gca,'Tag','Box');
%     hLegend = legend( [box_vars(1) current_axes(2)], {['AB (n=' num2str(num_AB) ')'], ['SCI (n=' num2str(num_SCI) ')']}, 'Location', 'NW');
    
%     for cond_idx = 1 : num_conditions
%         current_group =         cond_idx * ones (1, num_SCI);
%         text(current_group, condition_vals(:, cond_idx), sci_labels, 'Position', [1 0], 'FontWeight', 'bold');
%         text(current_group(5), condition_vals(5, cond_idx), sci_labels(5), 'FontWeight', 'bold', 'Color', 'r');
% 
%     end
    
%     legend('SCI subjects');
%     suplabel('Activation Strength', 't');
    
end% roi_idx

% nested boxplot with SCI points

cond_labels =           {'Lips', 'Wrist', 'Hand', 'Fingers', 'Ankle'};
variable_of_interest =  ROI_sig_count;
data_dimensions =       size(variable_of_interest);

for cond_idx = 1 : num_conditions-1
    line([cond_idx+0.5 cond_idx+0.5], [0 1], 'Color', 'k');
end



%% boxplots with points
% 
% cond_labels =   {'Lips', 'Wrist', 'Hand', 'Fingers', 'Ankle'};
% data_dimensions =       size(ROI_sig_vals);
% 
% 
% for roi_idx = 1 : 2
%     
%     figure;
%     
%     % AB plot
%     subplot(1, 2, 1);hold on;
%     
%     num_AB =            12;
%     curr_colorbar =     jet(num_AB);
%     all_cond_vals =     [];
%     
%     condition_vals =        squeeze( ROI_peak_vals(roi_idx, 1:num_AB, :, :) );
%         
%     all_cond_vals =         condition_vals(:);
%     
%     group =                         [];
%     for cond_idx = 1 : num_conditions
%         current_group =                     cond_idx * ones (1, num_AB);
%         group =                             [group current_group];
%     end
%     
%     
%     boxplot(all_cond_vals, group);
%     hold on;
%     scatter(group, all_cond_vals, 'filled');
%     
%     threshold_line =    refline(0, 2.5);
%     set(threshold_line, 'Color', 'k');
%     set(threshold_line, 'LineStyle', '--');
%     ylim([0 20]);
%     xlim([0.5 5.5]);
%     set(gca, 'XTick', [1 2 3 4 5]);
%     set(gca, 'XTickLabel', cond_labels);
%     xlabel('Task');
%     ylabel('Peak T');
%     title('Able-bodied')
%     
%     % SCI plot
%     num_SCI =           num_subjects - num_AB;
%     curr_colorbar =     jet(num_SCI);
%     subplot(1, 2, 2);hold on    
%     
%     all_cond_vals =     [];
%     
%     condition_vals =        squeeze( ROI_peak_vals(roi_idx, num_AB+1:num_subjects, :, :) );
%         
%     all_cond_vals =         condition_vals(:);
%     
%     group =                         [];
%     for cond_idx = 1 : num_conditions
%         current_group =                     cond_idx * ones (1, num_SCI);
%         group =                             [group current_group];
%     end
%     
%     
%     boxplot(all_cond_vals, group);
%     hold on;
%     scatter(group, all_cond_vals, 'filled');
%     
%     ylim([0 20]);
%     xlim([0.5 5.5]);
%     
%     threshold_line =    refline(0, 2.5);
%     set(threshold_line, 'Color', 'k');
%     set(threshold_line, 'LineStyle', '--');
%     set(gca, 'XTick', [1 2 3 4 5]);
%     set(gca, 'XTickLabel', cond_labels);
%     xlabel('Task');
%     ylabel('Peak T');
%     title('SCI');
%     set(gcf, 'Position', [2360 251 1086 480]);
%     
%     suplabel(plaintext_ROIs{roi_idx}, 't');
%     
% end% roi_idx
% 
% 
% 
% %% line plots
% 
% cond_labels =   {'Lips', 'Wrist', 'Hand', 'Fingers', 'Ankle'};
% 
% 
% for roi_idx = 1 : 2
%     
%     figure;
%     
%     % AB plot
%     subplot(1, 2, 1);hold on;
%     curr_colorbar =     jet(12);
%     for subject_idx = 1 : 12
%         
%         current_peak =      squeeze( ROI_peak_vals(roi_idx, subject_idx, :, :) );
%                 
%         switch roi_idx
%             case 1
%                 plot(current_peak', 'LineWidth', 2, 'Color', curr_colorbar(subject_idx, :)*0.8 );
%             case 2
%                 plot(current_peak', 'LineWidth', 2, 'LineStyle', '--', 'Color', curr_colorbar(subject_idx, :)*0.8 );
%         end% switch
% 
%         
%     end% FOR subject_idx
%     
%     threshold_line =    refline(0, 2.5);
%     set(threshold_line, 'Color', 'k');
%     set(threshold_line, 'LineStyle', '--');
%     ylim([0 20]);
%     xlim([0.5 5.5]);
%     set(gca, 'XTick', [1 2 3 4 5]);
%     set(gca, 'XTickLabel', cond_labels);
%     xlabel('Task');
%     ylabel('Peak T');
%     title('Able-bodied')
%     
%     % SCI plot
%     curr_colorbar =     jet(3);
%     subplot(1, 2, 2);hold on;
%     for subject_idx = 13 : num_subjects
%        
%         current_peak =      squeeze( ROI_peak_vals(roi_idx, subject_idx, :, :) );
%         
%         switch roi_idx
%             case 1
%                 plot(current_peak', 'LineWidth', 2, 'Color', curr_colorbar(subject_idx-12, :)*0.8 );
%             case 2
%                 plot(current_peak', 'LineWidth', 2, 'LineStyle', '--', 'Color', curr_colorbar(subject_idx-12, :)*0.8 );
%         end% switch
%         
%     end
%     
%     ylim([0 20]);
%     xlim([0.5 5.5]);
%     
%     threshold_line =    refline(0, 2.5);
%     set(threshold_line, 'Color', 'k');
%     set(threshold_line, 'LineStyle', '--');
%     set(gca, 'XTick', [1 2 3 4 5]);
%     set(gca, 'XTickLabel', cond_labels);
%     xlabel('Task');
%     ylabel('Peak T');
%     title('SCI');
%     set(gcf, 'Position', [2360 251 1086 480]);
%     
%     suplabel(plaintext_ROIs{roi_idx}, 't');
%     
% end% roi_idx
% 
% %%
% 
% % cond_labels =   {'Ankle', 'Wrist', 'Hand', 'Fingers', 'Lips'};
% 
% 
% for roi_idx = 1 : 2
%     
%     
%     % AB plot
%     curr_colorbar =     jet(12);
%     
%     figure;
%     subplot(1, 2, 1); hold on;
%     
%     for subject_idx = 1 : 12
%         
%         current_peak =      squeeze( ROI_sig_count(roi_idx, subject_idx, :, :) ) * 100;
%         
%         switch roi_idx
%             case 1
%                 plot(current_peak', 'LineWidth', 2, 'Color', curr_colorbar(subject_idx, :)*0.8 );
%             case 2
%                 plot(current_peak', 'LineWidth', 2, 'LineStyle', '--', 'Color', curr_colorbar(subject_idx, :)*0.8 );
%         end% switch
%         
%     end% FOR subject_idx
%         
%     ylim([0 100]);
%     xlim([0.5 5.5]);
%     set(gca, 'XTick', [1 2 3 4 5]);
%     set(gca, 'XTickLabel', cond_labels);
%     xlabel('Task');
%     ylabel('% ROI sig');
%     title('Able-bodied');
%     
%     
%     % SCI plot
%     curr_colorbar =     jet(3);
%     subplot(1, 2, 2); hold on;
%     
%     for subject_idx = 13 : num_subjects
%         
%         % for cond_idx = 1 : 5
%         
%         
%         current_peak =      squeeze( ROI_sig_count(roi_idx, subject_idx, :, :) ) * 100;
%         
%         switch roi_idx
%             case 1
%                 plot(current_peak', 'LineWidth', 2, 'Color', curr_colorbar(subject_idx-12, :)*0.8 );
%             case 2
%                 plot(current_peak', 'LineWidth', 2, 'LineStyle', '--', 'Color', curr_colorbar(subject_idx-12, :)*0.8 );
%         end% switch
% 
%     end% FOR subject_idx
%     
%     % ylim([0 1]);
%     
%     ylim([0 100]);
%     xlim([0.5 5.5]);
%     set(gca, 'XTick', [1 2 3 4 5]);
%     set(gca, 'XTickLabel', cond_labels);
%     xlabel('Task');
%     ylabel('% ROI sig');
%     title('SCI');
%     
%     set(gcf, 'Position', [2360 251 1086 480]);
%     
%     suplabel(plaintext_ROIs{roi_idx}, 't');
% 
% end %FOR roi_idx


% %%
% ROI_choice =                    1:num_ROI;
% 
% for roi_idx = 1 : length(ROI_choice)
%     
%     figure; hold on;
%     
%     data_dimensions =       size(ROI_sig_vals);
%     num_conditions =        length(cond_labels_to_use);
%     
%     counter = 1;
%     
%     for task_idx = tasks_to_plot
%         
%         current_task_voxels =           ROI_sig_vals(roi_idx, :, :, task_idx);
%         
%         empty_subjects =                cellfun(@isempty, current_task_voxels);
%         empty_subjects =                empty_subjects == 0;
%         
%         all_empties{task_idx} =         empty_subjects;
%         
%         
%         
%         merged_voxels =                 vertcat( current_task_voxels{:} )';
%         
%         current_voxel_counts =         cell2mat( cellfun(@length,current_task_voxels,'uni',false) );
%         
%         
%         
%         group =                         [];
%         for subject_idx = 1 : num_subjects
%             
%             current_group =                     subject_idx * ones (1, current_voxel_counts(subject_idx) );
%             group =                             [group current_group];
%             
%         end
%         
%         subplot(num_conditions, 1, counter);
%         counter = counter + 1;
%         
%         boxplot(merged_voxels, group);
%         xlim([0 num_subjects+0.5]);
%         ylim([0 20]);
%         
%         threshold_line =    refline(0, 5.5);
%         set(threshold_line, 'Color', 'k');
%         set(threshold_line, 'LineStyle', '--');
%         
%         temp_idx = 1 : num_subjects;
%         blanked_subject_list = cell(1, num_subjects);
%         blanked_subject_list = subject_list(empty_subjects);
%         
% %         set(gca, 'XTick', find(empty_subjects));
%         label_idx = get(gca, 'XTick');
%         set(gca, 'XTickLabel', blanked_subject_list);
%         set(gca, 'XTickLabelRotation', 45);
%         ylabel('T stat');
%         title(cond_labels{task_idx});
%         
%         
%     end
%     
%     set(gcf, 'Position', [2103 1 1146 940]);
%     
%     suplabel(plaintext_ROIs{roi_idx}, 't');
% end


% 
% 
% 
% current_chunk = test{ 1};
% current_2 =         test{2, 1};
% 
% 
% 
% 
% group = [ ones( size(current_chunk) );
%     2*ones( size(current_2) )];
% 
% boxplot(test{1:2, 1});





%% hand/fingers overlap 
% 
% variable_nums = size(ROI_peak_vals);
% 
% num_conditions =    variable_nums(4);
% 
% switch num_conditions
%     case 5
%         
%         for subject_idx = 1 : num_subjects
%             
%             for roi_idx = 1 : num_ROI
%                 
%                 condition_voxels =          squeeze( ROI_sig_locs(roi_idx, subject_idx, :, 3:4) );
%                 total_voxels =              sum( [ length(condition_voxels{1}), length(condition_voxels{2}) ] );
%                 common_voxels =             intersect(condition_voxels{1}, condition_voxels{2}, 'rows');
%                 overlap(subject_idx, roi_idx) = (size(common_voxels, 1)/total_voxels)*100;
%                 
%             end% FOR roi_idx
%             
%             
%         end% FOR subject_idx
%         
%     case 4
%         
%         for subject_idx = 1 : num_subjects
%             
%             for roi_idx = 1 : num_ROI
%                 
%                 condition_voxels =          squeeze( ROI_sig_locs(roi_idx, subject_idx, :, 1:2) );
%                 total_voxels =              sum( [ length(condition_voxels{1}), length(condition_voxels{2}) ] );
%                 common_voxels =             intersect(condition_voxels{1}, condition_voxels{2}, 'rows');
%                 overlap(subject_idx, roi_idx) = (size(common_voxels, 1)/total_voxels)*100;
%                 
%             end% FOR roi_idx
%             
%             
%         end% FOR subject_idx
%         
%         
% end% SWITCH
% 
% overlap
% median(overlap)
% std(overlap)

% Plot_Bars(plaintext_ROIs, overlap')


%% functional testing correlation

[~, ~, raw]  = xlsread('R:\data_raw\human\covert_mapping\Demographic and Functional Data\Demographic and Functional Data 2017.11.01.xlsx', 'Muscle');

read_subj_nums = raw([3 4 5 6 8 9 15], 1);
muscle_total =  raw([3 4 5 6 8 9 15], 12);
muscle_total = cell2mat(muscle_total);

sci_peak =      squeeze( ROI_peak_vals(1, 16:end, 1, [3 5]) );

sci_vol =       squeeze( ROI_sig_count(1, 16:end, 1, [3 5]) );

figure;
subplot(2, 1, 1);
scatter(muscle_total, sci_peak(:, 1), [], 'k', 'filled');
text(muscle_total, sci_peak(:, 1), read_subj_nums);
limits = get(gca, 'XLim');
[p, S] = polyfit(muscle_total, sci_peak(:, 1), 1);
[y, delta] = polyval(p, limits(1):limits(2), S);
mdl = fitlm(muscle_total, sci_peak(:, 1) );
r2 = mdl.Rsquared;
fstat = mdl.anova.F(1);
pval = mdl.anova.pValue(1);
hold on;
plot(limits(1):limits(2), y);
title(['Hand (T) vs Muscle total (R2=' num2str(r2.Ordinary) ', F=' num2str(fstat), ',p=' num2str(pval) ')']);
xlim([limits(1)-2 limits(2)+2]);
xlabel('Total muscle score (/50)');
ylabel('Peak T (hand grasp)');
limits = get(gca, 'Ylim');
ylim([limits(1)-2 limits(2)+2]);

subplot(2, 1, 2);
scatter(muscle_total, sci_peak(:, 2), [], 'k', 'filled');
text(muscle_total, sci_peak(:, 2), read_subj_nums);
limits = get(gca, 'XLim');
[p, S] = polyfit(muscle_total, sci_peak(:, 2), 1);
[y, delta] = polyval(p, limits(1):limits(2), S);
mdl = fitlm(muscle_total, sci_peak(:, 2) );
r2 = mdl.Rsquared;
fstat = mdl.anova.F(1);
pval = mdl.anova.pValue(1);
hold on;
plot(limits(1):limits(2), y);
title(['Ankle (T) vs Muscle total (R2=' num2str(r2.Ordinary) ', F=' num2str(fstat), ',p=' num2str(pval) ')']);
xlim([limits(1)-2 limits(2)+2]);
xlabel('Total muscle score (/50)');
ylabel('Peak T (ankle flex)');
set(gcf, 'Position', [2061 303 738 613]);
limits = get(gca, 'Ylim');
ylim([limits(1)-2 limits(2)+2]);



figure;
subplot(2, 1, 1);
scatter(muscle_total, sci_vol(:, 1), [], 'k', 'filled');
text(muscle_total, sci_vol(:, 1), read_subj_nums);
limits = get(gca, 'XLim');
[p, S] = polyfit(muscle_total, sci_vol(:, 1), 1);
[y, delta] = polyval(p, limits(1):limits(2), S);
mdl = fitlm(muscle_total, sci_vol(:, 1) );
r2 = mdl.Rsquared;
fstat = mdl.anova.F(1);
pval = mdl.anova.pValue(1);
hold on;
plot(limits(1):limits(2), y);
title(['Hand (Vol) vs Muscle total (R2=' num2str(r2.Ordinary) ', F=' num2str(fstat), ',p=' num2str(pval) ')']);
xlim([limits(1)-2 limits(2)+2]);
xlabel('Total muscle score (/50)');
ylabel('Sig volume (ankle flex)');
limits = get(gca, 'Ylim');
ylim([limits(1)-0.1 limits(2)+0.1]);

subplot(2, 1, 2);
scatter(muscle_total, sci_vol(:, 2), [], 'k', 'filled');
text(muscle_total, sci_vol(:, 2), read_subj_nums);
limits = get(gca, 'XLim');
[p, S] = polyfit(muscle_total, sci_vol(:, 2), 1);
[y, delta] = polyval(p, limits(1):limits(2), S);
mdl = fitlm(muscle_total, sci_vol(:, 2) );
r2 = mdl.Rsquared;
fstat = mdl.anova.F(1);
pval = mdl.anova.pValue(1);
hold on;
plot(limits(1):limits(2), y);
xlim([limits(1)-2 limits(2)+2]);
title(['Ankle (Vol) vs Muscle total (R2=' num2str(r2.Ordinary) ', F=' num2str(fstat), ',p=' num2str(pval) ')']);
set(gcf, 'Position', [2815 303 737 613]);
limits = get(gca, 'Ylim');
ylim([limits(1)-0.1 limits(2)+0.1]);
xlabel('Total muscle score (/50)');
ylabel('Sig volume (ankle flex)');




%%

[~, ~, raw]  = xlsread('R:\data_raw\human\covert_mapping\Demographic and Functional Data\Demographic and Functional Data 2017.11.01.xlsx', 'Case - Sensibility');

read_subj_nums = raw([3 4 5 6 8 9 15], 1);
sense_total =  raw([3 4 5 6 8 9 15], 10);
sense_total = cell2mat(sense_total);

sci_peak =      squeeze( ROI_peak_vals(1, 16:end, 1, [3 5]) );

sci_vol =       squeeze( ROI_sig_count(1, 16:end, 1, [3 5]) );

figure;
subplot(2, 1, 1);
scatter(sense_total, sci_peak(:, 1), [], 'k', 'filled');
text(sense_total, sci_peak(:, 1), read_subj_nums);
limits = get(gca, 'XLim');
[p, S] = polyfit(sense_total, sci_peak(:, 1), 1);
[y, delta] = polyval(p, limits(1):limits(2), S);
mdl = fitlm(sense_total, sci_peak(:, 1) );
r2 = mdl.Rsquared;
fstat = mdl.anova.F(1);
pval = mdl.anova.pValue(1);
hold on;
plot(limits(1):limits(2), y);
title(['Hand (T) vs Sensory total (R2=' num2str(r2.Ordinary) ', F=' num2str(fstat), ',p=' num2str(pval) ')']);
xlim([limits(1)-2 limits(2)+2]);
xlabel('Total sensory score (/24)');
ylabel('Peak T (hand grasp)');
limits = get(gca, 'Ylim');
ylim([limits(1)-2 limits(2)+2]);

subplot(2, 1, 2);
scatter(sense_total, sci_peak(:, 2), [], 'k', 'filled');
text(sense_total, sci_peak(:, 2), read_subj_nums);
limits = get(gca, 'XLim');
[p, S] = polyfit(sense_total, sci_peak(:, 2), 1);
[y, delta] = polyval(p, limits(1):limits(2), S);
mdl = fitlm(sense_total, sci_peak(:, 2) );
r2 = mdl.Rsquared;
fstat = mdl.anova.F(1);
pval = mdl.anova.pValue(1);
hold on;
plot(limits(1):limits(2), y);
title(['Ankle (T) vs Sensory total (R2=' num2str(r2.Ordinary) ', F=' num2str(fstat), ',p=' num2str(pval) ')']);
xlim([limits(1)-2 limits(2)+2]);
xlabel('Total sensory score (/24)');
ylabel('Peak T (ankle flex)');
set(gcf, 'Position', [2061 303 738 613]);
limits = get(gca, 'Ylim');
ylim([limits(1)-2 limits(2)+2]);



figure;
subplot(2, 1, 1);
scatter(sense_total, sci_vol(:, 1), [], 'k', 'filled');
text(sense_total, sci_vol(:, 1), read_subj_nums);
limits = get(gca, 'XLim');
[p, S] = polyfit(sense_total, sci_vol(:, 1), 1);
[y, delta] = polyval(p, limits(1):limits(2), S);
mdl = fitlm(sense_total, sci_vol(:, 1) );
r2 = mdl.Rsquared;
fstat = mdl.anova.F(1);
pval = mdl.anova.pValue(1);
hold on;
plot(limits(1):limits(2), y);
title(['Hand (Vol) vs Sensory total (R2=' num2str(r2.Ordinary) ', F=' num2str(fstat), ',p=' num2str(pval) ')']);
xlim([limits(1)-2 limits(2)+2]);
xlabel('Total sensory score (/24)');
ylabel('Sig volume (ankle flex)');
limits = get(gca, 'Ylim');
ylim([limits(1)-0.1 limits(2)+0.1]);

subplot(2, 1, 2);
scatter(sense_total, sci_vol(:, 2), [], 'k', 'filled');
text(sense_total, sci_vol(:, 2), read_subj_nums);
limits = get(gca, 'XLim');
[p, S] = polyfit(sense_total, sci_vol(:, 2), 1);
[y, delta] = polyval(p, limits(1):limits(2), S);
mdl = fitlm(sense_total, sci_vol(:, 2) );
r2 = mdl.Rsquared;
fstat = mdl.anova.F(1);
pval = mdl.anova.pValue(1);
hold on;
plot(limits(1):limits(2), y);
xlim([limits(1)-2 limits(2)+2]);
title(['Ankle (Vol) vs Sensory total (R2=' num2str(r2.Ordinary) ', F=' num2str(fstat), ',p=' num2str(pval) ')']);
set(gcf, 'Position', [2815 303 737 613]);
limits = get(gca, 'Ylim');
ylim([limits(1)-0.1 limits(2)+0.1]);
xlabel('Total sensory score (/24)');
ylabel('Sig volume (ankle flex)');












