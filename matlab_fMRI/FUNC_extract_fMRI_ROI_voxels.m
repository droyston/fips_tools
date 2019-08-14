% 2019-07-22 Dylan Royston
%
% Function to extract ROI stats (voxels) from a given fMRI image
% More generalized version of "organize_extracted_fmri_covert_mapping_stats"
%
% Extracts and organizes voxel data from specified ROIs out of a single image
%
%
%
%
%%

function output_struct = FUNC_extract_fMRI_ROI_voxels(input_struct)

image_path =    input_struct.image_path;
ROI_path =      input_struct.ROI_path;
ROI_list =      input_struct.ROI_names;

for roi_idx = 1 : length(ROI_list)
    
    % extracts ROI voxel data
    curr_ROI_path =         fullfile(ROI_path, ROI_list{roi_idx});
    voxel_data =            extract_stats_from_epi(curr_ROI_path, image_path);
    
    % converts voxel data into vals and locs
    active =                find(voxel_data);
    active_vals =           voxel_data(active);
    [ind_X, ind_Y, ind_Z] = ind2sub(size(voxel_data), active);
    active_locs =           [ind_X, ind_Y, ind_Z];
    
    % recalibrates coordinates to match MNI space
    convert =               2*active_locs;
    convert =               [convert(:, 1)-92, convert(:, 2)-128, convert(:, 3)-74];
    active_coords =         convert;
    
    % stores output data
    output_struct(roi_idx).raw_img =        voxel_data;
    output_struct(roi_idx).active_vals =    active_vals;
    output_struct(roi_idx).active_coords =  active_coords;
    
end% FOR roi_idx

end% FUNCTION