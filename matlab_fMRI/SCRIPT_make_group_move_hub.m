% 2019-08-09 Dylan Royston
%
% Script to generate common movement-hub ROI/cluster from AB_all_MO group set data 
%
% Accessory/dependent from SHELL_updated_CM_analysis
%
%
%
%
%
%% Initialize data to load

clear; clc;

% paths to individual subject files (source_data_dir) and group-level repository (active_data_dir)
source_data_dir =   '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/%s/NIFTI/%s';
% active_data_dir =   '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/%s/BETAS/%s';

% multi-subject
active_data_dir =   '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/new_group_level';

ROI_path_list =     {'/home/dar147/Documents/GITLOCAL/bci_analysis/Dylan/Neuroimaging/ROI/marsbar-aal-0.2_NIFTIS'};
ROI_name_list =     {'MNI_Precentral_L_roi.nii', 'MNI_Postcentral_L_roi.nii'};

ROI_plaintext_list = {'M1', 'S1'};


figure_flags.raw_voxels =       0;
figure_flags.move_clusters =    0;
figure_flags.overlap =          0;

%% 2: Extract volumetric voxel data from group-level T-maps

disp('*** EXTRACTING VOLUMETRIC DATA ***');

clearvars ROI_stats

set_list = 'AB_all_MO';
% set_list = 'SCI_motor_complete_MO';

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


% load group Tmaps
for set_idx = 1 : length(set_list)
    
    set_name =      set_list{set_idx};
    
    disp(['*** PROCESSING SET: ' set_name ' ***']);
    
    % load all conditions within a set by finding all subfolders in a set (should only be condition containers)
    set_path =      fullfile(active_data_dir, set_name);
    set_contents =  dir(set_path);
    set_filenames = {set_contents(3:end).name};
    cond_names =    set_filenames( isfolder( fullfile(set_path, set_filenames) ) );
    
    for cond_idx = 1 : length(cond_names)
        
        disp(num2str(cond_idx));
        
        % load T contrast image
        cond_path =     fullfile( set_path, cond_names{cond_idx} );
        cond_files =    dir(cond_path);
        cond_filenames = {cond_files(3:end).name};
        
        cond_T_file =   cond_filenames{ FUNC_find_string_in_cell(cond_filenames, '_T.nii') };
        cond_T_path =   fullfile(cond_path, cond_T_file);
        
        cond_nii =      load_untouch_nii(cond_T_path);
        cond_img =      cond_nii.img;
        
        %         set_IMGs(:, :, :, cond_idx) = cond_img;
        
        clearvars cond_nii cond_img input_struct
        
        
        % test, load p-val for FDR calc
        %         pIMG_path =                 strrep(cond_T_path, '_T.nii', '_P.nii');
        %         p_nii =                     load_untouch_nii(pIMG_path);
        %         p_img =                     p_nii.img;
        %         real_Ps =                   find(~isnan(p_img));
        %         list_Ps =                   p_img(real_Ps);
        
        % calculate FDR-corrected significance threshold and voxels (takes a while)
        % formula might look like this? not correct currently (probably, doesn't match TKsurfer)
        %         [sig_inds, thresh] =      FDR(list_Ps, 0.05);
        %         real_Tvals =              cond_img(real_Ps);
        %         sig_Tvals =               (real_Tvals(sig_inds) );
        %         test_thresh =             mean(sig_Tvals>0);
        
        % extract ROI statistics from group image
        input_struct.image_path =   cond_T_path;
        input_struct.ROI_path =     ROI_path_list{1};
        input_struct.ROI_names =    ROI_name_list;
        
        current_voxel_data =        FUNC_extract_fMRI_ROI_voxels(input_struct);
        
        
        ROI_stats(set_idx, cond_idx, :) =         current_voxel_data;
        
        
        %         optional, plot extracted voxel data
        %         combine values from M1/S1 for plotting
        
        %         test_vals =         vertcat(current_voxel_data(1).active_vals, current_voxel_data(2).active_vals);
        %         test_locs =         vertcat(current_voxel_data(1).active_coords, current_voxel_data(2).active_coords);
        %
        %         clearvars input_struct
        %         input_struct.point_vals =   test_vals;
        %         input_struct.point_locs =   test_locs;
        %         input_struct.cmap =         'jet';
        %         input_struct.clim =         [2 6];
        %         FUNC_plot_3D_fMRI_data(input_struct);
        
    end% FOR cond_idx
    
    
end% FOR set_idx

disp('*** DONE ***');

%% OPTIONAL: visualize extracted voxel data for specified set

if figure_flags.raw_voxels == 1
    
    target_set_idx =    1;
    target_cond_idx =   2;
    
    current_voxel_data =    squeeze( ROI_stats(target_set_idx, target_cond_idx, :) );
    
    
    test_vals =         vertcat(current_voxel_data(1).active_vals, current_voxel_data(2).active_vals);
    test_locs =         vertcat(current_voxel_data(1).active_coords, current_voxel_data(2).active_coords);
    
    clearvars input_struct
    input_struct.point_vals =   test_vals;
    input_struct.point_locs =   test_locs;
    input_struct.cmap =         'jet';
    input_struct.clim =         [2 6];
    FUNC_plot_3D_fMRI_data(input_struct);
    
end

%% Identify main cluster for overt conditions

% NOTE: COULD SAVE CLUSTERS OUT AS BINARY ROI NIFTI FILES 

% M1_range = [-80 20; -40 20; 0 78];
SM_range = [-80 20; -40 20; 0 100];
clearvars cluster_stats

for ROI_idx = 1 : 2
    
    % go through MO conditions to generate main cluster
    
    for set_idx = 1 : length(set_list)
        
        curr_setname = set_list{set_idx};
        is_overt = contains(curr_setname, '_MO');
        
        if is_overt
            
            for cond_idx = 1 : length(cond_names)
                
                
                current_voxel_data =        squeeze( ROI_stats(set_idx, cond_idx, ROI_idx) );
                
                clearvars input_struct output_struct
                input_struct.voxel_vals =   current_voxel_data.active_vals;
                input_struct.voxel_locs =   current_voxel_data.active_coords;
                input_struct.sig_thresh =   3.5;
                input_struct.make_figures = 0;
                
                output_struct =             FUNC_generate_fMRI_cluster(input_struct);
                
                cluster_stats(set_idx, cond_idx, ROI_idx) = output_struct;
                
            end% FOR cond_idx
            
        end% IF is_overt
        
        
    end% FOR set_idx
    
end% FOR ROI_idx


%% plot all clusters in same splace

if figure_flags.overlap == 1
    
    jet_colorbar_rgb =      [ [24 28 137];...
        [45 123 212];...
        [148 248 114];...
        [255 148 43];...
        [128 26 39] ]/255;
    
    symbols = {'*', '.', 's', 'd', '^'};
    
    plot_range = [1 4];
    
    for ROI_idx = 1 : 2
        
        overlap_H(ROI_idx) = figure;
        hold on;
        xlim([-80 20])
        ylim([-40 20]);
        zlim([0 78]);
        
        set_idx = 1;
        
        for cond_idx = plot_range(1) : plot_range(2)
            
            curr_locs =                     cluster_stats(set_idx, cond_idx, ROI_idx).cluster_locs;
            curr_vals =                     cluster_stats(set_idx, cond_idx, ROI_idx).cluster_vals;
            curr_CoM =                      cluster_stats(set_idx, cond_idx, ROI_idx).COM_loc;
            
            scatter3(curr_locs(:, 1), curr_locs(:, 2), curr_locs(:, 3), 160, jet_colorbar_rgb(cond_idx, :), symbols{cond_idx});
            
            FUNC_draw_3D_intersect(gcf, curr_CoM);
            
        end% FOR, cond_idx
        
        set(gca, 'View', [-100 60]);
        
    end% FOR ROI_idx
    
end


%% identify main "hub", cluster shared between all 3 hand movements

for ROI_idx = 1 : 2
    
    counter = 1;
    
    set_idx = 1;
    
    for cond_idx = 2 : 4
        
        curr_cluster_locs =         cluster_stats(set_idx, cond_idx, ROI_idx).cluster_locs;
        
        all_cluster_locs{counter} = curr_cluster_locs;
        counter =                   counter + 1;
        
    end% FOR cond_idx
    
    % cluster_sizes = cellfun(@length, all_cluster_locs);
    
    % block_locs = NaN(max(cluster_sizes), 3, 3);
    
    % block_locs(1:cluster_sizes(1), :, 1) = all_cluster_locs{1};
    % block_locs(1:cluster_sizes(2), :, 2) = all_cluster_locs{2};
    % block_locs(1:cluster_sizes(3), :, 3) = all_cluster_locs{3};
    
    move_hub_locs =   mintersect(all_cluster_locs{1}, all_cluster_locs{2}, all_cluster_locs{3}, 'rows');
    
    hub_coords{ROI_idx} = move_hub_locs;
    
    if figure_flags.overlap == 1
        % visualize common hub on figure above
        figure(overlap_H(ROI_idx) );
        scatter3(move_hub_locs(:, 1), move_hub_locs(:, 2), move_hub_locs(:, 3), 160, 'k', 'filled');
    end
    
end

%% Save move hub as external file (currently coordinates, could be binary

dest_filepath = fullfile(set_path, 'AB_all_move_hub_locs.mat');

save(dest_filepath, 'hub_coords', '-v7.3');

disp('*** HUB COORDINATES SAVED ***');






