% 2019-07-17 Dylan Royston
%
% Updated shell script to create group-level maps using beta-value contrasts
%
%
% Block outline
% 1: Create new group-level mean images for specified task
%
%
%
%% Initialize data to load

clear; clc;

% paths to individual subject files (source_data_dir) and group-level repository (active_data_dir)
% active_data_dir =   '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/%s/BETAS/%s';

if isunix
% multi-subject
source_data_dir =   '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/%s/NIFTI/%s';
% active_data_dir =   '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/group_level';
% ROI_path_list =     {'/home/dar147/Documents/GITLOCAL/bci_analysis/Dylan/Neuroimaging/ROI/marsbar-aal-0.2_NIFTIS'};
else
    source_data_dir =   'V:\CovertMapping\data_generated\SUBJECT_DATA_STORAGE\%s\NIFTI\%s';
    active_data_dir =   'V:\CovertMapping\data_generated\SUBJECT_DATA_STORAGE\new_group_level';
    ROI_path_list =     {'V:\CovertMapping\data_generated\CM_Analysis_Tools\ROI\marsbar-aal-0.2_NIFTIS'};
end

% flag list to set which blocks to execute
block_flags.create_new_images =   0;% calculate new group image from individual subjects

ROI_name_list =     {'MNI_Precentral_L_roi.nii', 'MNI_Postcentral_L_roi.nii'};

ROI_plaintext_list = {'M1', 'S1'};

movement_list =     {'Wrist', 'Hand', 'Fingers'};

%% 1: Concatenate images and create group-levels for each task/condition
% (it would be nice to store images instead of re-loading, but too memory intensive)

% TO DO: finish loop structure to allow creation of multiple images


if block_flags.create_new_images == 1
    
    % 2019-08-07 subject lists (including all subjects for "mismatched" sets)
    AB_all =                    {'CMC01', 'CMC03', 'CMC04', 'CMC05', 'CMC07', 'CMC09', 'CMC10', 'CMC11', 'CMC12', 'CMC13',...
        'CMC14', 'CMC15', 'CMC17', 'CMC18', 'CMC20', 'CMC22', 'CMC23', 'CMC24', 'CMC26', 'CMC27'};
    
    
    
    
    %%%%%%%%%%%%%%%%%% previous %%%%%%%%%%%%
    
    % hard-coding for different subject subsets
    % AB_motor_complete =     {'CMC01', 'CMC03', 'CMC04', 'CMC05', 'CMC07', 'CMC09', 'CMC10', 'CMC11', 'CMC12', 'CMC13', 'CMC14',...
    %     'CMC15', 'CMC17', 'CMC18', 'CMC20', 'CMC22', 'CMC23', 'CMC24', 'CMC26', 'CMC27'};
    
%         AB_motor_complete_hand =    {'CMC01', 'CMC03', 'CMC04', 'CMC05', 'CMC07', 'CMC09', 'CMC23', 'CMC24', 'CMC26'};
%         AB_motor_complete_ref =     {'CMC10', 'CMC11', 'CMC12', 'CMC13', 'CMC14', 'CMC15', 'CMC17', 'CMC18', 'CMC20', 'CMC22', 'CMC27'};
    
            % used for sensory
%         AB_motor_complete_ref =     {'CMC10', 'CMC12', 'CMC13', 'CMC14', 'CMC15', 'CMC17', 'CMC18', 'CMC20', 'CMC22'};

    
    %     AB_sens_complete_hand =      {'CMC01', 'CMC03', 'CMC04', 'CMC05', 'CMC06', 'CMC07', 'CMC09', 'CMC23', 'CMC24', 'CMC26'};
    %     AB_sens_complete_ref =      {'CMC10', 'CMC12', 'CMC13', 'CMC14', 'CMC15', 'CMC17', 'CMC18', 'CMC19', 'CMC20', 'CMC22'};
    
    
%     SCI_motor_complete =        {'CMS01', 'CMS02', 'CMS03', 'CMS04', 'CMS06', 'CMS07', 'CMS09', 'CMS13'};
    % Omitted CMS10, bad coregistration/normalization? blank patch on S1
    
    % used for sensory
%         SCI_motor_complete =        {'CMS01', 'CMS02', 'CMS03', 'CMS04', 'CMS07', 'CMS09', 'CMS13'};
    
    %     smalltest =           {'CMC10', 'CMC11'};
    
    % task data to load (task_list = which task, con_list = which conditions)
    subject_list =      AB_all;
    task_list =         {'Motor_overt'};
    cond_list =          [1, 2, 3, 4, 5];
    
%         task_list =         {'Motor_covert_wrist'};
%         cond_list =         [1, 2, 3, 4];

%         task_list =         {'Sensory_overt_wrist'};
%         cond_list =         [1];
    
    num_subjects =      length(subject_list);
    num_tasks =         length(task_list);
    num_cons =          length(cond_list);
    
    
    curr_task =                 task_list{1};
    curr_conds =                cond_list;
    
    
    % define input structure for image-loading function
    input_struct.load_path =    source_data_dir;
    input_struct.save_path =    active_data_dir;
    input_struct.set_handle =   'AB_all_MO';% AB_motor_complete_ref_MO
    input_struct.subjects =     subject_list;
    input_struct.task =         curr_task;
    input_struct.conds =        curr_conds;
    
    func_flags.return_indiv =   1;
    func_flags.save_new =       1;
    input_struct.flags =        func_flags;
    
    output_struct =             FUNC_create_group_beta_images(input_struct);
    
    
    
    
end% IF block_flags.create_new_images


%% 2: Extract volumetric voxel data from group-level T-maps

disp('*** EXTRACTING VOLUMETRIC DATA ***');

clearvars ROI_stats

set_list = 'AB_all_MO';
% set_list = 'all';
% set_list = 'type_sensory';
% set_list = 'type_motor';

% if set_list is 'all', load all extant sets for processing
switch set_list
    case 'all'
    
    set_dir_contents =  dir(active_data_dir);
    set_dir_names =     {set_dir_contents(3:end).name};
    
    is_set =            FUNC_find_string_in_cell(set_dir_names, '_');
    
    set_list =          set_dir_names(is_set);
    case 'type_sensory'
            
    set_dir_contents =  dir(active_data_dir);
    set_dir_names =     {set_dir_contents(3:end).name};
    
    is_set =            FUNC_find_string_in_cell(set_dir_names, '_S');
        
    set_list =          set_dir_names(is_set);
    
    case 'type_motor'
            
    set_dir_contents =  dir(active_data_dir);
    set_dir_names =     {set_dir_contents(3:end).name};
    
    is_set =            FUNC_find_string_in_cell(set_dir_names, '_M');
        
    set_list =          set_dir_names(is_set);
        
    otherwise
        
        temp = set_list;
        clearvars set_list;
        set_list{1} = temp;
        clearvars temp;
    
    
end% IF strmatch


%%


% load group Tmaps
for set_idx = 1 : length(set_list)
    
    set_name =      set_list{set_idx};
    
    disp(['*** PROCESSING SET: ' set_name ' ***']);
    
    
    % load T values
    clearvars output_data
    map_type = 'T';
    output_data =    FUNC_load_data_from_group_images(active_data_dir, set_name, ROI_path_list{1}, ROI_name_list, map_type);
    ROI_stats{1, set_idx} = output_data;
    
    % load B values
    clearvars output_data
    map_type = 'B';
    output_data =    FUNC_load_data_from_group_images(active_data_dir, set_name, ROI_path_list{1}, ROI_name_list, map_type);
    ROI_stats{2, set_idx} = output_data;
    
end% FOR set_idx

%%
% 
% % load group Tmaps
% for set_idx = 1 : length(set_list)
%     
%     set_name =      set_list{set_idx};
%     
%     disp(['*** PROCESSING SET: ' set_name ' ***']);
%     
%     % load all conditions within a set by finding all subfolders in a set (should only be condition containers)
%     set_path =      fullfile(active_data_dir, set_name);
%     set_contents =  dir(set_path);
%     set_filenames = {set_contents(3:end).name};
%     cond_names =    set_filenames( isfolder( fullfile(set_path, set_filenames) ) );
%     
%     for cond_idx = 1 : length(cond_names)
%         
%         disp(num2str(cond_idx));
%         
%         % load T contrast image
%         cond_path =     fullfile( set_path, cond_names{cond_idx} );
%         cond_files =    dir(cond_path);
%         cond_filenames = {cond_files(3:end).name};
%         
%         cond_T_file =   cond_filenames{ FUNC_find_string_in_cell(cond_filenames, '_T.nii') };
%         cond_T_path =   fullfile(cond_path, cond_T_file);
%         
%         cond_nii =      load_untouch_nii(cond_T_path);
%         cond_img =      cond_nii.img;
%         
% %         set_IMGs(:, :, :, cond_idx) = cond_img;
%         
%         clearvars cond_nii cond_img input_struct
%         
%         
%         % test, load p-val for FDR calc
%         %         pIMG_path =                 strrep(cond_T_path, '_T.nii', '_P.nii');
%         %         p_nii =                     load_untouch_nii(pIMG_path);
%         %         p_img =                     p_nii.img;
%         %         real_Ps =                   find(~isnan(p_img));
%         %         list_Ps =                   p_img(real_Ps);
%         
%         % calculate FDR-corrected significance threshold and voxels (takes a while)
%         % formula might look like this? not correct currently (probably, doesn't match TKsurfer)
%         %         [sig_inds, thresh] =      FDR(list_Ps, 0.05);
%         %         real_Tvals =              cond_img(real_Ps);
%         %         sig_Tvals =               (real_Tvals(sig_inds) );
%         %         test_thresh =             mean(sig_Tvals>0);
%         
%         % extract ROI statistics from group image
%         input_struct.image_path =   cond_T_path;
%         input_struct.ROI_path =     ROI_path_list{1};
%         input_struct.ROI_names =    ROI_name_list;
%         
%         current_voxel_data =        FUNC_extract_fMRI_ROI_voxels(input_struct);
%         
%         
%         ROI_stats(set_idx, cond_idx, :) =         current_voxel_data;
%         
%         
% %         optional, plot extracted voxel data
% %         combine values from M1/S1 for plotting
% 
% %         test_vals =         vertcat(current_voxel_data(1).active_vals, current_voxel_data(2).active_vals);
% %         test_locs =         vertcat(current_voxel_data(1).active_coords, current_voxel_data(2).active_coords);
% %         
% %         clearvars input_struct
% %         input_struct.point_vals =   test_vals;
% %         input_struct.point_locs =   test_locs;
% %         input_struct.cmap =         'jet';
% %         input_struct.clim =         [2 6];
% %         FUNC_plot_3D_fMRI_data(input_struct);
%         
%     end% FOR cond_idx
%     
%     
% end% FOR set_idx

disp('*** DONE ***');

%% Calculate target stats (redundant to loop above, but separated for clarity/debugging)

disp('*** CALCULATING TARGET STATS ***');

% T-value to use as significance threshold
curr_thresh = 2;

overt_counter = 1;
clearvars overt_stats overt_sets

for set_idx = 1 : length(set_list)
    
    for cond_idx = 1 : size(ROI_stats, 2)
        
        for roi_idx = 1 : length(ROI_name_list)
            
            curr_stats =        squeeze( ROI_stats(set_idx, cond_idx, roi_idx) );
            
            sig_voxel_idx =     find(curr_stats.active_vals > curr_thresh);
            
            ROI_stats(set_idx, cond_idx, roi_idx).sig_voxel_idx =     sig_voxel_idx;
            ROI_stats(set_idx, cond_idx, roi_idx).sig_voxel_vals =    curr_stats.active_vals(sig_voxel_idx);
            ROI_stats(set_idx, cond_idx, roi_idx).sig_voxel_coords =  curr_stats.active_coords(sig_voxel_idx);
            
        end% FOR roi_idx
        
    end% FOR cond_idx
    
    % separate Overt stats for reference plotting against Covert conditions
    if ~isempty( strfind( set_list{set_idx}, '_MO') )
        overt_stat_hold =                   squeeze( ROI_stats(set_idx, :, :) );
        
        overt_stats(overt_counter, :, :) =  overt_stat_hold;
        overt_sets(overt_counter) =         set_list(set_idx);
        
        overt_counter = overt_counter + 1;
    end
    
    % separate Sensory Overt stats for reference plotting against Covert conditions
    if ~isempty( strfind( set_list{set_idx}, '_SO') )
        overt_stat_hold =                   squeeze( ROI_stats(set_idx, :, :) );
        
        overt_stats(overt_counter, :, :) =  overt_stat_hold;
        overt_sets(overt_counter) =         set_list(set_idx);
        
        overt_counter = overt_counter + 1;
    end
    
    
    
end% FOR set_idx

disp('*** DONE ***');

%% Plot target stats (test/debugging, single set (group-task) with both ROIs)
% currently used to plot Overt condition data

subplot_order =     [1 3 2 4];

for set_idx = 1 : length(set_list)
    
    
    curr_setname =  set_list{set_idx};
    is_overt = ~isempty( strfind(curr_setname, '_MO') );
    
    if is_overt
        
        counter =           1;
        figure; hold on;
        
        for roi_idx = 1 : length(ROI_name_list)
            
            % plot volume
            %         clearvars vals_to_plot
            axes_handles(counter) = subplot(length(ROI_name_list), 2, subplot_order(counter) );
            counter = counter + 1;
            
            for cond_idx = 1 : 4
                
                curr_stats =        ROI_stats(set_idx, cond_idx, roi_idx);
                sig_vals =          curr_stats.sig_voxel_vals;
                sig_vols(cond_idx) = length(sig_vals);
                %             vals_to_plot{cond_idx} = sig_vals;
                
            end% FOR cond_idx
            
            bar(sig_vols);
            ylabel('Sig vol (#)');
            xlabel('Condition #');
            title([ROI_plaintext_list{roi_idx} ' volume']);
            
            
            
            % plot peak T
            clearvars vals_to_plot
            axes_handles(counter) = subplot(length(ROI_name_list), 2, subplot_order(counter));
            counter = counter + 1;
            
            for cond_idx = 1 : 4
                
                curr_stats =        ROI_stats(set_idx, cond_idx, roi_idx);
                peak_vals(cond_idx) = max(curr_stats.active_vals);
                
            end% FOR cond_idx
            
            bar(peak_vals);
            ylabel('Peak T');
            xlabel('Condition #');
            title([ROI_plaintext_list{roi_idx} ' peak']);
            
        end% FOR roi_idx
        
        set(gcf, 'Position', [2036 349 755 553] );
        title_string = strrep(set_list{set_idx}, '_', ' ');
        suplabel(title_string, 't');
        
        
        top_limit = max( [axes_handles([1 3]).YLim] );
        set(axes_handles(1), 'YLim', [0 top_limit]);
        set(axes_handles(3), 'YLim', [0 top_limit]);
        
        top_limit = max( [axes_handles([2 4]).YLim] );
        set(axes_handles(2), 'YLim', [0 top_limit]);
        set(axes_handles(4), 'YLim', [0 top_limit]);
        
    end
    
end% FOR set_idx

%% Enrichment plotting (same as above, but with overt stats paired to each covert

disp('*** PLOTTING TARGET STATS ***')

subplot_order =     [1 3 2 4];

for set_idx = 1 : length(set_list)
    
    curr_setname =  set_list{set_idx};
    
    disp(curr_setname);
    
    is_covert_M = ~isempty( strfind(curr_setname, '_MC') );
    
    is_covert_S = ~isempty( strfind(curr_setname, '_SC') );
    
    % only plot Covert conditions
    if is_covert_M || is_covert_S
        
        if is_covert_M
            curr_type = 'M';
        end
        if is_covert_S
            curr_type = 'S';
        end
        
        
        % pull matched Overt data for reference plotting
        setname_parts =    strsplit(curr_setname, '_');
        
        is_AB =            strcmp(setname_parts{1}, 'AB');
        if is_AB
            group_label =      [setname_parts{1} '_' setname_parts{2} '_' setname_parts{3} '_' setname_parts{4}];
            move_type_flag =    setname_parts{5}(3);
        else
            group_label =      [setname_parts{1} '_' setname_parts{2} '_' setname_parts{3}];
            move_type_flag =    setname_parts{4}(3);
        end
            
        % extract overt stats    
        overt_match =      FUNC_find_string_in_cell(overt_sets, [group_label '_' curr_type]);
        matched_overt_stats = squeeze( overt_stats(overt_match, :, :) );
        matched_overt_labels = overt_sets(overt_match);
        
        % extract which movement this is
        move_type_idx =     FUNC_find_string_in_cell(movement_list, move_type_flag);
        
        counter =           1;
        figure;
        
        for roi_idx = 1 : length(ROI_name_list)
            
            % plot volume
            axes_handles(counter) = subplot(length(ROI_name_list), 2, subplot_order(counter) ); hold on
            counter = counter + 1;
            
            for cond_idx = 1 : 4
                
                curr_stats =        ROI_stats(set_idx, cond_idx, roi_idx);
                sig_vals =          curr_stats.sig_voxel_vals;
                sig_vols(cond_idx) = length(sig_vals);
                %             vals_to_plot{cond_idx} = sig_vals;
                
            end% FOR cond_idx
            
            switch curr_type
                case 'M'
                    % extract specific Overt stats to plot (is offest by +1 for cond1 (lips))
                    overt_vol =         length( matched_overt_stats(move_type_idx+1, roi_idx).sig_voxel_vals );
                    
                case 'S'
                    %             % sensory overt
                    move_type_letter =      movement_list{move_type_idx}(1);
                    curr_overt_target =     FUNC_find_string_in_cell(matched_overt_labels, ['_SO' move_type_letter]);
                    %
                    overt_vol =         length( matched_overt_stats(curr_overt_target, 1, roi_idx).sig_voxel_vals );
            end
            
            bar(sig_vols);
            
            line([0.5 4.5], [overt_vol overt_vol], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2);
                        
            ylabel('Sig vol (#)');
            xlabel('Condition #');
            title([ROI_plaintext_list{roi_idx} ' volume']);
            
            
            
            % plot peak T
            axes_handles(counter) = subplot(length(ROI_name_list), 2, subplot_order(counter)); hold on;
            counter = counter + 1;
            
            for cond_idx = 1 : 4
                
                curr_stats =        ROI_stats(set_idx, cond_idx, roi_idx);
%                 peak_vals(cond_idx) = max(curr_stats.active_vals);

                [sorted_vals, sort_idx] = sort( curr_stats.sig_voxel_vals, 'descend');
                peak_vals(cond_idx) =   median(sorted_vals(1:10));
                
            end% FOR cond_idx
            
            switch curr_type
                case 'M'
                    [sorted_vals, sort_idx] = sort(matched_overt_stats(move_type_idx+1, roi_idx).sig_voxel_vals, 'descend');
                    overt_peak =        median( sorted_vals(1:10) );
                    
%                     overt_peak =         max( matched_overt_stats(move_type_idx+1, roi_idx).sig_voxel_vals );
                    
                case 'S'
                    % sensory overt
                    move_type_letter =      movement_list{move_type_idx}(1);
                    curr_overt_target =     FUNC_find_string_in_cell(matched_overt_labels, ['_SO' move_type_letter]);
                    
%                     overt_peak =         max( matched_overt_stats(curr_overt_target, 1, roi_idx).sig_voxel_vals );
                    [sorted_vals, sort_idx] = sort( matched_overt_stats(curr_overt_target, 1, roi_idx).sig_voxel_vals, 'descend');
                    overt_peak =            median( sorted_vals(1:10) );
            end
                        
            bar(peak_vals);
            
            line([0.5 4.5], [overt_peak overt_peak], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2);

            ylabel('Peak T');
            xlabel('Condition #');
            title([ROI_plaintext_list{roi_idx} ' peak']);
            
        end% FOR roi_idx
        
        set(gcf, 'Position', [2036 349 755 553] );
        title_string = strrep(set_list{set_idx}, '_', ' ');
        suplabel(title_string, 't');
        
        top_limit = max( [axes_handles([1 3]).YLim] );
        set(axes_handles(1), 'YLim', [0 top_limit]);
        set(axes_handles(3), 'YLim', [0 top_limit]);
        
        top_limit = max( [axes_handles([2 4]).YLim] );
        set(axes_handles(2), 'YLim', [0 top_limit]);
        set(axes_handles(4), 'YLim', [0 top_limit]);
        
    end% IF is_covert
    
end% FOR set_idx

%% Plot all stats on compressed figure
% volume

set_tag_list =      {'MCW', 'MCH', 'MCF', 'SCW', 'SCF'};

num_cons =          4;

group_colors =      {'k', 'b', 'r'};

group_labels =      {'AB hand', 'AB ref', 'SCI'};

MO_move_order =     {'W', 'H', 'F'};

figure; 

for set_idx = 1 : length(set_tag_list)
    
    current_move_label =     set_tag_list{set_idx};
    
    target_set_idx =       FUNC_find_string_in_cell(set_list, set_tag_list{set_idx});
    target_set_names =      set_list(target_set_idx);
    
    target_stats =          ROI_stats(target_set_idx, :, :);
    
    
    subplot(2, 3, set_idx); hold on;
    line([1 4], [0 0], 'LineWidth', 4, 'color', 'g' );

    for group_idx = 1 : 3
        
        set_name =          target_set_names{group_idx};
        
%         group_label =       strsplit( target_set_names{group_idx}, '_' );
        
        is_AB_h =           ~isempty(strfind(set_name, 'hand') );
        is_AB_r =           ~isempty(strfind(set_name, 'ref') );
        is_SCI =            ~isempty(strfind(set_name, 'SCI') );
        
        group_index =       find( [is_AB_h is_AB_r is_SCI] );
        
        
        % load overt stats
        switch group_idx
            case 1% AB_h
                target_set_group = 'AB_motor_complete_hand_';
            case 2
                target_set_group = 'AB_motor_complete_ref_';
            case 3
                target_set_group = 'SCI_motor_complete_';
        end

        cond_target =       current_move_label(3);
        
        switch current_move_label(1)
            case 'M'
                overt_set_name =        [target_set_group 'MO'];
                curr_overt_target =     FUNC_find_string_in_cell(set_list, overt_set_name);
                
                cond_idx =           FUNC_find_string_in_cell(MO_move_order, cond_target);
                
                curr_overt_stats =     squeeze( ROI_stats(curr_overt_target, cond_idx+1, :) );
                
            case 'S'
                
                overt_set_name =        [target_set_group 'SO' cond_target];
                curr_overt_target =     FUNC_find_string_in_cell(set_list, overt_set_name);
                                
                curr_overt_stats =     squeeze( ROI_stats(curr_overt_target, 1, :) );
        end
        
        
        for roi_idx = 1 : 2
            
            curr_stats =            {target_stats(group_idx, 1:num_cons, roi_idx).sig_voxel_vals};
            
            % only grabs non-empty data
            %             curr_stats =            curr_stats( not(cellfun(@isempty, curr_stats) ) );
            
            overt_vals =            curr_overt_stats(roi_idx).sig_voxel_vals;
            overt_vol =             length(overt_vals);
%             line([1 4], [overt_vol overt_vol], 'LineWidth', 4, 'LineStyle', '--', 'color', group_colors{group_idx} );

            
            % just plot values
            %             line([1 4], [overt_vol overt_vol], 'LineWidth', 4, 'LineStyle', '--', 'color', group_colors{group_idx} );
            %
            %             stats_to_plot =         cellfun(@length, curr_stats);
            %
            %             line_handle(group_idx) = line([1: length(stats_to_plot)], stats_to_plot, 'LineWidth', 4, 'Color', group_colors{group_index});
            %             scatter([1: length(stats_to_plot)], stats_to_plot, 200, group_colors{group_idx}, 'filled');
            
            
            
%             % subtract covert from overt
%             stats_to_plot =         cellfun(@length, curr_stats);
%             
%             new_covert_vals =       stats_to_plot - overt_vol;
%             
%             line_handle(group_idx) = line([1: length(new_covert_vals)], new_covert_vals, 'LineWidth', 4, 'Color', group_colors{group_index});
%             scatter([1: length(new_covert_vals)], new_covert_vals, 200, group_colors{group_idx}, 'filled');

            % subtract enrichments from simple
            stats_to_plot =         cellfun(@length, curr_stats);
            
            new_covert_vals =       stats_to_plot - stats_to_plot(1);
            
            switch roi_idx
                case 1
                    line_handle(group_idx) = line([1: length(new_covert_vals)], new_covert_vals, 'LineWidth', 4, 'Color', group_colors{group_index});
                    scatter([1: length(new_covert_vals)], new_covert_vals, 200, group_colors{group_idx}, 'filled');
                    
                case 2
                    line_handle(group_idx) = line([1: length(new_covert_vals)], new_covert_vals, 'LineWidth', 4, 'LineStyle', '--', 'Color', group_colors{group_index});
                    scatter([1: length(new_covert_vals)], new_covert_vals, 200, group_colors{group_idx}, 's', 'filled');
            end
%             bar( stats_to_plot)
            
        end% FOR roi_idx
        
    end% FOR group_idx
    
%     curr_lims = get(gca, 'ylim');
%     
%     set(gca, 'ylim', [0 curr_lims(2)]);
    
    xlim([0.5 4.5]);
    ylabel('Sig vol (#)');
    xlabel('Conditions');
    xticks(1:4);
    
%     graphic_objects =   findobj(gcf, 'type', 'line');
    
    legend(line_handle, group_labels, 'location', 'nw');
    
    title(set_tag_list{set_idx});
    
    
end





%% Plot all stats on compressed figure
% peaks

set_tag_list =      {'MCW', 'MCH', 'MCF', 'SCW', 'SCF'};

num_cons =          4;

group_colors =      {'k', 'b', 'r'};

group_labels =      {'AB hand', 'AB ref', 'SCI'};

MO_move_order =     {'W', 'H', 'F'};

figure; 

for set_idx = 1 : length(set_tag_list)
    
    current_move_label =     set_tag_list{set_idx};
    
    target_set_idx =       FUNC_find_string_in_cell(set_list, set_tag_list{set_idx});
    target_set_names =      set_list(target_set_idx);
    
    target_stats =          ROI_stats(target_set_idx, :, :);
    
    
    subplot(2, 3, set_idx); hold on;
    line([1 4], [0 0], 'LineWidth', 4, 'color', 'g' );

    for group_idx = 1 : 3
        
        set_name =          target_set_names{group_idx};
        
%         group_label =       strsplit( target_set_names{group_idx}, '_' );
        
        is_AB_h =           ~isempty(strfind(set_name, 'hand') );
        is_AB_r =           ~isempty(strfind(set_name, 'ref') );
        is_SCI =            ~isempty(strfind(set_name, 'SCI') );
        
        group_index =       find( [is_AB_h is_AB_r is_SCI] );
        
        
        % load overt stats
        switch group_idx
            case 1% AB_h
                target_set_group = 'AB_motor_complete_hand_';
            case 2
                target_set_group = 'AB_motor_complete_ref_';
            case 3
                target_set_group = 'SCI_motor_complete_';
        end

        cond_target =       current_move_label(3);
        
        switch current_move_label(1)
            case 'M'
                overt_set_name =        [target_set_group 'MO'];
                curr_overt_target =     FUNC_find_string_in_cell(set_list, overt_set_name);
                
                cond_idx =           FUNC_find_string_in_cell(MO_move_order, cond_target);
                
                curr_overt_stats =     squeeze( ROI_stats(curr_overt_target, cond_idx+1, :) );
                
            case 'S'
                
                overt_set_name =        [target_set_group 'SO' cond_target];
                curr_overt_target =     FUNC_find_string_in_cell(set_list, overt_set_name);
                                
                curr_overt_stats =     squeeze( ROI_stats(curr_overt_target, 1, :) );
        end
        
        
        for roi_idx = 1 : 2
            
            curr_stats =            {target_stats(group_idx, 1:num_cons, roi_idx).sig_voxel_vals};
            
            % only grabs non-empty data
            %             curr_stats =            curr_stats( not(cellfun(@isempty, curr_stats) ) );
            
            overt_vals =            curr_overt_stats(roi_idx).sig_voxel_vals;
            overt_vol =             length(overt_vals);
%             line([1 4], [overt_vol overt_vol], 'LineWidth', 4, 'LineStyle', '--', 'color', group_colors{group_idx} );

            
            % just plot values
            %             line([1 4], [overt_vol overt_vol], 'LineWidth', 4, 'LineStyle', '--', 'color', group_colors{group_idx} );
            %
            %             stats_to_plot =         cellfun(@length, curr_stats);
            %
            %             line_handle(group_idx) = line([1: length(stats_to_plot)], stats_to_plot, 'LineWidth', 4, 'Color', group_colors{group_index});
            %             scatter([1: length(stats_to_plot)], stats_to_plot, 200, group_colors{group_idx}, 'filled');
            
            
            
%             % subtract covert from overt
%             stats_to_plot =         cellfun(@length, curr_stats);
%             
%             new_covert_vals =       stats_to_plot - overt_vol;
%             
%             line_handle(group_idx) = line([1: length(new_covert_vals)], new_covert_vals, 'LineWidth', 4, 'Color', group_colors{group_index});
%             scatter([1: length(new_covert_vals)], new_covert_vals, 200, group_colors{group_idx}, 'filled');

            % subtract enrichments from simple
%             stats_to_plot =         cellfun(@length, curr_stats);
            for cond_idx = 1 : 4
                curr_numbers =      curr_stats{cond_idx};
                [sorted_vals, sort_idx] = sort(curr_numbers, 'descend');
                
                stats_to_plot(cond_idx) = median(sorted_vals(1:10) );
                
            end
            
            new_covert_vals =       stats_to_plot - stats_to_plot(1);

            switch roi_idx
                case 1
                    line_handle(group_idx) = line([1: length(new_covert_vals)], new_covert_vals, 'LineWidth', 4, 'Color', group_colors{group_index});
                    scatter([1: length(new_covert_vals)], new_covert_vals, 200, group_colors{group_idx}, 'filled');
                    
                case 2
                    line_handle(group_idx) = line([1: length(new_covert_vals)], new_covert_vals, 'LineWidth', 4, 'LineStyle', '--', 'Color', group_colors{group_index});
                    scatter([1: length(new_covert_vals)], new_covert_vals, 200, group_colors{group_idx}, 's', 'filled');
            end
                    
%             bar( stats_to_plot)
            
        end% FOR roi_idx
        
    end% FOR group_idx
    
%     curr_lims = get(gca, 'ylim');
%     
%     set(gca, 'ylim', [0 curr_lims(2)]);
    
    xlim([0.5 4.5]);
    ylabel('Peak T val');
    xlabel('Conditions');
    xticks(1:4);
    
%     graphic_objects =   findobj(gcf, 'type', 'line');
    
    legend(line_handle, group_labels, 'location', 'nw');
    
    title(set_tag_list{set_idx});
    
    
end



%% Plot individual subject quantifications

disp('*** PULLING INDIVIDUAL SUBJECT VALUES ***');

covert_M_sets = FUNC_find_string_in_cell(set_list, 'MC');
covert_S_sets = FUNC_find_string_in_cell(set_list, 'SC');

all_covert_sets = set_list( sort([covert_M_sets covert_S_sets], 'ascend') );

set_line = {'MCW', 'MCH', 'MCF', 'SCW', 'SCF'};
task_line = {'Motor_covert_wrist', 'Motor_covert_hand', 'Motor_covert_fingers', 'Sensory_covert_wrist', 'Sensory_covert_fingers'};

clearvars IS_ROI_stats

for set_idx = 1 : length(all_covert_sets)
    
    disp(all_covert_sets{set_idx});
    
    % identify task name
    set_labels =                 strsplit(all_covert_sets{set_idx}, '_');
    task_flag =                 set_labels{end};
    set_task_idx =              FUNC_find_string_in_cell(set_line, task_flag);
    task_name =                 task_line{set_task_idx};
    
    % identify subject list for given set
    curr_set_subj_path =        fullfile(active_data_dir, all_covert_sets{set_idx}, 'con_1', 'indiv_subjects');
    set_subj_files =            dir(curr_set_subj_path);
    set_subj_names =            {set_subj_files(3:end).name};
    
    clearvars actual_id
    for idx = 1 : length(set_subj_names)
        curr_string =               set_subj_names{idx};
        actual_id{idx} =         curr_string(1:5);
    end
        
    unique_ids =        unique(actual_id);
    
    for subj_idx = 1 : length(unique_ids)
        
        subject_names =             set_subj_names{subj_idx};
        curr_name =                 strsplit(subject_names, '_');
        curr_ID =                   curr_name{1};
        
        disp(curr_ID);
        
        raw_subj_path =             sprintf(source_data_dir, curr_ID, task_name);
        
        for cond_idx = 1 : 4
            cond_path =                 fullfile(raw_subj_path, ['spmT_000' num2str(cond_idx) '.nii']);
            
            
            % extract ROI statistics from individual subject image
            clearvars input_struct
            input_struct.image_path =   cond_path;
            input_struct.ROI_path =     ROI_path_list{1};
            input_struct.ROI_names =    ROI_name_list;
            
            current_voxel_data =        FUNC_extract_fMRI_ROI_voxels(input_struct);
            
            for roi_idx = 1 : 2
                
                curr_active_vals =            current_voxel_data(roi_idx).active_vals;
                curr_active_locs =            current_voxel_data(roi_idx).active_coords;

                sig_idx =                     find(curr_active_vals > 2);
                
                sig_vals =                    curr_active_vals(sig_idx);
                sig_locs =                    curr_active_locs(sig_idx, :);
                
                IS_ROI_stats(set_idx, subj_idx, cond_idx, roi_idx).active_vals =       curr_active_vals;
                IS_ROI_stats(set_idx, subj_idx, cond_idx, roi_idx).active_locs =       curr_active_locs;
                IS_ROI_stats(set_idx, subj_idx, cond_idx, roi_idx).sig_vals =         sig_vals;
                IS_ROI_stats(set_idx, subj_idx, cond_idx, roi_idx).sig_locs =         sig_locs;
                
            end% FOR roi_idx
            
        end% FOR cond_idx
        
    end% FOR subj_idx
    
    
    
end


%%

for set_idx = 1 : length(all_covert_sets)

    curr_set_subj_path =        fullfile(active_data_dir, all_covert_sets{set_idx}, 'con_1', 'indiv_subjects');

    set_subj_contents =         dir(curr_set_subj_path);
    
    set_subject_list =          {set_subj_contents(3:end).name};
    
    num_subjects =              length(set_subject_list);
    

    
    cond_colorscale = parula(4);
    
    figure; hold on;
    
    
    for cond_idx = 1 : 4
        
        clearvars current_values curr_vols temp

        current_values(1, :) = {IS_ROI_stats(set_idx, 1:num_subjects, cond_idx, 1).sig_vals};
        current_values(2, :) = {IS_ROI_stats(set_idx, 1:num_subjects, cond_idx, 2).sig_vals};
        
%         blanks = not( cellfun(@isempty, currrent_values) );
        
%         temp(1, :) = current_values(1, blanks(1, :) );
%         temp(2, :) = current_values(2, blanrks(2, :) );
        
%         current_values = temp;
        
        num_subjs =     length(current_values);
        
        curr_vols =    cellfun(@length, current_values );
        
        x_val =         repmat(cond_idx-0.1, 1, length(curr_vols) );
        scatter(x_val ,curr_vols(1, :), 100, cond_colorscale(cond_idx, :), 'filled');
        
        x_val =         repmat(cond_idx+0.1, 1, length(curr_vols) );
        scatter(x_val ,curr_vols(2, :), 100, cond_colorscale(cond_idx, :), 's', 'filled');
            
        [zero_r, zero_c] =     find(curr_vols == 0);
        
        text(cond_idx, -200, [num2str(num_subjs - length(zero_c) ) '/' num2str(num_subjs) ], 'HorizontalAlignment', 'center' );
        
    end
    
    line([0.5 4.5], [0 0], 'Color', 'k');
    
    xlim([0.5 4.5]);
    
    curr_height = get(gca, 'YLim');
    set(gca, 'YLim', [-300 curr_height(2)]);
    
    ylabel('Sig vol');
    xticks(1:4);
    
    title(strrep(all_covert_sets{set_idx}, '_', ' ') );
    






end

