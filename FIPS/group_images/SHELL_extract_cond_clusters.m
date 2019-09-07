% 2019-08-12 Dylan Royston
%
% Side version of SHELL_updated_CM_analysis, focused on making/quantifying new clusters for each condition
%
%
% Pulls data from both group-level images (can also create new images)
%
% Currently hard-coding as a script to produce results, should come back and functionalize for smoother operations
%
%
% new image calculation moved to SCRIPT_make_specific_group_CM_images
% manual move-hub calculation moved to SCRIPT_make_group_move_hub
%
%
%% Initialize data to load

clear; clc;

if isunix
    % paths to individual subject files (source_data_dir) and group-level repository (active_data_dir)
    source_data_dir =   '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/%s/NIFTI/%s';
    % active_data_dir =   '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/%s/BETAS/%s';
    % multi-subject
    active_data_dir =   '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/new_group_level';
    ROI_path_list =     {'/home/dar147/Documents/GITLOCAL/bci_analysis/Dylan/Neuroimaging/ROI/marsbar-aal-0.2_NIFTIS'};
else
    source_data_dir =   '\\192.168.0.227\VAShare\CovertMapping\data_generated\SUBJECT_DATA_STORAGE\%s\NIFTI\%s';
    active_data_dir =   '\\192.168.0.227\VAShare\CovertMapping\data_generated\SUBJECT_DATA_STORAGE\new_group_level';
    ROI_path_list =     {'C:\GIT\bci_analysis\Dylan\Neuroimaging\ROI\marsbar-aal-0.2_NIFTIS'};
end
ROI_name_list =     {'MNI_Precentral_L_roi.nii', 'MNI_Postcentral_L_roi.nii'};

ROI_plaintext_list = {'M1', 'S1'};

movement_list =     {'Wrist', 'Hand', 'Fingers'};

cond_names =        {'Simple', 'Goal', 'Audio', 'Stim'};

% path to previously-saved hub coordinates
hub_path =          fullfile(active_data_dir, 'AB_all_MO', 'AB_all_move_hub_locs.mat');

set_list = 'AB_all_MO';


%% Extract T-val and beta data from group condition files


disp('*** EXTRACTING VOLUMETRIC DATA ***');

clearvars ROI_stats

set_list = 'AB_all_MO';
% set_list = 'all';
% set_list = 'type_sensory';
% set_list = 'type_motor';
% set_list =  'type_MCF';
% set_list =  'type_MCH';
% set_list =  'type_MCW';

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
        
    case 'type_MCF'
        
        set_dir_contents =  dir(active_data_dir);
        set_dir_names =     {set_dir_contents(3:end).name};
        is_set =            FUNC_find_string_in_cell(set_dir_names, '_MCF');
        set_list =          set_dir_names(is_set);
        
    case 'type_MCH'
        
        set_dir_contents =  dir(active_data_dir);
        set_dir_names =     {set_dir_contents(3:end).name};
        is_set =            FUNC_find_string_in_cell(set_dir_names, '_MCH');
        set_list =          set_dir_names(is_set);
        
    case 'type_MCW'
        
        set_dir_contents =  dir(active_data_dir);
        set_dir_names =     {set_dir_contents(3:end).name};
        is_set =            FUNC_find_string_in_cell(set_dir_names, '_MCW');
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

disp('*** DONE ***');

%% Extract full-ROI voxel values
% process: use T-maps to identify significant voxels, then extract beta values and report positively-correlated voxels

sig_T_thresh =          2;

real_cond_counter =   1;

output_sig_vals =      cell(2, 4);
temp_vals  =            cell(2, 2);

group_counter = 1;

SM_range = [-80 20; -40 20; 0 100];
clearvars output_t_vals output_b_vals subgroup_t_vals subgroup_b_vals group_t_vals group_b_vals


for set_idx = 1 : length(set_list)
    
    % get T values
    curr_t_data =     ROI_stats{1, set_idx};
    
    curr_b_data =       ROI_stats{2, set_idx};
    
    is_all =            size(curr_t_data, 1);
    
    subgroup_t_vals =     cell(1, 2);
    subgroup_b_vals =     cell(1, 2);
    
    
    for ROI_idx = 1 : 2
        
        %         curr_hub_locs =     move_hub_locs{ROI_idx};
        
        for cond_idx = 1 : size(curr_t_data, 1)
            
            curr_ROI_vals =         squeeze( curr_t_data(cond_idx, ROI_idx).active_vals );
            
            curr_ROI_locs =         squeeze( curr_t_data(cond_idx, ROI_idx).active_coords );
            
            %
            %             clearvars input_struct
            %             input_struct.point_vals = curr_ROI_vals;
            %             input_struct.point_locs = curr_ROI_locs;
            %             input_struct.cmap =     'jet';
            %             input_struct.clim =     [2 5];
            %
            %             fig_out = FUNC_plot_3D_fMRI_data(input_struct);
            %
            pos_sig_idx =           find(curr_ROI_vals > sig_T_thresh);
            
            
            sig_T_vals =            curr_ROI_vals(pos_sig_idx);
            sig_locs =              curr_ROI_locs(pos_sig_idx, :);
            
            %             clearvars input_struct
            %             input_struct.point_vals = sig_T_vals;
            %             input_struct.point_locs = sig_locs;
            %             input_struct.cmap =     'jet';
            %             input_struct.clim =     [2 5];
            %
            %             fig_out = FUNC_plot_3D_fMRI_data(input_struct);
            
            all_beta_vals =         squeeze( curr_b_data(cond_idx, ROI_idx).active_vals);
            
            sig_beta_vals =         all_beta_vals(pos_sig_idx);
            
            
            
            
            
            %             A = spm_clusters(curr_ROI_locs');
            
            if is_all == 3
                %                 output_sig_vals{ROI_idx, cond_idx} = output_struct;
                output_t_vals{ROI_idx, cond_idx} = sig_T_vals;
                output_b_vals{ROI_idx, cond_idx} = sig_beta_vals;
                
                output_locs{ROI_idx, cond_idx} = sig_locs;
                
            else
                %                 subgroup_vals{ROI_idx} = output_struct;
                subgroup_t_vals{ROI_idx} = sig_T_vals;
                subgroup_b_vals{ROI_idx} = sig_beta_vals;
                
                subgroup_locs{ROI_idx} = sig_locs;
                
            end
            
        end% FOR cond_idx
        
        
    end% FOR ROI_idx
    
    if is_all ~= 3
        group_t_vals{group_counter} = subgroup_t_vals;
        group_b_vals{group_counter} = subgroup_b_vals;
        
        group_locs{group_counter} = subgroup_locs;
        
        group_counter = group_counter + 1;
    end
    
end% FOR set_idx


if strcmp(set_list{1}, 'AB_all_MO')
    
    val_hold =      group_t_vals{1};
    
else

t_swapper = cell(2, 2);
t_swapper{1, 1} = group_t_vals{1}{1};
t_swapper{1, 2} = group_t_vals{2}{1};
t_swapper{2, 1} = group_t_vals{1}{2};
t_swapper{2, 2} = group_t_vals{2}{2};

output_t_vals(1, 4) = t_swapper(1, 1);
output_t_vals(2, 4) = t_swapper(2, 1);

output_t_vals(1, 5) = t_swapper(1, 2);
output_t_vals(2, 5) = t_swapper(2, 2);



b_swapper = cell(2, 2);
b_swapper{1, 1} = group_b_vals{1}{1};
b_swapper{1, 2} = group_b_vals{2}{1};
b_swapper{2, 1} = group_b_vals{1}{2};
b_swapper{2, 2} = group_b_vals{2}{2};

output_b_vals(1, 4) = b_swapper(1, 1);
output_b_vals(2, 4) = b_swapper(2, 1);

output_b_vals(1, 5) = b_swapper(1, 2);
output_b_vals(2, 5) = b_swapper(2, 2);



loc_swapper = cell(2, 2);
loc_swapper{1, 1} = group_locs{1}{1};
loc_swapper{1, 2} = group_locs{2}{1};
loc_swapper{2, 1} = group_locs{1}{2};
loc_swapper{2, 2} = group_locs{2}{2};

output_locs(1, 4) = loc_swapper(1, 1);
output_locs(2, 4) = loc_swapper(2, 1);

output_locs(1, 5) = loc_swapper(1, 2);
output_locs(2, 5) = loc_swapper(2, 2);

end

%%
% 
% for cond_idx = 1 : 3
%     
%     vals = ROI_stats{1, 1}(cond_idx, 1).active_vals;
%     locs = ROI_stats{1, 1}(cond_idx, 1).active_coords;
%     
%     FUNC_plot_3D_fMRI_data(vals, locs, 'jet', [0 4], 1);
%     
% end

%% Plot T- and beta-values for each condition


figure;

curr_colormap =         jet(length(cond_names)+1);

new_cond_names =        {cond_names{:} 'Stim ref'};

% subplot_idx =           [1 3 2 4];
sp_counter =            1;

for ROI_idx = 1 : 2
    
    subplot(2, 3, sp_counter); hold on;
    
    num_sig_voxels =            cellfun(@length, output_t_vals(ROI_idx, 1:5) );
    b_hs = bar(num_sig_voxels);
    b_hs.FaceColor = 'flat';
    b_hs.CData = curr_colormap;
    ylabel('# sig voxels');
    xticks(1:5);
    xticklabels(new_cond_names);
    set(gca, 'XTickLabelRotation', 45);
    
    
    sp_counter = sp_counter + 1;
    
    
    
    subplot(2, 3, sp_counter); hold on;
    
    values_to_plot =            output_t_vals(ROI_idx, 1:5);
    
    clearvars input_struct
    input_struct.data_cells =   values_to_plot;
    input_struct.cmap =         curr_colormap;
    input_struct.set_labels =   new_cond_names;
    input_struct.new_fig_flag = 0;
    FUNC_boxplot_from_cells(input_struct);
    ylabel('T values');
    title(ROI_plaintext_list{ROI_idx});
    
    sp_counter = sp_counter + 1;
    
    
    
    
    subplot(2, 3, sp_counter); hold on;
    
    values_to_plot =            output_b_vals(ROI_idx, 1:5);
    
    clearvars input_struct
    input_struct.data_cells =   values_to_plot;
    input_struct.cmap =         curr_colormap;
    input_struct.set_labels =   new_cond_names;
    input_struct.new_fig_flag = 0;
    FUNC_boxplot_from_cells(input_struct);
    ylabel('\beta values');
    
    sp_counter = sp_counter + 1;
    
    
end

set(gcf, 'Position', [2028 149 1097 734]);
suplabel('Full ROI', 't');

%% Repeat measures in MO hub


hub_path =          fullfile(active_data_dir, 'AB_all_MO', 'AB_all_move_hub_locs.mat');

loaded_hub_data =     load(hub_path);
move_hub_locs =       loaded_hub_data.hub_coords;


figure;

sp_counter = 1;

clearvars new_hub_Ts new_hub_Bs

for ROI_idx = 1 : 2
    
    % extract values from significant voxels within move hub
    curr_hub_locs =          move_hub_locs{ROI_idx};
    curr_sig_locs =          output_locs(ROI_idx, :);
    
    for cond_idx = 1 : length(curr_sig_locs)
        
        this_locs =             curr_sig_locs{cond_idx};
        
        [C, hub_match_idx, ib] =           intersect(this_locs, curr_hub_locs, 'rows');
        
        curr_Ts =               output_t_vals{ROI_idx, cond_idx};
        curr_Bs =               output_b_vals{ROI_idx, cond_idx};
        
        match_t_vals =          curr_Ts(hub_match_idx);
        match_b_vals =          curr_Bs(hub_match_idx);
        
        new_hub_Ts{ROI_idx, cond_idx} =  match_t_vals;
        new_hub_Bs{ROI_idx, cond_idx} =  match_b_vals;
        
    end
    
    
    subplot(2, 3, sp_counter); hold on;
    
    num_sig_voxels =            cellfun(@length, new_hub_Ts(ROI_idx, 1:5) );
    b_hs = bar(num_sig_voxels);
    b_hs.FaceColor = 'flat';
    b_hs.CData = curr_colormap;
    ylabel('# sig voxels');
    xticks(1:5);
    xticklabels(new_cond_names);
    set(gca, 'XTickLabelRotation', 45);
    
    
    sp_counter = sp_counter + 1;
    
    
    
    subplot(2, 3, sp_counter); hold on;
    
    values_to_plot =            new_hub_Ts(ROI_idx, 1:5);
    
    clearvars input_struct
    input_struct.data_cells =   values_to_plot;
    input_struct.cmap =         curr_colormap;
    input_struct.set_labels =   new_cond_names;
    input_struct.new_fig_flag = 0;
    FUNC_boxplot_from_cells(input_struct);
    ylabel('T values');
    title(ROI_plaintext_list{ROI_idx});
    
    sp_counter = sp_counter + 1;
    
    
    
    
    subplot(2, 3, sp_counter); hold on;
    
    values_to_plot =            new_hub_Bs(ROI_idx, 1:5);
    
    clearvars input_struct
    input_struct.data_cells =   values_to_plot;
    input_struct.cmap =         curr_colormap;
    input_struct.set_labels =   new_cond_names;
    input_struct.new_fig_flag = 0;
    FUNC_boxplot_from_cells(input_struct);
    ylabel('\beta values');
    
    sp_counter = sp_counter + 1;
    
    
end



set(gcf, 'Position', [2028 149 1097 734]);
suplabel('Move Hub', 't');


%%

meta_set_list = {'type_MCW', 'type_MCH', 'type_MCF'};

figure;
set(gcf, 'Position', [2016 43 1701 907]);
subplot_order = [1 5 2 6 3 7 4 8];
plot_counter = 1;

for meta_set_idx = 1 : length(meta_set_list)
    
    
    
    % set_list =  'type_MCF';
    % set_list =  'type_MCH';
    % set_list =  'type_MCW';
    
    set_list = meta_set_list{meta_set_idx};
    
    disp(set_list);
    
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
            
        case 'type_MCF'
            
            set_dir_contents =  dir(active_data_dir);
            set_dir_names =     {set_dir_contents(3:end).name};
            is_set =            FUNC_find_string_in_cell(set_dir_names, '_MCF');
            set_list =          set_dir_names(is_set);
            
        case 'type_MCH'
            
            set_dir_contents =  dir(active_data_dir);
            set_dir_names =     {set_dir_contents(3:end).name};
            is_set =            FUNC_find_string_in_cell(set_dir_names, '_MCH');
            set_list =          set_dir_names(is_set);
            
        case 'type_MCW'
            
            set_dir_contents =  dir(active_data_dir);
            set_dir_names =     {set_dir_contents(3:end).name};
            is_set =            FUNC_find_string_in_cell(set_dir_names, '_MCW');
            set_list =          set_dir_names(is_set);
            
        otherwise
            
            temp = set_list;
            clearvars set_list;
            set_list{1} = temp;
            clearvars temp;
            
            
    end% IF strmatch
    
    %% Load individual subject data
    
    
    
    curr_setname =          set_list{1};
    
    set_path =              fullfile( active_data_dir, curr_setname);
    
    set_contents =          dir(set_path);
    
    this_names =            {set_contents(:).name};
    
    con_idx =               FUNC_find_string_in_cell(this_names, 'con_');
    
    con_paths =             fullfile(set_path, this_names(con_idx), 'indiv_subjects' );
    
    clearvars subj_stats
    
    for con_idx = 1 : length(con_paths)
        
        disp(['CON ' num2str(con_idx) ] );
        
        subj_files =            dir( con_paths{con_idx} );
        
        subj_filenames =        {subj_files(:).name};
        
        
        
        %     img_idx =                 FUNC_find_string_in_cell(subj_filenames, 'spmT');
        
        img_idx =                 FUNC_find_string_in_cell(subj_filenames, 'con_');
        
        
        img_names =               subj_filenames(img_idx);
        
        for subj_idx = 1 : length(img_idx)
            
            disp(['SUBJ ' num2str(subj_idx) ] );
            
            curr_img_path =         fullfile( con_paths{con_idx}, img_names{subj_idx} );
            
            clearvars input_struct
            input_struct.image_path =   curr_img_path;
            input_struct.ROI_path =     ROI_path_list{1};
            input_struct.ROI_names =    ROI_name_list;
            
            curr_stats =             FUNC_extract_fMRI_ROI_voxels(input_struct);
            
            subj_stats(con_idx, subj_idx, :) = curr_stats;
            
            
        end% FOR subj_idx
        
        
        
        
        
    end% FOR con_idx
    
    disp('DONE');
    
    %% Calculate linear-enrichment for each voxel across subjects
    
    
    num_subjs = size(subj_stats, 2);
    
    num_conds = size(subj_stats, 1);
    
    
    line_ends = {[-18 -56; -24 8; 80 26]; [-14 -66; -44 -4; 82 14] };
    
    
    for ROI_idx = 1 : 2
        
        subplot(2, 4, subplot_order(plot_counter) ); hold on;
        plot_counter = plot_counter + 1;
        
        voxel_list =    subj_stats(1, 1, ROI_idx).active_coords;
        
        num_voxels =    length(voxel_list);
        
        cond_vals =     NaN(length(voxel_list), num_subjs, num_conds);
        
        for cond_idx = 1 : 3
            
            for subj_idx = 1 : num_subjs
                
                this_vals =                             subj_stats(cond_idx, subj_idx, ROI_idx).active_vals;
                
                cond_vals(:, subj_idx, cond_idx) =      this_vals;
                
                
            end% FOR subj_idx
            
            
        end% FOR cond_idx
        
        
        disp('LINEARIZING VOXELS');
        voxel_Bs = NaN(num_voxels, num_subjs);
        
        for v_idx = 1 : num_voxels
            
            for subj_idx = 1 : num_subjs
                
                curr_voxel_vals = squeeze( cond_vals(v_idx, subj_idx, 1:3) );
                
                [p, S, mu] = polyfit(1:3, curr_voxel_vals', 1);
                
                voxel_Bs(v_idx, subj_idx) = p(1);
                
            end% FOR subj_idx
            
            
            
        end% FOR v_idx
        
        
        voxel_means = nanmean(voxel_Bs, 2);
        
        voxel_stds = nanstd(voxel_Bs, [], 2);
        
        voxel_Ts =  voxel_means./voxel_stds;
        
        %     figure; histogram(voxel_means);
        
        FUNC_plot_3D_fMRI_data(voxel_means, voxel_list, 'jet', [-0.15 0.15], 0);
        colormap(custom_colormap_BRB);
        
        %     line_obj = line([-18 -62], [-22 8], [80 22], 'LineWidth', 80, 'Color', 'k');
        
        
        
        
        
        num_linepts = 100;
        
        ROI_linepts = line_ends{ROI_idx};
        
        
        x_pts = linspace(ROI_linepts(1, 1), ROI_linepts(1, 2), num_linepts);
        y_pts = linspace(ROI_linepts(2, 1), ROI_linepts(2, 2), num_linepts);
        z_pts = linspace(ROI_linepts(3, 1), ROI_linepts(3, 2), num_linepts);
        
%         scatter3(x_pts, y_pts, z_pts, 10, 'k', 'filled');
        
        radius = 15;
        
        for point_idx = 1 : num_linepts
            
            curr_pt = [x_pts(point_idx) y_pts(point_idx) z_pts(point_idx)];
            
            
            for voxel_idx = 1 : num_voxels
                curr_voxel = voxel_list(voxel_idx, :);
                distance(voxel_idx) =   sqrt( ( curr_pt(1) - curr_voxel(1) ).^2 + (curr_pt(2)-curr_voxel(2)).^2 + (curr_pt(3)-curr_voxel(3)).^2 );
            end
            
            nearby_idx = find(distance < radius);
            
            nearby_vals = voxel_means(nearby_idx);
            
            point_avg(point_idx) = mean(nearby_vals);
            
            point_std(point_idx) = std(nearby_vals);
            
        end
        
        
%         
%             [x,y,z] = sphere;
%             x = x*radius;
%             y = y*radius;
%             z = z*radius;
%             surf(x+curr_pt(1), y+curr_pt(2), z+curr_pt(3));
        
        all_point_vals{meta_set_idx, ROI_idx} = point_avg;
        all_point_stds{meta_set_idx, ROI_idx} = point_std;
        
        %     figure; plot(point_avg);
        
        title([ROI_plaintext_list{ROI_idx} ' - ' movement_list{meta_set_idx} ] );
        
    end% FOR ROI_idx
    
    
    
end% FOR meta_set_idx



for ROI_idx = 1 : 2
    
    subplot(2, 4, subplot_order(plot_counter) ); hold on;
    plot_counter = plot_counter + 1;
    
    
    for con_idx = 1 : num_conds
        
        curr_vals = [all_point_vals{con_idx, ROI_idx}];
        
%         curr_stds = [all_point_stds{con_idx, ROI_idx}];
        
        plot(curr_vals, 'LineWidth', 2);
        
%         shadedErrorBar(1:100, curr_vals, curr_stds);
        
    end
    
    legend('Wrist', 'Hand', 'Fingers', 'Location', 'se');
    title(ROI_plaintext_list{ROI_idx});
    
        line([0 100], [0 0], 'LineStyle', '--', 'Color', 'k');

    
end


%%
% 
% 
% % %% Quantify subject values
% 
% for subj_idx = 1 : size(subj_stats, 2)
%     
%     disp(['SUBJ ' num2str(subj_idx)] );
%     
%     for con_idx = 1 : size(subj_stats, 1)
%         
%         for ROI_idx = 1 : size(subj_stats, 3)
%             
%             curr_active_vals =       subj_stats(con_idx, subj_idx, ROI_idx).active_vals;
%             
%             curr_active_locs =      subj_stats(con_idx, subj_idx, ROI_idx).active_coords;
%             
% %             sig_idx =               find(curr_active_vals > 2);
%             sig_idx =               find(curr_active_vals);
%             
%             sig_vals =              curr_active_vals(sig_idx);
%             sig_locs =              curr_active_locs(sig_idx, :);
%             
%             if ~isempty(sig_vals)
% %                 COM_data =              FUNC_calc_voxel_COM(sig_vals, sig_locs);
%             end
%             
%             subj_stats(con_idx, subj_idx, ROI_idx).sig_vals = sig_vals;
%             subj_stats(con_idx, subj_idx, ROI_idx).sig_locs = sig_locs;
% %             subj_stats(con_idx, subj_idx, ROI_idx).COM_loc =     COM_data.COM_loc;
% 
%             
%         end% FOR ROI_idx
% %         new_cond_names =        {cond_names{:} 'Stim ref'};
%         new_cond_names =        {cond_names{1:3}};
% 
%         
%         
%     end% FOR con_idx
%     
%     
%     
%     
%     
% end% FOR subj_idx
% 
% disp('DONE');
% 
% % Plot subject vals
% 
% figure; 
% 
% num_subjs = size(subj_stats, 2);
% 
% num_cons = size(subj_stats, 1);
% 
% for ROI_idx = 1 : 2
%     
%     all_vals = {};
%     
% %     group_assn = ones(1, 100);
%     group_assn = [];
% 
%     for cond_idx = 1 : num_cons
%         
%         curr_cond_vals =    {subj_stats(cond_idx, :, ROI_idx).sig_vals};
%         
%         all_vals =          horzcat(all_vals, curr_cond_vals);
%         
%         group_assn(cond_idx*num_subjs - 19 : cond_idx*num_subjs) = cond_idx;
% 
%         
%         
%     end
%     
%     num_points =        cellfun(@length, all_vals);
%     num_subsets =       num_cons*num_subjs;
%     block_data =        NaN(num_subsets, max(num_points) );
%     
%     
%     for set_idx = 1 : num_subsets
%         block_data(set_idx, 1:num_points(set_idx) ) =   all_vals{set_idx};
%         
%     end
%     
% %     boxplot(block_data', group_assn);
%     boxplot(block_data');
%     
%     line([20.5 20.5], [2 11]);
%     line([40.5 40.5], [2 11]);
%     line([60.5 60.5], [2 11]);
%     line([80.5 80.5], [2 11]);
% 
%     
% end
% 
% 
% 
% 
% 































