% 2016-09-28 Dylan Royston
%
% Script to convert a folder full of MB ANALYZE images to 4D NIFTI
%
%
%
%
%
% WARNING DO NOT USE CURRENTLY BROKEN
%
%%

subject_id =        'CMC13';

analyze_folder =    ['R:\data_generated\human\covert_mapping\SUBJECT DATA STORAGE\' subject_id '\MB Recon'];
nifti_folder =      ['R:\data_generated\human\covert_mapping\SUBJECT DATA STORAGE\' subject_id '\NIFTI'];

analyze_files =     dir(analyze_folder);
num_files =         length(analyze_files);

for file_idx = 3:num_files
    
    file_name =         analyze_files(file_idx).name;
    target_string =     '_MB.hdr';
    is_header =         strfind(file_name, target_string);
    
    if ~isempty(is_header)
        
        full_path =         [analyze_folder '\' file_name];
        name_minus_ext =    strsplit(file_name, '.');       
        new_name_path =     [nifti_folder '\' name_minus_ext{1} '.nii'];
        
        already_made =      exist(new_name_path, 'file');
        
        if already_made ~= 2
            display(['*** SAVING NIFTI FILE ***' new_name_path]);
            
            curr_image =        load_untouch_nii(full_path);
            curr_nii =          make_nii(curr_image.img);
            save_nii(curr_nii, new_name_path);
        else
            display(['*** NIFTI ALREADY EXISTS ***' new_name_path]);
        end% existence check
        
    end% is a valid ANALYZE file
    
end% file loop
