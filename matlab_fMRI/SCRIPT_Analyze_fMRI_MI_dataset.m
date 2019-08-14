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
bar_plots =         1;
scatter_plots =     0;

reprocess_data =    0;

% file path to subject folders
study_path =        'R:\data_generated\human\fMRI_motor_imagery\New subject data storage\[subject_id]\NIFTI\[current_paradigm]';

% list of subjects to process
% subject_list =          {'NS12'};
% subject_list =          {'NC01', 'NC02', 'NC03', 'NC04', 'NC05', 'NC06', 'NC07', 'NC08', 'NC09', 'NC10', 'NC11', 'NC12', 'NC13', 'NC14'};
% subject_list =              {'NS01', 'NS02', 'NS03', 'NS04', 'NS06', 'NS07', 'NS12', 'NS13'};

subject_list =          {'NC01', 'NC02', 'NC03', 'NC04', 'NC05', 'NC06', 'NC07', 'NC08', 'NC09', 'NC10', 'NC11', 'NC12', 'NC13', 'NC14',...
    'NS01', 'NS02', 'NS03', 'NS04', 'NS06', 'NS07', 'NS12', 'NS13'};




% list of conditions to process
% if dominance_flag ==1, organize_extracted_fmri_stats looks for a [side]_ prefix to read in L/R tasks appropriately
paradigms = {'[side]_hand_grasp_attempted', '[side]_hand_grasp_imagined'};

plaintext_paradigms = {'Dom. Hand Grasp Attempted', 'Dom. Hand Grasp Imagined'};

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

save_path = 'R:\data_generated\human\fMRI_motor_imagery\New subject data storage\PROCESSED_DATA\';

display('*** EXTRACTING STATS FROM CONTRAST FILES ***')

% sets up inputs for organization function
metadata_struct.subject_list =         subject_list;
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
master_list =                    data_struct.master_list;
ROI_peak_vals =                  data_struct.ROI_peak_vals;
ROI_peak_locs =                  data_struct.ROI_peak_locs;
ROI_active_count =               data_struct.ROI_active_count;
ROI_active_vals =                data_struct.ROI_active_vals;
ROI_active_locs =                data_struct.ROI_active_locs;
ROI_sig_count =                  data_struct.ROI_sig_count;
ROI_sig_vals =                   data_struct.ROI_sig_vals;
ROI_sig_locs =                   data_struct.ROI_sig_locs;


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
    
    plaintext_ROIs =    {'Dominant M1', 'Dominant S1', 'Dominant SMA', 'Dominant PPC',...
        'Non-dom M1', 'Non-dom S1', 'Non-dom SMA', 'Non-dom PPC'};
    
end

%% Group data organization

if strcmp(analysis_method, 'mean')
    
    group_data =                     {};
    AB_peak_vals =                   [];
    SCI_peak_vals =                  [];
    AB_sig_count =                   [];
    SCI_sig_count =                  [];
    num_group_subjects(1) =          0;
    num_group_subjects(2) =          0;
    
    for subject_idx = 1 : num_subjects
        
        current_subject =   subject_list{subject_idx};
        SCI_check =         strfind(current_subject, 'NS');
        
        if isempty(SCI_check)% if able-bodied control
            num_group_subjects(1) =                        num_group_subjects(1) + 1;
            AB_peak_vals(:, num_group_subjects(1), :) =         squeeze( ROI_peak_vals(:, subject_idx, :) );
            AB_sig_count(:, num_group_subjects(1), :) =         squeeze( ROI_sig_count(:, subject_idx, :) );
            
        else% if SCI subject
            num_group_subjects(2) =                       num_group_subjects(2) + 1;
            SCI_peak_vals(:, num_group_subjects(2), :) =       squeeze( ROI_peak_vals(:, subject_idx, :) );
            SCI_sig_count(:, num_group_subjects(2), :) =         squeeze( ROI_sig_count(:, subject_idx, :) );
            
        end% subject status
        
    end%% subject loop
    
    AB_data.peak_vals = AB_peak_vals;
    AB_data.sig_count = AB_sig_count;
    
    SCI_data.peak_vals = SCI_peak_vals;
    SCI_data.sig_count = SCI_sig_count;
    
    group_data{1} =     AB_data;
    group_data{2} =     SCI_data;
    
    group_names{1} =    'AB';
    group_names{2} =    'SCI';
    
    group_peak_means{1} =    squeeze( mean( group_data{1}.peak_vals, 2) );
    group_peak_means{2} =    squeeze( mean( group_data{2}.peak_vals, 2) );
    
    group_sigcount_means{1} =    squeeze( mean( group_data{1}.sig_count, 2) );
    group_sigcount_means{2} =    squeeze( mean( group_data{2}.sig_count, 2) );
    
    
    % statistics
    for r = 1 : num_ROI
        
        for c = 1 : num_paradigms
            
            for group_idx = 1 : 2
                
                curr_peakval_comparison_data{group_idx} = group_data{group_idx}.peak_vals(r, :, c);
                
                curr_sigcount_comparison_data{group_idx} = group_data{group_idx}.sig_count(r, :, c);
                
            end% group loop
            
            
            % peak vals
            peakval_sig_tests{1}(r, c) =    ranksum(curr_peakval_comparison_data{1}, curr_peakval_comparison_data{2});
            
            [h, p, ci, stats] =     ttest2(curr_peakval_comparison_data{1}, curr_peakval_comparison_data{2});
            peakval_sig_tests{2}(r, c) =    p;
            
            
            
            % sig count
            sigcount_sig_tests{1}(r, c) =    ranksum(curr_sigcount_comparison_data{1}, curr_sigcount_comparison_data{2});
            
            [h, p, ci, stats] =     ttest2(curr_sigcount_comparison_data{1}, curr_sigcount_comparison_data{2});
            sigcount_sig_tests{2}(r, c) =    p;
            
        end% paradigm loop
        
    end% ROI loop
    
    %peak vals
    [peakval_sig_row{1}, peakval_sig_col{1}] =    find(peakval_sig_tests{1} < 0.05);
    [peakval_sig_row{2}, peakval_sig_col{2}] =    find(peakval_sig_tests{2} < 0.05);
    
    peakval_sig_comparisons{1} =          zeros(num_ROI, num_paradigms);
    peakval_sig_comparisons{2} =          zeros(num_ROI, num_paradigms);
    
    peakval_sig_comparisons{1}(peakval_sig_row{1}, peakval_sig_col{1}) = 1;
    peakval_sig_comparisons{2}(peakval_sig_row{2}, peakval_sig_col{2}) = 1;
    
    peakval_plot_sigs{1} = NaN(8, 2);
    peakval_plot_sigs{2} = NaN(8, 2);
    
    peakval_plot_sigs{1}(peakval_sig_row{1}, peakval_sig_col{1}) = peakval_sig_tests{1}(peakval_sig_row{1}, peakval_sig_col{1});
    peakval_plot_sigs{2}(peakval_sig_row{2}, peakval_sig_col{2}) = peakval_sig_tests{2}(peakval_sig_row{2}, peakval_sig_col{2});

    
    %sig count
    [sigcount_sig_row{1}, sigcount_sig_col{1}] =    find(sigcount_sig_tests{1} < 0.05);
    [sigcount_sig_row{2}, sigcount_sig_col{2}] =    find(sigcount_sig_tests{2} < 0.05);
    
    sigcount_sig_comparisons{1} =          zeros(num_ROI, num_paradigms);
    sigcount_sig_comparisons{2} =          zeros(num_ROI, num_paradigms);
    
    sigcount_sig_comparisons{1}(sigcount_sig_row{1}, sigcount_sig_col{1}) = 1;
    sigcount_sig_comparisons{2}(sigcount_sig_row{2}, sigcount_sig_col{2}) = 1;
    
    sigcount_plot_sigs{1} = NaN(8, 2);
    sigcount_plot_sigs{2} = NaN(8, 2);
    
    sigcount_plot_sigs{1}(sigcount_sig_row{1}, sigcount_sig_col{1}) = sigcount_sig_tests{1}(sigcount_sig_row{1}, sigcount_sig_col{1});
    sigcount_plot_sigs{2}(sigcount_sig_row{2}, sigcount_sig_col{2}) = sigcount_sig_tests{2}(sigcount_sig_row{2}, sigcount_sig_col{2});
    
end% group data organization


%% Plot peak activations

for r = 1 : 8
    switch r
        case 1% Left M1
            emphasis_width{r} = 3;
            emphasis_style{r} = '-';
            emphasis_color{r} = [0 0.4470 0.7410];
        case 2% Left S1
            emphasis_width{r} = 3;
            emphasis_style{r} = '-';
            emphasis_color{r} = [0.8500 0.3250 0.0980];
        case 3% Left SMA
            emphasis_width{r} = 1;
            emphasis_style{r} = '-';
            emphasis_color{r} = [0.9290 0.6940 0.1250];
        case 4% Left PPC
            emphasis_width{r} = 1;
            emphasis_style{r} = '-';
            emphasis_color{r} = [0.4940 0.1840 0.5560];
        case 5% Right M1
            emphasis_width{r} = 1;
            emphasis_style{r} = '--';
            emphasis_color{r} = [0 0.4470 0.7410];
        case 6% Right S1
            emphasis_width{r} = 1;
            emphasis_style{r} = '--';
            emphasis_color{r} = [0.8500 0.3250 0.0980];
        case 7% Right SMA
            emphasis_width{r} = 1;
            emphasis_style{r} = '--';
            emphasis_color{r} = [0.9290 0.6940 0.1250];
        case 8% Right PPC
            emphasis_width{r} = 1;
            emphasis_style{r} = '--';
            emphasis_color{r} = [0.4940 0.1840 0.5560];
    end% ROI switch
end

if scatter_plots == 1
    
    switch analysis_method
        case 'indiv'
            
            for subject_idx = 1 : num_subjects
                
                figure; hold on;
                current_ROI_vals = zeros(8, num_paradigms);
                
                % assign ROI-specific line details
                for r = 1 : 8
                    
                    current_ROI_vals =   squeeze( ROI_peak_vals(:, subject_idx, :) );
                    
                    % scatter/line plots
                    l = plot(current_ROI_vals(r, :), 'LineWidth', emphasis_width{r}, 'LineStyle', emphasis_style{r}, 'Color', emphasis_color{r} );
                    current_color(r, :) = get(l, 'Color');
                    %                             scatter(1:4, current_ROI_vals(r, :), 40, current_color, 'filled' );
                    
                end% ROI loop
                set(gcf, 'OuterPosition', [480 213 700 700])% [left bottom width height]

                legend(plaintext_ROIs, 'Location', 'b');
                
                for r = 1 : 8
                    scatter(1:num_paradigms, current_ROI_vals(r, :), 40, current_color(r, :), 'filled' );
                end
                
                % figure settings
                title([subject_list(subject_idx) 'ROI peaks']);
                xlim([0.5 2.5])
                curr_ylim = get(gca, 'ylim');
                ylim([0 curr_ylim(2)]);
                xlabel('Enrichment Condition')
                ylabel('Peak T-val')
                
                x = refline(0, 3);
                set(x, 'LineStyle', ':')
                set(x, 'Color', 'k')
                
                condition_ticks = get(gca, 'XTickLabels');
                display_conditions = {'', 'Attempted', '', 'Imagined'};
                set(gca, 'XTickLabels', display_conditions)
                

                
                
            end% subject loop
            
            
        case 'mean'
            
            for group_idx = 1 : 2
                
                current_group_means =       group_peak_means{group_idx};
                
                figure; hold on;
                
                % assign ROI-specific line details
                for r = 1 : 8
                    
                    % line plots
                    l = plot(current_group_means(r, :), 'LineWidth', emphasis_width{r}, 'LineStyle', emphasis_style{r}, 'Color', emphasis_color{r} );
                    current_color(r, :) = get(l, 'Color');
                    
                end% ROI loop
                set(gcf, 'OuterPosition', [480 213 700 700])% [left bottom width height]
                
                legend(plaintext_ROIs, 'Location', 'best');
                
                % scatter plots
                for r = 1 : 8
                    scatter(1:num_paradigms, current_group_means(r, :), 40, current_color(r, :), 'filled' );
                end
                
                % figure settings
                title( [group_names{group_idx} ' ROI peaks (n=' num2str( num_group_subjects(group_idx) ) ')' ] );
                xlim([0.5 2.5])
                
                curr_ylim = get(gca, 'ylim');
                group_ylims(group_idx, :) = curr_ylim;
                if max(group_ylims(:, 2)) > max(curr_ylim)
                    ylim([0 max(group_ylims(:, 2)) ] );
                else
                    ylim([0 curr_ylim(2)]);
                end
                
                xlabel('Enrichment Condition')
                ylabel('Peak T-val')
                
                x = refline(0, 3);
                set(x, 'LineStyle', ':')
                set(x, 'Color', 'k')
                
                condition_ticks = get(gca, 'XTickLabels');
                display_conditions = {'', 'Attempted', '', 'Imagined'};
                set(gca, 'XTickLabels', display_conditions)
                

            end
            
            
    end% analysis method switch
    
end% scatter plot flag



%% Bar plots to compare group stats

if bar_plots == 1
    
    % organize data into clusters of [AB SCI __ ] for Plot_Bars
    num_clusters =          (num_ROI) * (num_paradigms + 1);
    num_real_clusters =     (num_ROI) * (num_paradigms);
    
    group_slots(1, :) =    1:(num_paradigms + 1):num_clusters;
    group_slots(2, :) =    2:(num_paradigms + 1):num_clusters;
    group_slots(3, :) =    (num_paradigms + 1):(num_paradigms + 1):num_clusters;
    
    bar_colors = zeros(num_real_clusters, 3);
    

    for c = 1 : num_paradigms
        
        bar_grouped_peakval_data =  cell(1, num_clusters);
        bar_grouped_sigcount_data =  cell(1, num_clusters);

        bar_color_idx =     1;
        
        for cluster_idx = 1 : num_clusters
            
            [group_idx, ROI_idx] =   find(group_slots == cluster_idx);
            
            if group_idx == 1
                bar_colors(bar_color_idx, :) =      [0.5 0.5 0.5];%able-bodied = gray
                bar_color_idx =                     bar_color_idx + 1;
            end
            if group_idx == 2
                bar_colors(bar_color_idx, :) =      [1 0 0];%SCI = red
                bar_color_idx =                     bar_color_idx + 1;
            end

            
            if group_idx ~= 3
                
                % peak vals
                peakval_cluster_data =          group_data{group_idx}.peak_vals(ROI_idx, :, c);
                bar_grouped_peakval_data{cluster_idx} = peakval_cluster_data;
                
                % sig count
                sigcount_cluster_data =          group_data{group_idx}.sig_count(ROI_idx, :, c);
                bar_grouped_sigcount_data{cluster_idx} = sigcount_cluster_data;
                
            end% data insertion
            
        end% cluster loop
        
        % peak val plots
        Plot_Bars({}, bar_grouped_peakval_data, 'Color', bar_colors)
        title_string = sprintf('%s \n Group comparisons \n AB n=%d, SCI n=%d', plaintext_paradigms{c}, num_group_subjects(1), num_group_subjects(2));
        title(title_string)
        legend('AB', 'SCI', 'Location', 'northeast')
        ylabel('Peak T value')
        xlabel('ROI')
        
        new_tick_vals = group_slots(1, :) + 0.5;
        set(gca, 'XTick', new_tick_vals);
        set(gca, 'XTickLabel', plaintext_ROIs);
        set(gcf, 'OuterPosition', [480 213 1142 778])% [left bottom width height]
        
        x = refline(0, 3);
        set(x, 'LineStyle', '--')
        set(x, 'Color', 'b')
        
        
        for r = 1 : 8
            sig_groups{r} = group_slots([1 2], r)';
        end
        
%         sigstar(sig_groups, plot_sigs{2}(:, c))%peakval_sig_tests{1} = ranksum, {2} = ttest2
        sigstar(sig_groups, peakval_sig_tests{2}(:, c))%peakval_sig_tests{1} = ranksum, {2} = ttest2
        
        limits(c, :) =  get(gca, 'YLim');
        max_lim =       max(limits(:, 2));
        if max_lim > max(limits(c, :))
            set(gca, 'YLim', [0 max_lim])
        end
        
        y = line([12 12], [0 max_lim]);
        
        
        
        
        
        
        % sig count plots
        Plot_Bars({}, bar_grouped_sigcount_data, 'Color', bar_colors)
        title_string = sprintf('%s \n Group comparisons \n AB n=%d, SCI n=%d', plaintext_paradigms{c}, num_group_subjects(1), num_group_subjects(2));
        title(title_string)
        legend('AB', 'SCI', 'Location', 'northeast')
        ylabel('% ROI sig')
        xlabel('ROI')
        
        new_tick_vals = group_slots(1, :) + 0.5;
        set(gca, 'XTick', new_tick_vals);
        set(gca, 'XTickLabel', plaintext_ROIs);
        set(gcf, 'OuterPosition', [480 213 1142 778])% [left bottom width height]
        
        
        for r = 1 : 8
            sig_groups{r} = group_slots([1 2], r)';
        end
        
%         sigstar(sig_groups, plot_sigs{2}(:, c))%peakval_sig_tests{1} = ranksum, {2} = ttest2
        sigstar(sig_groups, sigcount_sig_tests{1}(:, c))%peakval_sig_tests{1} = ranksum, {2} = ttest2
        
        count_limits(c, :) =  get(gca, 'YLim');
        count_max_lim =       max(count_limits(:, 2));
        if count_max_lim > max(count_limits(c, :))
            set(gca, 'YLim', [0 count_max_lim])
        end
        
        y = line([12 12], [0 count_max_lim]);

    end% condition loop
    
end% bar plots


%% 




























