% 2019-05-15 Dylan Royston
%
% Shell script for analyzing Covert Mapping fMRI activity
% Focused on using SPM-preprocessed images
%
%
% === DEPDENDENCIES ===
%   - 
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



organized_data =        FUNC_organize_group_voxel_data(ROI_stats);

output_t_vals =         organized_data.t_vals;
output_b_vals =         organized_data.b_vals;
output_locs =           organized_data.locs;

%%

temp_vals = output_b_vals{1, 1};
temp_locs = output_locs{1, 1};

h = FUNC_plot_3D_fMRI_data(temp_vals, temp_locs, 'jet', [0 3], 1);

comdata = FUNC_calc_voxel_COM(temp_vals, temp_locs);

%% Plot T- and beta-values for each condition


figure;

new_cond_names = {'Lips', 'Wrist', 'Hand', 'Fingers', 'Ankle'};

% curr_colormap =         jet(length(cond_names)+1);

curr_colormap =             jet(length(new_cond_names));

% new_cond_names =        {cond_names{:} 'Stim ref'};

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


%% 


hub_path =          fullfile(active_data_dir, 'AB_all_MO', 'AB_all_move_hub_locs.mat');

loaded_hub_data =     load(hub_path);
move_hub_locs =       loaded_hub_data.hub_coords;

for ROI_idx = 1 : 2
    
    curr_locs =             move_hub_locs{ROI_idx};
    
    fake_vals =             ones(length(curr_locs), 1);
    
    FUNC_plot_3D_fMRI_data(fake_vals, curr_locs, 'jet', [1 2], 1);
    
    hub_com = FUNC_calc_voxel_COM(fake_vals, curr_locs);
    
    FUNC_draw_3D_intersect(gcf, hub_com.COM_loc);
    
    
    ml_midpoint = hub_com.COM_loc(1);
    
    medial_loc_idx = find(curr_locs(:, 1) > ml_midpoint);
    lateral_loc_idx = find(curr_locs(:, 1) < ml_midpoint);
    
    
    medial_locs = curr_locs(medial_loc_idx, :);
    lateral_locs = curr_locs(lateral_loc_idx, :);
    
    sublocs{ROI_idx, 1} = medial_locs;
    sublocs{ROI_idx, 2} = lateral_locs;
    
end

%% Repeat measures in MO hub

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

%% compare distributions between hub halves

% basically null results

figure;

sp_counter = 1;

clearvars new_hub_Ts new_hub_Bs

sub_labels = {'Medial', 'Lateral'};

sp_idx = [1 2 5 6 3 4 7 8];

for ROI_idx = 1 : 2
    
    for sub_idx = 1 : 2
        
            curr_sublocs =  sublocs{ROI_idx, sub_idx};
            curr_sig_locs =          output_locs(ROI_idx, :);
            
            for cond_idx = 2  : 4 %currently hard-coded for MO hand conditions
                
                this_locs =             curr_sig_locs{cond_idx};
                
                [C, hub_match_idx, ib] =           intersect(this_locs, curr_sublocs, 'rows');
                
                curr_Ts =               output_t_vals{ROI_idx, cond_idx};
                curr_Bs =               output_b_vals{ROI_idx, cond_idx};
                
                match_t_vals =          curr_Ts(hub_match_idx);
                match_b_vals =          curr_Bs(hub_match_idx);
                
                new_hub_Ts{ROI_idx, cond_idx-1} =  match_t_vals;
                new_hub_Bs{ROI_idx, cond_idx-1} =  match_b_vals;
                
            end
            
            subplot(2, 4, sp_idx(sp_counter)); hold on;
            
            values_to_plot =            new_hub_Ts(ROI_idx, :);
            
            clearvars input_struct
            input_struct.data_cells =   values_to_plot;
            input_struct.cmap =         curr_colormap;
            input_struct.set_labels =   new_cond_names(2:4);
            input_struct.new_fig_flag = 0;
            FUNC_boxplot_from_cells(input_struct);
            ylabel('T values');
            title([ROI_plaintext_list{ROI_idx} ' ' sub_labels{sub_idx}]);
            
            sp_counter = sp_counter + 1;
            
            
            
            
            subplot(2, 4, sp_idx(sp_counter)); hold on;
            
            values_to_plot =            new_hub_Bs(ROI_idx, :);
            
            clearvars input_struct
            input_struct.data_cells =   values_to_plot;
            input_struct.cmap =         curr_colormap;
            input_struct.set_labels =   new_cond_names(2:4);
            input_struct.new_fig_flag = 0;
            FUNC_boxplot_from_cells(input_struct);
            ylabel('\beta values');
            title([ROI_plaintext_list{ROI_idx} ' ' sub_labels{sub_idx}]);

            
            sp_counter = sp_counter + 1;
            
        
    end% FOR sub_idx
    
    
end% FOR ROI_idx



set(gcf, 'Position', [2028 149 1097 734]);
suplabel('Move Hub', 't');


%% Load individual subject data


meta_set_list = {'AB_all_MO'};

for meta_set_idx = 1 : length(set_list)
    
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
    
    %% Calculate subject COMs
    
    
    num_subjs = size(subj_stats, 2);
    
    num_conds = size(subj_stats, 1);
    
    for ROI_idx = 1 : 2
        
        clearvars all_s_COMs

        for cond_idx = 1 : num_conds
            
            for subj_idx = 1 : num_subjs
                
%                 curr_img = subj_stats(cond_idx, subj_idx, ROI_idx).raw_img;
                
                curr_vals = subj_stats(cond_idx, subj_idx, ROI_idx).active_vals;
                curr_locs = subj_stats(cond_idx, subj_idx, ROI_idx).active_coords;
                
%                 h = FUNC_plot_3D_fMRI_data(curr_vals, curr_locs, 'jet', [0 3], 1);
                
                
                pos_val_idx = find(curr_vals > 0);
                pos_vals = curr_vals(pos_val_idx);
                pos_locs = curr_locs(pos_val_idx, :);
                
                
%                 subj_COM =  FUNC_calc_voxel_COM_new(curr_vals, curr_locs);
                subj_COM =  FUNC_calc_voxel_COM(pos_vals, pos_locs);
%                   subj_COM =  FUNC_calc_voxel_COM(curr_img);
            
                all_s_COMs(subj_idx, cond_idx, :) = subj_COM.COM_loc;
                
                
            end% FOR subj_idx
            
            
            
        end% FOR cond_idx
        
        
        subject_COMs{ROI_idx} = all_s_COMs;
        
        
    end% FOR ROI_idx
    
    
    %%
    
    figure;
    
    jet_colormap = jet(num_conds);
    
    for ROI_idx = 1 : 2
        
        subplot(1, 2, ROI_idx); hold on;
        
        set(gca, 'View', [-100 60]);
        xlim([-80 20]);
        ylim([-60 20]);
        zlim([0 100]);

        
        for cond_idx = 1 : num_conds
            
            curr_COMs = squeeze( subject_COMs{ROI_idx}(:, cond_idx, :) );
            
            scatter3(curr_COMs(:, 1), curr_COMs(:, 2), curr_COMs(:, 3), 60, jet_colormap(cond_idx, :));
            
            cond_means(cond_idx, :) = mean(curr_COMs, 1);
                        
%             [c, r, ev, v, ch] = ellipsoid_fit(curr_COMs);
            
%             ellipse(
            
        end
        
        scatter3(cond_means(:, 1), cond_means(:, 2), cond_means(:, 3), 150, jet_colormap, 's', 'filled');
        
        
    end
    
    
    
    
    
end% FOR meta_set_idx






















