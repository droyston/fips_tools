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
reprocess_data =        1;


% plot flags
bar_plots =         0;
scatter_plots =     1;
stat_to_plot =      'peak';
% stat_to_plot =      'vol';


% file path to subject folders
study_path =        'R:\data_generated\human\covert_mapping\SUBJECT DATA STORAGE\[subject_id]\NIFTI\[current_paradigm]';
% study_path =        'R:\data_generated\human\covert_mapping\SUBJECT DATA STORAGE\[subject_id]\FunctionalData\[current_paradigm]';

% study_path =        'C:\Users\hrnel\Documents\MATLAB\fMRI Analysis\fMRI Analysis Storage\Renamed Folders\[subject_id]\NIFTI\[current_paradigm]\';

% list of subjects to process
% subject_list =          {'CMC01', 'CMC03', 'CMC04', 'CMC05', 'CMC07', 'CMC10', 'CMC11', 'CMC12', 'CMC13', 'CMC14', 'CMC15', 'CMC17'};
% subject_list =          {'CMC10', 'CMC11', 'CMC12', 'CMC13', 'CMC14', 'CMC15', 'CMC17'};
% subject_list =          {'CMS01', 'CMS02', 'CMS03'};
subject_list =          {'CMC03'};

% subject_list =          {'NC01', 'NC02', 'NC03', 'NC04', 'NC05', 'NC06', 'NC07', 'NC08', 'NC09', 'NC10', 'NC11', 'NC12', 'NC13', 'NC14'};

num_subjects =          length(subject_list);

% paradigms = {'Motor_covert_fingers'};
% plaintext_paradigms = {'Motor Covert Fingers'};


% list of conditions to process
paradigms = {'Motor_covert_fingers', 'Motor_covert_hand', 'Motor_covert_wrist', 'Motor_overt',...
    'Sensory_covert_fingers', 'Sensory_covert_wrist'};

% paradigms = {'Sensory_overt_fingers'};

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
%     'Sensory Overt Fingers', 'Sensory Overt Hand', 'Sensory Overt Wrist'};


% paradigms = {'Motor_covert_hand', 'Motor_covert_wrist', 'Motor_overt','Sensory_covert_wrist'};

% plaintext_paradigms = {'Motor Covert Hand', 'Motor Covert Wrist', 'Motor Overt','Sensory Covert Wrist'};

% establishes custom class/structure for subject/condition/ROI data structure
ROI_stats =             ROI_stats_class;

% Sets which ROIs to be analyzed (calibrated for MNI regions
% Individual data can be analyzed similarly but may require inverse-normalization transformation matrix
ROI_list =              {'MNI_Precentral_L_ROI', 'MNI_Postcentral_L_ROI', 'MNI_Supp_Motor_Area_L_ROI', 'MNI_Parietal_Combined_L', ...
    'MNI_Precentral_R', 'MNI_Postcentral_R', 'MNI_Supp_Motor_Area_R', 'MNI_Parietal_Combined_R'};
% ROI_list = {'MNI_Precentral_L_ROI', 'MNI_Postcentral_L_ROI'};

plaintext_ROIs =        {'L Precentral', 'L Postcentral', 'L SMA', 'L PPC', 'R Precentral', 'R Postcentral', 'R SMA', 'R PPC'};
% plaintext_ROIs =        {'M1', 'S1'};

num_ROI =               length(ROI_list);

ROI_path =              'R:\data_generated\human\covert_mapping\CM Analysis Tools\ROI\marsbar-aal-0.2_NIFTIS\';


% ======================================== Stat extraction =================================================


% % 2016-07-06 Royston: implementing data-saving and loading protocol
save_path =         'R:\data_generated\human\covert_mapping\SUBJECT DATA STORAGE\PROCESSED_DATA\';


% sets up inputs for organization function
metadata_struct.subject_list =         subject_list;
metadata_struct.paradigms =            paradigms;
metadata_struct.ROI_list =             ROI_list;
metadata_struct.ROI_path =             ROI_path;
metadata_struct.study_path =           study_path;

loaded_data =       Load_Preproc_fMRI_Data(metadata_struct, save_path);

if ~exist('reprocess_data', 'var')
    reprocess_data =    loaded_data.reprocess_data;
end

if reprocess_data == 1
    
    display('*** EXTRACTING STATS FROM CONTRAST FILES ***')
    
    % extracts and organizes data from spmT contrast files
    data_struct =     organize_extracted_fmri_covert_mapping_stats(metadata_struct);
%     Save_Preproc_fMRI_Data(data_struct, metadata_struct, save_path, reprocess_data);
    
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


%% FIGURE: bar/scatter plots of activation in each condition

display('*** PLOTTING PEAK ACTIVATIONS ***')



% 2016-09-19 Royston: added switch to determine data-in for figures
switch stat_to_plot
    case 'peak'
        data_to_plot = ROI_peak_vals;
        refline_flag = 1;
    case 'vol'
        data_to_plot = ROI_sig_count;
        refline_flag = 0;
end

switch analysis_method
    case 'mean'
        data_to_plot = mean(data_to_plot, 2);
        subj_to_plot = 1;
    case 'indiv'
        subj_to_plot = subject_list;
end

for s=1:length(subj_to_plot)
    for m1_p=1:length(paradigms)
        
        data_in =           squeeze(data_to_plot(:, :, m1_p, :));
        paradigm_info =     paradigm_design(m1_p);
        
        fig_handle =        Plot_Conditional_Stick_Figures(data_in, paradigm_info, plaintext_ROIs);
        
        if refline_flag == 1% peaks
            x = refline(0, 3);
            set(x, 'LineStyle', ':')
            set(x, 'Color', 'k')
            ylabel('Peak T value');
        else% vols
%             ylim([0 1]);
            ylabel('Fraction ROI significant');
        end
    end
end


%% subject data scatter

for task_idx = 1 : num_paradigms
    
    curr_task_info =        paradigm_design(task_idx);
    num_conditions =        length(curr_task_info.conditions);
    
    switch stat_to_plot
        case 'peak'
            data_to_plot =  ROI_peak_vals;
            refline_flag =  1;
        case 'vol'
            data_to_plot =  ROI_sig_count;
            refline_flag =  0;
    end

    task_data =             squeeze( data_to_plot(:, :, task_idx, 1:num_conditions) );
    
    color_spectrum = jet(num_subjects);
    
    figure; hold on;
    
    for subject_idx = 1 : num_subjects
        
        curr_color =        color_spectrum(subject_idx, :);
        subject_data =      squeeze(    task_data(1:2, subject_idx, :) );
        label_loc =         mean(subject_data);
        
        plot(1:num_conditions, subject_data(1, :), 'Color', color_spectrum(subject_idx, :), 'LineWidth', 2);
        plot(1:num_conditions, subject_data(2, :), '--', 'Color', color_spectrum(subject_idx, :));

        for condition_idx = 1 : num_conditions
           scatter([condition_idx condition_idx], subject_data(:, condition_idx),[], [curr_color; curr_color], 'filled');
           text(condition_idx, label_loc(condition_idx), subject_list{subject_idx}, 'Color', curr_color );
        end
        
    end% subject_idx
    
   xlim([0.5 num_conditions+0.5]);
   
   plot([0.5 num_conditions+0.5], [3 3], '--w');
   
   title(curr_task_info.paradigm);
   x_labels = get(gca, 'XTickLabel');
   set(gca, 'XTick', [1:num_conditions]);
   set(gca, 'XTickLabel', curr_task_info.conditions);
   xlabel('Conditions');
   
           if refline_flag == 1% peaks
            x = refline(0, 3);
            set(x, 'LineStyle', ':')
            set(x, 'Color', 'k')
            ylabel('Peak T value');
        else% vols
            ylim([0 1]);
            ylabel('Fraction ROI significant');
           end
           
%            ylabel('Peak T-val (M1/S1)');
   
   set(gcf, 'Position', [2032 125 1046 841]);
   set(gca, 'Color', 'k');
end


%% percent change from simple

% stat_to_plot = 'vol';

for task_idx = 1 : num_paradigms
    
    curr_task_info =        paradigm_design(task_idx);
    num_conditions =        length(curr_task_info.conditions);
    
    switch stat_to_plot
        case 'peak'
            data_to_plot =  ROI_peak_vals;
            refline_flag =  1;
        case 'vol'
            data_to_plot =  ROI_sig_count;
            refline_flag =  0;
    end

    task_data =             squeeze( data_to_plot(:, :, task_idx, 1:num_conditions) );
    
    color_spectrum = jet(num_subjects);
    
    figure; hold on;
    
    for subject_idx = 1 : num_subjects
        
        clearvars norm_data
        
        curr_color =        color_spectrum(subject_idx, :);
        subject_data =      squeeze(    task_data(1:2, subject_idx, :) );
        
        % normalize conditions to simple
        baseline =          subject_data(:, 1);
        norm_data(1, :) =   (subject_data(1, :)./baseline(1) - 1) * 100;
        norm_data(2, :) =   (subject_data(2, :)./baseline(2) - 1) * 100;
        
        label_loc =         mean(norm_data);
        
        plot(1:num_conditions, norm_data(1, :), 'Color', color_spectrum(subject_idx, :), 'LineWidth', 3);
        plot(1:num_conditions, norm_data(2, :), '--', 'Color', color_spectrum(subject_idx, :), 'LineWidth', 3);

        for condition_idx = 1 : num_conditions
           scatter([condition_idx condition_idx], norm_data(:, condition_idx),100, [curr_color; curr_color], 'filled');
%            scatter([condition_idx], norm_data(2, condition_idx),100, [curr_color], 'filled');
%            text(condition_idx, label_loc(condition_idx), subject_list{subject_idx}, 'Color', curr_color, 'FontSize', 20 );
        end
        
    end% subject_idx
    
   xlim([0.5 num_conditions+0.5]);
   
   plot([0.5 num_conditions+0.5], [0 0], '--k');
   
   title_string = strrep(curr_task_info.paradigm, '_', ' ');
   title(title_string);
   x_labels = get(gca, 'XTickLabel');
   set(gca, 'XTick', [1:num_conditions]);
   set(gca, 'XTickLabel', curr_task_info.conditions);
%    set(gca, 'XTickLabel', {});
%    set(gca, 'YTickLabel', {});
   xlabel('Conditions');
   
           if refline_flag == 1% peaks
%             x = refline(0, 3);
%             set(x, 'LineStyle', ':')
%             set(x, 'Color', 'k')
            ylabel('%change from Simple');
        else% vols
%             ylim([0 1]);
            ylabel('Fraction ROI significant');
           end
           
%            ylabel('Peak T-val (M1/S1)');
   
   set(gcf, 'Position', [2032 125 1046 841]);
%    set(gca, 'Color', 'k');
end

%% per-subject data quality

for subject_idx = 1 : num_subjects
    
    task_names =            {paradigm_design(:).paradigm};
    task_names =            task_names([1 2 3 5 6]);
    num_conditions =        4;
    
    switch stat_to_plot
        case 'peak'
            data_to_plot =  ROI_peak_vals;
            refline_flag =  1;
        case 'vol'
            data_to_plot =  ROI_sig_count;
            refline_flag =  0;
    end

    task_data =             squeeze( data_to_plot(:, subject_idx, [1 2 3 5 6], 1:num_conditions) );
    
    color_spectrum = jet(5);
    
    figure; hold on;
    
    for task_idx = 1 : 5
        
        clearvars norm_data
        
        curr_color =     color_spectrum(task_idx, :);
        curr_data =      squeeze(    task_data(1:2, task_idx, :) );
        
        % normalize conditions to simple
        baseline =          curr_data(:, 1);
        norm_data(1, :) =   (curr_data(1, :)./baseline(1) - 1) * 100;
        norm_data(2, :) =   (curr_data(2, :)./baseline(2) - 1) * 100;
        
        label_loc =         mean(norm_data);
        
        plot(1:num_conditions, norm_data(1, :), 'Color', color_spectrum(task_idx, :), 'LineWidth', 2);
        plot(1:num_conditions, norm_data(2, :), '--', 'Color', color_spectrum(task_idx, :));

        for condition_idx = 1 : num_conditions
           scatter([condition_idx condition_idx], norm_data(:, condition_idx),[], [curr_color; curr_color], 'filled');
           
           print_name = strrep(task_names{task_idx}, '_', ' ');
           
           text(condition_idx, label_loc(condition_idx), print_name, 'Color', curr_color );
        end
        
    end% subject_idx
    
   xlim([0.5 num_conditions+0.5]);
   
   plot([0.5 num_conditions+0.5], [0 0], '--w');
   
   title_string = subject_list{subject_idx};
   title(title_string);
   x_labels = get(gca, 'XTickLabel');
   set(gca, 'XTick', [1:num_conditions]);
   set(gca, 'XTickLabel', curr_task_info.conditions);
   xlabel('Conditions');
   
           if refline_flag == 1% peaks
%             x = refline(0, 3);
%             set(x, 'LineStyle', ':')
%             set(x, 'Color', 'k')
            ylabel('%change from Simple');
        else% vols
%             ylim([0 1]);
            ylabel('Fraction ROI significant');
           end
           
%            ylabel('Peak T-val (M1/S1)');
   
   set(gcf, 'Position', [2032 125 1046 841]);
   set(gca, 'Color', 'k');
end


%%

for subject_idx = 1 : num_subjects
    
    task_names =            {paradigm_design(:).paradigm};
    task_names =            task_names([1 2 3 5 6]);
    num_conditions =        4;
    
    switch stat_to_plot
        case 'peak'
            data_to_plot =  ROI_peak_vals;
            refline_flag =  1;
        case 'vol'
            data_to_plot =  ROI_sig_count;
            refline_flag =  0;
    end

    task_data =             squeeze( data_to_plot(:, subject_idx, [1 2 3 5 6], 1:num_conditions) );
    
    color_spectrum = jet(5);
    
    figure; hold on;
    
    for task_idx = 1 : 5
        
        clearvars norm_data big_norm_data
        
        curr_color =     color_spectrum(task_idx, :);
        curr_data =      squeeze(    task_data(1:2, task_idx, :) );
        
        big_curr_data =  squeeze( task_data(:, task_idx, :) );
        
        % normalize conditions to simple
        baseline =          curr_data(:, 1);
        big_baseline =      big_curr_data(:, 1);
        norm_data(1, :) =   (curr_data(1, :)./baseline(1) - 1) * 100;
        norm_data(2, :) =   (curr_data(2, :)./baseline(2) - 1) * 100;
        
        for roi_idx = 1 : 8
            big_norm_data(roi_idx, :) =     (big_curr_data(roi_idx, :)./big_baseline(roi_idx) - 1) * 100;
        end
        
        all_big_norms{subject_idx, task_idx} = big_norm_data;
        all_big_baseline{subject_idx, task_idx} = big_baseline;
        all_baselines{subject_idx, task_idx} =      baseline;
        all_norms{subject_idx, task_idx} =          norm_data;
        all_abs{subject_idx, task_idx} =            curr_data;
        all_big_abs{subject_idx, task_idx} =    big_curr_data;
        
        label_loc =         mean(norm_data);
        
%         plot(1:num_conditions, norm_data(1, :), 'Color', color_spectrum(task_idx, :), 'LineWidth', 2);
%         plot(1:num_conditions, norm_data(2, :), '--', 'Color', color_spectrum(task_idx, :));

        plot(1:num_conditions, big_norm_data, 'Color', color_spectrum(task_idx, :), 'LineWidth', 2);
        

        for condition_idx = 1 : num_conditions
            
            placeholder = repmat(condition_idx, 1, size(big_norm_data, 1) );
            cholder =       reshape(repmat(curr_color, 1, size(big_norm_data, 1) ), [3 8])';
%            scatter([condition_idx condition_idx], norm_data(:, condition_idx),[], [curr_color; curr_color], 'filled');
            scatter(placeholder, big_norm_data(:, condition_idx),[], cholder, 'filled');

           print_name = strrep(task_names{task_idx}, '_', ' ');
           
           text(condition_idx, label_loc(condition_idx), print_name, 'Color', curr_color );
        end
        
    end% subject_idx
    
   xlim([0.5 num_conditions+0.5]);
   
   plot([0.5 num_conditions+0.5], [0 0], '--w');
   
   title_string = subject_list{subject_idx};
   title(title_string);
   x_labels = get(gca, 'XTickLabel');
   set(gca, 'XTick', [1:num_conditions]);
   set(gca, 'XTickLabel', curr_task_info.conditions);
   xlabel('Conditions');
   
           if refline_flag == 1% peaks
%             x = refline(0, 3);
%             set(x, 'LineStyle', ':')
%             set(x, 'Color', 'k')
            ylabel('%change from Simple');
        else% vols
%             ylim([0 1]);
            ylabel('Fraction ROI significant');
           end
           
%            ylabel('Peak T-val (M1/S1)');
   
   set(gcf, 'Position', [2032 125 1046 841]);
   set(gca, 'Color', 'k');
end





%% begin frenzied hard-coding for abstract writing


    
clearvars sig_check enrich num_sig num_enr enr_stats

for task_idx = 1 : 5
    


        
    for subject_idx = 1 : num_subjects
        
        
        current_subj_data =             all_abs{subject_idx, task_idx};
        curr_baseline =                 all_baselines{subject_idx, task_idx};
        curr_norms =                    all_norms{subject_idx, task_idx};
        
        sig_check(:, subject_idx) =     curr_baseline > 3;
        
        enrich(1, :, subject_idx) =                        current_subj_data(1, 2:end) > curr_baseline(1);
        enrich(2, :, subject_idx) =                        current_subj_data(2, 2:end) > curr_baseline(2);
        
        enrich_amt(1, :, subject_idx) =                     curr_norms(1, 2:end);
        enrich_amt(2, :,  subject_idx) =                    curr_norms(2, 2:end);
        
    end
    
    num_sig(1, task_idx) = length(find(sig_check(1, :) == 1) );
    num_sig(2, task_idx) = length(find(sig_check(2, :) == 1) );

    m1_enr_idx{1} =         find(enrich(1, 1, :) == 1);
    m1_enr_idx{2} =         find(enrich(1, 2, :) == 1);
    m1_enr_idx{3} =         find(enrich(1, 3, :) == 1);
    
    s1_enr_idx{1} =         find(enrich(2, 1, :) == 1);
    s1_enr_idx{2} =         find(enrich(2, 2, :) == 1);
    s1_enr_idx{3} =         find(enrich(2, 3, :) == 1);
    
    m1_down_idx{1} =         find(enrich(1, 1, :) ~= 1);
    m1_down_idx{2} =         find(enrich(1, 2, :) ~= 1);
    m1_down_idx{3} =         find(enrich(1, 3, :) ~= 1);
    
    s1_down_idx{1} =         find(enrich(2, 1, :) ~= 1);
    s1_down_idx{2} =         find(enrich(2, 2, :) ~= 1);
    s1_down_idx{3} =         find(enrich(2, 3, :) ~= 1);
    
    m1_enr(1)                  = length(find(enrich(1, 1, :) == 1) );
    m1_enr(2)                  = length(find(enrich(1, 2, :) == 1) );
    m1_enr(3)                  = length(find(enrich(1, 3, :) == 1) );
    
    s1_enr(1)                  = length(find(enrich(2, 1, :) == 1) );
    s1_enr(2)                  = length(find(enrich(2, 2, :) == 1) );
    s1_enr(3)                  = length(find(enrich(2, 3, :) == 1) );
    
    m1_amt(1) =                 mean(enrich_amt(1, 1, m1_enr_idx{1}));
    m1_amt(2) =                 mean(enrich_amt(1, 2, m1_enr_idx{2}));
    m1_amt(3) =                 mean(enrich_amt(1, 3, m1_enr_idx{3}));
    
    s1_amt(1) =                 mean(enrich_amt(2, 1, s1_enr_idx{1}));
    s1_amt(2) =                 mean(enrich_amt(2, 2, s1_enr_idx{2}));
    s1_amt(3) =                 mean(enrich_amt(2, 3, s1_enr_idx{3}));
    
    
    m1_down(1) =                 mean(enrich_amt(1, 1, m1_down_idx{1}));
    m1_down(2) =                 mean(enrich_amt(1, 2, m1_down_idx{2}));
    m1_down(3) =                 mean(enrich_amt(1, 3, m1_down_idx{3}));
    
    s1_down(1) =                 mean(enrich_amt(2, 1, s1_down_idx{1}));
    s1_down(2) =                 mean(enrich_amt(2, 2, s1_down_idx{2}));
    s1_down(3) =                 mean(enrich_amt(2, 3, s1_down_idx{3}));
    
    enr_stats(1, 1, :, task_idx) =     m1_enr;
    enr_stats(1, 2, :, task_idx) =     m1_amt;
    
    enr_stats(2, 1, :, task_idx) =     s1_enr;
    enr_stats(2, 2, :, task_idx) =     s1_amt;
    
    hold on;
    subplot(3, 5, task_idx);
    bar([m1_amt; s1_amt]')
    title(task_names{task_idx})
    
    subplot(3, 5, task_idx + 5);
    bar([m1_down; s1_down]')
    
    
    m1_change(1) =              mean(enrich_amt(1, 1, :) );
    m1_change(2) =              mean(enrich_amt(1, 2, :) );
    m1_change(3) =              mean(enrich_amt(1, 3, :) );
    
       
    s1_change(1) =              mean(enrich_amt(2, 1, :) );
    s1_change(2) =              mean(enrich_amt(2, 2, :) );
    s1_change(3) =              mean(enrich_amt(2, 3, :) );
   
    subplot(3, 5, task_idx + 10);
    bar([m1_change; s1_change]');
    
    all_changes(task_idx, :, :) = [m1_change; s1_change];
    
end

effect = squeeze( mean(all_changes, 1) )

motor_effect = squeeze( mean(all_changes(1:3, :, :), 1) )

sense_effect = squeeze( mean(all_changes(4:5, :, :), 1) )

%% better, soft-coded

clearvars sig_check enrich num_sig num_enr enr_stats enr_idx down_idx enrich_amt down all_changes change enr amt

for task_idx = 1 : 5
    
    for subject_idx = 1 : num_subjects
        
        
        current_subj_data =             all_big_abs{subject_idx, task_idx};
        curr_baseline =                 all_big_baseline{subject_idx, task_idx};
        curr_norms =                    all_big_norms{subject_idx, task_idx};
        
        sig_check(:, subject_idx) =     curr_baseline > 3;
        
        for roi_idx = 1 : 8
           
%             number(roit_idx, :, subject_idx) =                        current_subj_data(roi_idx, :);
            
            enrich(roi_idx, :, subject_idx) =                        current_subj_data(roi_idx, 2:end) > curr_baseline(roi_idx);
            enrich_amt(roi_idx, :, subject_idx) =                   curr_norms(roi_idx, 2:end);
        end
        

        
    end
    
%     number =        squeeze(number(1, :, :) );
    
    relevant_data = squeeze(enrich_amt(2, :, :));
    relevant_data = relevant_data(:, [1 3 4 6]);

    
    finger_m1_clavicle = mean(relevant_data, 2);
    finger_m1_clavicle_std = std(relevant_data, 0, 2);
    
    for roi_idx = 1 : 8
        
        num_sig(roi_idx, task_idx) =    length(find(sig_check(roi_idx, :) == 1) );
        
        for cond_idx = 1 : 3
            enr_idx{roi_idx, cond_idx} =           find(enrich(roi_idx, cond_idx, :) == 1);
        
            down_idx{roi_idx, cond_idx} =           find(enrich(roi_idx, cond_idx, :) ~= 1);
            
            enr(roi_idx, cond_idx) =                length(find(enrich(roi_idx, cond_idx, :) == 1) );
            
            amt(roi_idx, cond_idx) =                mean(enrich_amt(roi_idx, cond_idx, enr_idx{cond_idx} ) );
            
            down(roi_idx, cond_idx) =               mean(enrich_amt(roi_idx, cond_idx, down_idx{roi_idx, cond_idx} ) );
            
        
        end
        
        enr_stats{1, roi_idx, :, task_idx} =        enr;
        enr_stats{2, roi_idx, :, task_idx} =        amt;

        for cond_idx = 1 : 3
            
            change(roi_idx, cond_idx) =             mean(enrich_amt(roi_idx, cond_idx, 6:12) );
            
                       
        end
        

    end
    
    finger_change = change(1:2, :)
    
    all_changes(task_idx, :, :) = change;
    
    all_change_cell{task_idx} = change;
    
end

effect = squeeze( mean(all_changes, 1) )
% effect = squeeze( mean(all_changes([1 2 4], :, :), 1) )
effect_std = squeeze( std(all_changes) )


motor_effect = squeeze( mean(all_changes(1:3, :, :), 1) );
motor_std =     squeeze( std(all_changes(1:3, :, :) ) );

sense_effect = squeeze( mean(all_changes(4:5, :, :), 1) );

finger_motor = all_changes(1, 1, :);


%%

overt_data =    squeeze( data_to_plot(1:2, :, 4, 1:3) );

mean_hands =    squeeze( mean(overt_data, 2) )

%%

all_m1_data =       squeeze(data_to_plot(1, 6:12, [1 2 3], 1:4) );
all_s1_data =       squeeze(data_to_plot(2, 6:12, [5 6], 1:4) );


m1_cond_data = [];
clearvars all_m1_conditions all_s1_conditions

for cond_idx = 1 : 4
    
    m1_cond_data = all_m1_data(:, :, cond_idx);
    
    test = m1_cond_data(:);
    
    all_m1_conditions(:, cond_idx) = test;
    
    s1_cond_data = all_s1_data(:, :, cond_idx);
    
    test2 = s1_cond_data(:);
    
    all_s1_conditions(:, cond_idx) = test2;
    
    
end






%%

clearvars p_vals

for comp_idx = 2 : 4
    
    curr_comp =     all_m1_conditions(:, comp_idx);
    
    [yes, m1_p] =     ttest2(all_m1_conditions(:, 1), curr_comp);
    
    m1_p_vals(comp_idx) = m1_p;
    
    
    
    curr_comp =     all_s1_conditions(:, comp_idx);
    
    [yes, s1_p] =     ttest2(all_s1_conditions(:, 1), curr_comp);
    
    s1_p_vals(comp_idx) = s1_p;
    
end


%%
% switch analysis_method
%     
%     % plots 10 figures per subject
%     case 'indiv'
%         
%         for s=1:length(subject_list)
%             for p=1:length(paradigms)
%                 
%                 % clears and resets paradigm-specific conditions
%                 clearvars stats_to_plot paradigm_stats ROI_labels
%                 conditions = paradigm_design(p).conditions;
%                 num_conditions = length(conditions);
%                 
%                 % extracts stats to plot
%                 for c=1:num_conditions
%                     paradigm_stats{c} =     data_to_plot(:, :, p, c);
%                 end
%                 
%                 
%                 % organizes data for Plot_Bars
%                 for c=1:length(conditions)
%                     for r=1:length(plaintext_ROIs)
%                         
%                         condition_idx =                     r*(num_conditions + 1) - ( (num_conditions + 1) - c);
%                         stats_to_plot{condition_idx, :} =   paradigm_stats{c}(r, :);
%                         current_ROI_labels =                repmat(  plaintext_ROIs(r) , 1, 4);
%                         
%                     end% ROI loop
%                 end% condition loop
%                 
%                 if bar_plots == 1
%                     
%                     % sets bar colors based on paradigm
%                     switch num_conditions
%                         case 1% stim, single color = dark gray
%                             color_vector = [37 37 37];
%                             label_interval = (num_conditions):num_conditions*2:(num_conditions*length(ROI_list)*2);
%                         case 4% enrichment, hot
%                             color_vector = [ [255 255 178]; [254 204 92]; [253 141 60]; [227 26 28] ];
%                             label_interval = ( (num_conditions+1)/2):num_conditions+1:( (num_conditions+1)*length(ROI_list));
%                         case 5% motor overt, red/blue gradient
%                             color_vector = [ [215 25 28]; [253 174 97]; [255 255 191]; [171 221 164]; [43 131 186] ];
%                             label_interval = ( (num_conditions+1)/2):num_conditions+1:( (num_conditions+1)*length(ROI_list));
%                     end
%                     
%                     %actual plotting function
%                     h = Plot_Bars({}, stats_to_plot','Color', (color_vector/255));
%                     
%                     % == figure settings ===
%                     xticks = [plaintext_ROIs];
%                     set(gca, 'XTick', label_interval);
%                     set(gca, 'XTickLabel', xticks);
%                     %                 xlabel_rotate(0)
%                     % reference line at T=3
%                     set(gca, 'ygrid', 'on')
%                     %   %             plot([0 10],[3 3],'--r')
%                     
%                     if refline_flag == 1
%                         x = refline(0, 3);
%                         set(x, 'LineStyle', '--')
%                         set(x, 'Color', 'r')
%                     end
%                     % axis labels
%                     ylabel('Peak T value');
%                     xlabel('Regions of interest');
%                     % legend
%                     legend(conditions)
%                     % title
%                     title_string = { sprintf( '%s \n Peaks - %s', cell2mat( subject_list(s) ), cell2mat( plaintext_paradigms(p) ) ) };
%                     title(title_string)
%                     % misc
%                     set(gcf, 'PaperPositionMode', 'auto');
%                     set(gcf,'units','normalized','outerposition',[0.15 0.15 0.65 0.65])
%                     
%                 end% bar plot flag
%                 
%                 %=========================================================================
%                 
%                 
%                 % 2016-07-05 Royston
%                 % across-condition scatter/line plot
%                 
%                 if scatter_plots == 1
%                     
%                     switch num_conditions
%                         case 4% covert enrichment
%                             
%                             figure; hold on;
%                             current_ROI_vals = zeros(8, 4);
%                             
%                             % assign ROI-specific line details
%                             for r = 1 : 8
%                                 switch r
%                                     case 1% Left M1
%                                         emphasis_width = 3;
%                                         emphasis_style = '-';
%                                         emphasis_color = [0 0.4470 0.7410];
%                                     case 2% Left S1
%                                         emphasis_width = 3;
%                                         emphasis_style = '-';
%                                         emphasis_color = [0.8500 0.3250 0.0980];
%                                     case 3% Left SMA
%                                         emphasis_width = 1;
%                                         emphasis_style = '-';
%                                         emphasis_color = [0.9290 0.6940 0.1250];
%                                     case 4% Left PPC
%                                         emphasis_width = 1;
%                                         emphasis_style = '-';
%                                         emphasis_color = [0.4940 0.1840 0.5560];
%                                     case 5% Right M1
%                                         emphasis_width = 1;
%                                         emphasis_style = '--';
%                                         emphasis_color = [0 0.4470 0.7410];
%                                     case 6% Right S1
%                                         emphasis_width = 1;
%                                         emphasis_style = '--';
%                                         emphasis_color = [0.8500 0.3250 0.0980];
%                                     case 7% Right SMA
%                                         emphasis_width = 1;
%                                         emphasis_style = '--';
%                                         emphasis_color = [0.9290 0.6940 0.1250];
%                                     case 8% Right PPC
%                                         emphasis_width = 1;
%                                         emphasis_style = '--';
%                                         emphasis_color = [0.4940 0.1840 0.5560];
%                                 end% ROI switch
%                                 
%                                 current_ROI_vals(r, :) = squeeze( data_to_plot(r, :, p, 1:4) );
%                                 
%                                 % scatter/line plots
%                                 l = plot(current_ROI_vals(r, :), 'LineWidth', emphasis_width, 'LineStyle', emphasis_style, 'Color', emphasis_color );
%                                 current_color(r, :) = get(l, 'Color');
%                                 %                             scatter(1:4, current_ROI_vals(r, :), 40, current_color, 'filled' );
%                                 
%                             end% ROI loop
%                             
%                             legend(plaintext_ROIs, 'Location', 'northwest');
%                             
%                             for r = 1 : 8
%                                 scatter(1:4, current_ROI_vals(r, :), 40, current_color(r, :), 'filled' );
%                                 
%                             end
%                             
%                             % figure settings
%                             title(plaintext_paradigms(p));
%                             xlim([0.5 4.5])
%                             curr_ylim = get(gca, 'ylim');
%                             ylim([0 curr_ylim(2)]);
%                             xlabel('Enrichment Condition')
%                             ylabel('Peak T-val')
%                             
%                             if refline_flag == 1
%                                 
%                                 x = refline(0, 3);
%                                 set(x, 'LineStyle', ':')
%                                 set(x, 'Color', 'k')
%                             end
%                             
%                             condition_ticks = get(gca, 'XTickLabels');
%                             display_conditions = {'', 'Simple', '', 'Goal', '', 'Audio', '', 'Stim'};
%                             set(gca, 'XTickLabels', display_conditions)
%                             
%                             %                         legend(plaintext_ROIs, 'Location', 'northwest');
%                             
%                             
%                             %=========================================
%                             
%                         case 5% motor overt
%                             
%                             figure; hold on;
%                             current_ROI_vals = zeros(8, 5);
%                             
%                             % assign ROI-specific line details
%                             for r = 1 : 8
%                                 switch r
%                                     case 1% Left M1
%                                         emphasis_width = 3;
%                                         emphasis_style = '-';
%                                         emphasis_color = [0 0.4470 0.7410];
%                                     case 2% Left S1
%                                         emphasis_width = 3;
%                                         emphasis_style = '-';
%                                         emphasis_color = [0.8500 0.3250 0.0980];
%                                     case 3% Left SMA
%                                         emphasis_width = 1;
%                                         emphasis_style = '-';
%                                         emphasis_color = [0.9290 0.6940 0.1250];
%                                     case 4% Left PPC
%                                         emphasis_width = 1;
%                                         emphasis_style = '-';
%                                         emphasis_color = [0.4940 0.1840 0.5560];
%                                     case 5% Right M1
%                                         emphasis_width = 1;
%                                         emphasis_style = '--';
%                                         emphasis_color = [0 0.4470 0.7410];
%                                     case 6% Right S1
%                                         emphasis_width = 1;
%                                         emphasis_style = '--';
%                                         emphasis_color = [0.8500 0.3250 0.0980];
%                                     case 7% Right SMA
%                                         emphasis_width = 1;
%                                         emphasis_style = '--';
%                                         emphasis_color = [0.9290 0.6940 0.1250];
%                                     case 8% Right PPC
%                                         emphasis_width = 1;
%                                         emphasis_style = '--';
%                                         emphasis_color = [0.4940 0.1840 0.5560];
%                                 end% ROI switch
%                                 
%                                 current_ROI_vals(r, :) = squeeze( data_to_plot(r, :, p, 1:5) );
%                                 
%                                 % scatter/line plots
%                                 l = plot(current_ROI_vals(r, :), 'LineWidth', emphasis_width, 'LineStyle', emphasis_style, 'Color', emphasis_color );
%                                 current_color(r, :) = get(l, 'Color');
%                                 
%                             end% ROI loop
%                             
%                             legend(plaintext_ROIs, 'Location', 'northeast')
%                             
%                             for r = 1 : 8
%                                 scatter(1:5, current_ROI_vals(r, :), 40, current_color(r, :), 'filled' );
%                             end
%                             
%                             % figure settings
%                             title(plaintext_paradigms(p));
%                             xlim([0.5 5.5])
%                             curr_ylim = get(gca, 'ylim');
%                             ylim([0 curr_ylim(2)]);
%                             xlabel('Movement')
%                             ylabel('Peak T-val')
%                             
%                             if refline_flag == 1
%                                 x = refline(0, 3);
%                                 set(x, 'LineStyle', ':')
%                                 set(x, 'Color', 'k')
%                             end
%                             
%                             condition_ticks = get(gca, 'XTickLabels');
%                             display_conditions = {'', 'Lip', '', 'Wrist', '', 'Hand', '', 'Fingers', '', 'Ankle'};
%                             set(gca, 'XTickLabels', display_conditions)
%                             
%                     end% scatter/line plot switch
%                     
%                 end% scatter plot flag
%                 
%             end % paradigm loop
%             
%         end% subject loop
%         
%         
%         
%         
%         %============================================================================================================================
%         
%         
%         % plots 10 figures of averaged data
%     case 'mean'
%         
%         for p=1:length(paradigms)
%             
%             % clears and resets paradigm-specific conditions
%             clearvars stats_to_plot paradigm_stats ROI_labels
%             conditions = paradigm_design(p).conditions;
%             num_conditions = length(conditions);
%             
%             % extracts stats to plot
%             for c=1:num_conditions
%                 paradigm_stats{c} =     data_to_plot(:, :, p, c);
%             end
%             
%             % organizes data for Plot_Bars
%             for c=1:length(conditions)
%                 for r=1:length(plaintext_ROIs)
%                     
%                     condition_idx =                     r*(num_conditions + 1) - ( (num_conditions + 1) - c);
%                     stats_to_plot{condition_idx, :} =   paradigm_stats{c}(r, :);
%                     current_ROI_labels =                repmat(  plaintext_ROIs(r) , 1, 4);
%                     
%                 end% ROI loop
%             end% condition loop
%             
%             if bar_plots == 1
%                 
%                 % sets bar colors based on paradigm
%                 switch num_conditions
%                     case 1% stim, single color = dark gray
%                         color_vector = [37 37 37];
%                         label_interval = (num_conditions):num_conditions*2:(num_conditions*length(ROI_list)*2);
%                     case 4% enrichment, hot
%                         color_vector = [ [255 255 178]; [254 204 92]; [253 141 60]; [227 26 28] ];
%                         label_interval = ( (num_conditions+1)/2):num_conditions+1:( (num_conditions+1)*length(ROI_list));
%                     case 5% motor overt, red/blue gradient
%                         color_vector = [ [215 25 28]; [253 174 97]; [255 255 191]; [171 221 164]; [43 131 186] ];
%                         label_interval = ( (num_conditions+1)/2):num_conditions+1:( (num_conditions+1)*length(ROI_list));
%                 end
%                 
%                 %actual plotting function
%                 h = Plot_Bars({}, stats_to_plot','Color', (color_vector/255), 'IndPoints', true);
%                 
%                 % == figure settings ===
%                 xticks = [plaintext_ROIs];
%                 set(gca, 'XTick', label_interval);
%                 set(gca, 'XTickLabel', xticks);
%                 %                 xlabel_rotate(0)
%                 
%                 
%                 % reference line at T=3
%                 set(gca, 'ygrid', 'on')
%                 %   %             plot([0 10],[3 3],'--r')
%                 if refline_flag == 1
%                     x = refline(0, 3);
%                     set(x, 'LineStyle', '--')
%                     set(x, 'Color', 'r')
%                 end
%                 
%                 % axis labels
%                 ylabel('Peak T value');
%                 xlabel('Regions of interest');
%                 
%                 % legend
%                 legend(conditions)
%                 
%                 % title
%                 title_string = { sprintf( 'All subjects (n=%i) \n Peaks - %s', length(subject_list), cell2mat( plaintext_paradigms(p) ) ) };
%                 title(title_string)
%                 
%                 % misc
%                 set(gcf, 'PaperPositionMode', 'auto');
%                 set(gcf,'units','normalized','outerposition',[0.15 0.15 0.65 0.65])
%                 
%                 
%             end% bar plot flag
%             
%             %============================================================================
%             
%             if scatter_plots == 1
%                 
%                 switch num_conditions
%                     case 4% covert enrichment
%                         
%                         figure; hold on;
%                         %                         current_ROI_vals = zeros(8, 4);
%                         clearvars current_ROI_vals mean_ROI_vals std_ROI_vals
%                         
%                         % assign ROI-specific line details
%                         for r = 1 : 8
%                             switch r
%                                 case 1% Left M1
%                                     emphasis_width = 3;
%                                     emphasis_style = '-';
%                                     emphasis_color = [0 0.4470 0.7410];
%                                 case 2% Left S1
%                                     emphasis_width = 3;
%                                     emphasis_style = '-';
%                                     emphasis_color = [0.8500 0.3250 0.0980];
%                                 case 3% Left SMA
%                                     emphasis_width = 1;
%                                     emphasis_style = '-';
%                                     emphasis_color = [0.9290 0.6940 0.1250];
%                                 case 4% Left PPC
%                                     emphasis_width = 1;
%                                     emphasis_style = '-';
%                                     emphasis_color = [0.4940 0.1840 0.5560];
%                                 case 5% Right M1
%                                     emphasis_width = 1;
%                                     emphasis_style = '--';
%                                     emphasis_color = [0 0.4470 0.7410];
%                                 case 6% Right S1
%                                     emphasis_width = 1;
%                                     emphasis_style = '--';
%                                     emphasis_color = [0.8500 0.3250 0.0980];
%                                 case 7% Right SMA
%                                     emphasis_width = 1;
%                                     emphasis_style = '--';
%                                     emphasis_color = [0.9290 0.6940 0.1250];
%                                 case 8% Right PPC
%                                     emphasis_width = 1;
%                                     emphasis_style = '--';
%                                     emphasis_color = [0.4940 0.1840 0.5560];
%                             end% ROI switch
%                             
%                             
%                             current_ROI_vals = squeeze(data_to_plot(r, :, p, 1:4));
%                             mean_ROI_vals(r, :) = mean(current_ROI_vals, 1);
%                             std_ROI_vals(r, :) = std(current_ROI_vals, 1);
%                             
%                             % scatter/line plots
%                             l = plot(mean_ROI_vals(r, :), 'LineWidth', emphasis_width, 'LineStyle', emphasis_style, 'Color', emphasis_color);
%                             current_color(r, :) = get(l, 'Color');
%                             %                             scatter(1:4, current_ROI_vals(r, :), 40, current_color, 'filled' );
%                             
%                         end% ROI loop
%                         
%                         legend(plaintext_ROIs, 'Location', 'best');
%                         
%                         for r = 1 : 8
%                             scatter(1:4, mean_ROI_vals(r, :), 40, current_color(r, :), 'filled' );
%                             %                             errorbar( mean_ROI_vals(r, :), std_ROI_vals(r, :), current_color(r, :) );
%                         end
%                         
%                         % figure settings
%                         title(plaintext_paradigms(p));
%                         xlim([0.5 4.5])
%                         curr_ylim = get(gca, 'ylim');
%                         ylim([0 curr_ylim(2)]);
%                         xlabel('Enrichment Condition')
%                         ylabel('Peak T-val')
%                         
%                         if refline_flag == 1
%                             x = refline(0, 3);
%                             set(x, 'LineStyle', ':')
%                             set(x, 'Color', 'k')
%                         end
%                         
%                         condition_ticks = get(gca, 'XTickLabels');
%                         display_conditions = {'', 'Simple', '', 'Goal', '', 'Audio', '', 'Stim'};
%                         set(gca, 'XTickLabels', display_conditions)
%                         
%                         %                         legend(plaintext_ROIs, 'Location', 'northwest');
%                         
%                         
%                         %=============================================
%                         
%                     case 5% motor overt
%                         
%                         figure; hold on;
%                         %                         current_ROI_vals = zeros(8, 5);
%                         clearvars current_ROI_vals mean_ROI_vals std_ROI_vals
%                         
%                         % assign ROI-specific line details
%                         for r = 1 : 8
%                             switch r
%                                 case 1% Left M1
%                                     emphasis_width = 3;
%                                     emphasis_style = '-';
%                                     emphasis_color = [0 0.4470 0.7410];
%                                 case 2% Left S1
%                                     emphasis_width = 3;
%                                     emphasis_style = '-';
%                                     emphasis_color = [0.8500 0.3250 0.0980];
%                                 case 3% Left SMA
%                                     emphasis_width = 1;
%                                     emphasis_style = '-';
%                                     emphasis_color = [0.9290 0.6940 0.1250];
%                                 case 4% Left PPC
%                                     emphasis_width = 1;
%                                     emphasis_style = '-';
%                                     emphasis_color = [0.4940 0.1840 0.5560];
%                                 case 5% Right M1
%                                     emphasis_width = 1;
%                                     emphasis_style = '--';
%                                     emphasis_color = [0 0.4470 0.7410];
%                                 case 6% Right S1
%                                     emphasis_width = 1;
%                                     emphasis_style = '--';
%                                     emphasis_color = [0.8500 0.3250 0.0980];
%                                 case 7% Right SMA
%                                     emphasis_width = 1;
%                                     emphasis_style = '--';
%                                     emphasis_color = [0.9290 0.6940 0.1250];
%                                 case 8% Right PPC
%                                     emphasis_width = 1;
%                                     emphasis_style = '--';
%                                     emphasis_color = [0.4940 0.1840 0.5560];
%                             end% ROI switch
%                             
%                             current_ROI_vals = squeeze(data_to_plot(r, :, p, 1:5));
%                             mean_ROI_vals(r, :) = mean(current_ROI_vals, 1);
%                             std_ROI_vals(r, :)= std(current_ROI_vals, 1);
%                             % scatter/line plots
%                             l = plot(mean_ROI_vals(r, :), 'LineWidth', emphasis_width, 'LineStyle', emphasis_style, 'Color', emphasis_color );
%                             current_color(r, :) = get(l, 'Color');
%                             
%                             
%                         end% ROI loop
%                         
%                         legend(plaintext_ROIs, 'Location', 'best');
%                         
%                         for r = 1 : 8
%                             scatter(1:5, mean_ROI_vals(r, :), 40, current_color(r, :), 'filled' );
%                             %                             errorbar(1:5, mean_ROI_vals(r, :), std_ROI_vals(r, :), current_color(r, :) );
%                         end
%                         
%                         % figure settings
%                         title(plaintext_paradigms(p));
%                         xlim([0.5 5.5])
%                         curr_ylim = get(gca, 'ylim');
%                         ylim([0 curr_ylim(2)]);
%                         xlabel('Movement')
%                         ylabel('Peak T-val')
%                         
%                         if refline_flag == 1
%                             x = refline(0, 3);
%                             set(x, 'LineStyle', ':')
%                             set(x, 'Color', 'k')
%                         end
%                         
%                         condition_ticks = get(gca, 'XTickLabels');
%                         display_conditions = {'', 'Lip', '', 'Wrist', '', 'Hand', '', 'Fingers', '', 'Ankle'};
%                         set(gca, 'XTickLabels', display_conditions)
%                         
%                 end% scatter/line plot switch
%                 
%             end% scatter flag
%             
%             
%             
%         end % paradigm loop
% end% plotting


%%



























