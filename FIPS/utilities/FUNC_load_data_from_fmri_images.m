% 2019-08-16 Dylan Royston
%
% Version of FUNC_load_data_from_group_images, modified to work with single subject images
% 
% Works with file structures in new_group_images directory
%
%
%
%
%
%%

function output_struct = FUNC_load_data_from_fmri_images(data_path, folder_name, ROI_path, ROI_names)


% load all conditions within a set by finding all subfolders in a set (should only be condition containers)
set_path =      fullfile(data_path, folder_name);
set_contents =  dir(set_path);
set_filenames = {set_contents(3:end).name};
cond_names =    set_filenames( isfolder( fullfile(set_path, set_filenames) ) );

for cond_idx = 1 : length(cond_names)
    
    disp(num2str(cond_idx));
    
    % load T contrast image
    cond_path =     fullfile( set_path, cond_names{cond_idx}, 'indiv_subjects' );
    subj_files =    dir(cond_path);
    cond_filenames = {subj_files(3:end).name};
    

    clearvars file_data
    for file_idx = 1 : length(cond_filenames)
        
        file_path  =    fullfile(cond_path, cond_filenames{file_idx} );
        
        
        clearvars cond_nii cond_img input_struct
        
        % extract ROI statistics from each image
        input_struct.image_path =   file_path;
        input_struct.ROI_path =     ROI_path{1};
        input_struct.ROI_names =    ROI_names;
        
        current_voxel_data =        FUNC_extract_fMRI_ROI_voxels(input_struct);
        
        % 2019-08-20 test
        
        
        saved_data.active_vals =    current_voxel_data.active_vals;
        saved_data.active_coords =  current_voxel_data.active_coords;
        
        file_data{file_idx} =       saved_data;
        
    end
    
    
    ROI_stats(cond_idx, :) =         file_data;
    
    output_struct = ROI_stats;
    
    
end% FOR cond_idx









end