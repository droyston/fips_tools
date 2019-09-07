%
% 2016-07-06 Dylan Royston
%
% Stand-alone function to save preprocessed data to a given server folder
% Saves only if data does not exist in specified folder, or if Overwrite flag is on
% File name specifies subject and norm/indiv, specific paradigm/ROI data are stored in accompanying metadata file
%

%%

function Save_Preproc_CM_Data(data_struct, metadata_struct, save_path, overwrite_flag)

% establishes file naming convention for 1 or multiple subjects
subject_list =      metadata_struct.subject_list;
num_subjects =      length(subject_list);

if num_subjects == 1
    data_file_name_design =     '%s_DATA.mat';
    meta_file_name_design =     '%s_META_DATA.mat';
    data_file_name =    sprintf(data_file_name_design, subject_list{1});
    meta_file_name =    sprintf(meta_file_name_design, subject_list{1});
else
    data_file_name =    'MULTI_SUBJECT_DATA.mat';
    meta_file_name =    'MULTI_SUBJECT_META_DATA.mat';
end

% checks if the specified data already exists
folder_contents =       dir(save_path);
num_files =             size(folder_contents, 1);

% if folder is empty, save anyway
if num_files == 2
    do_save = 1;
else
    
    file_exists = 0;
    % search for desired save file
    for file_idx = 3:num_files
        
        curr_file_name =    folder_contents(file_idx).name;
        name_check =        strcmp(curr_file_name, data_file_name);
        
        % if file is found, implement overwrite_flag
        if name_check ==    1
            file_exists =   1;
        end
        
    end% file loop
    
    % if file exists and overwrite is desired, do save; if not, exit
    if file_exists == 1
        if overwrite_flag == 1
            do_save = 1;
        else
            do_save = 0;
        end
    else
        do_save = 1;
    end% file exists
    
    
end% file loop

if do_save == 1
    full_data_path = [save_path data_file_name];
    full_meta_path = [save_path meta_file_name];
    
    save(full_meta_path, 'metadata_struct');
    save(full_data_path, 'data_struct');
    display('--- DATA SAVED SUCCESSFULLY ---');
    
else
    display('--- DATA ALREADY EXISTS, NOT SAVED ---');
end

end% end function
