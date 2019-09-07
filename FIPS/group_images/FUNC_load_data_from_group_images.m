% 2019-08-09 Dylan Royston
%
% Function to simplify extracting group-level image values from file structure
% Dependency from SHELL_updated_CM_analysis
%
%
%
%
%
%
%%

function output_struct = FUNC_load_data_from_group_images(data_path, set_name, ROI_path, ROI_names, map_type)




% load all conditions within a set by finding all subfolders in a set (should only be condition containers)
set_path =      fullfile(data_path, set_name);
set_contents =  dir(set_path);
set_filenames = {set_contents(3:end).name};
cond_names =    set_filenames( isfolder( fullfile(set_path, set_filenames) ) );

for cond_idx = 1 : length(cond_names)
    
    disp(num2str(cond_idx));
    
    % load T contrast image
    cond_path =     fullfile( set_path, cond_names{cond_idx} );
    cond_files =    dir(cond_path);
    cond_filenames = {cond_files(3:end).name};
    
    switch map_type
        case 'T'
            cond_img_file =   cond_filenames{ FUNC_find_string_in_cell(cond_filenames, '_T.nii') };
        case 'B'
            cond_img_file =   cond_filenames{ FUNC_find_string_in_cell(cond_filenames, '_mean.nii') };
    end
    
    cond_img_path =   fullfile(cond_path, cond_img_file);
    
    cond_nii =      load_untouch_nii(cond_img_path);
    cond_img =      cond_nii.img;
    
    set_IMGs(:, :, :, cond_idx) = cond_img;
    
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
    input_struct.image_path =   cond_img_path;
    input_struct.ROI_path =     ROI_path;
    input_struct.ROI_names =    ROI_names;
    
    current_voxel_data =        FUNC_extract_fMRI_ROI_voxels(input_struct);
    
    
    ROI_stats(cond_idx, :) =         current_voxel_data;
    
    output_struct = ROI_stats;
    
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









end