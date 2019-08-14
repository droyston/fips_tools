% 2019-07-17 Dylan Royston
%
% Subfunction to load, concatenate, and calculate group-level beta/T images
% Writing now to work on single tasks with multiple subjects for simplicity
%
%
%
%
%
%
%%

function output_struct = FUNC_create_group_beta_images(input_struct)

% load input variables
load_path =         input_struct.load_path;
save_path =         input_struct.save_path;
set_handle =        input_struct.set_handle;
subject_list =      input_struct.subjects;
task_name =         input_struct.task;
cond_list =         input_struct.conds;
flags =             input_struct.flags;

% check/create dedicated folder for this set
set_path =          fullfile(save_path, set_handle);

if ~isdir(set_path)
    disp('*** CREATING SET DIRECTORY ***');
    mkdir(set_path);
end

% cd(set_path);

%% Load individual subject images for each task/condition

% cycle through each condition
for cond_idx = 1 : length(cond_list)
    
    disp(['*** CONDITION ' num2str(cond_idx) ': LOADING IMAGES ***']);
    
    contrast_name =     sprintf('con_%4.4i.nii', cond_list(cond_idx) );
    
    % check/make folder for each condition
    subset_path =       fullfile(set_path, ['con_' num2str(cond_idx)]);
    if ~isdir(subset_path)
        disp('*** CREATING SUBSET DIRECTORY ***');
        mkdir(subset_path);
        indiv_subj_store_path =     fullfile(subset_path, 'indiv_subjects');
        mkdir(indiv_subj_store_path);
    else
        indiv_subj_store_path =     fullfile(subset_path, 'indiv_subjects');
    end
    
    % normalized dimensions (79x95x69xS)
    IMG =               [];
    
    % concatenate images from each subject for this condition
    for subject_idx = 1 : length(subject_list)
        
        target_path =       sprintf(load_path, subject_list{subject_idx}, task_name);
        contrast_path =     fullfile(target_path, contrast_name);
        
        % optional, copy each subject's contrast to a separate storage folder
        new_filepath =      fullfile(indiv_subj_store_path, [subject_list{subject_idx} '_' contrast_name]);
        
        if ~isfile(new_filepath)
            eval(sprintf('!cp %s %s', contrast_path, new_filepath));
        end
        
        nii =          load_untouch_nii(contrast_path);
        IMG(:, :, :, subject_idx) = nii.img;
        
    end% FOR subject_idx
    
    %% calculate group images
    
    disp('*** CALCULATING ***');

    % calculate group-average images
    mIMG =     squeeze(nanmean(IMG, 4));% mean image
    sIMG =     squeeze(nanstd(IMG, [], 4)./sqrt(size(IMG, 4) ) );% standard error of mean image
    tIMG =     mIMG./sIMG;% t contrast
    pIMG =     1-tcdf( abs(tIMG), size(IMG,4)-1);% p values
    
    
    % save new contrast files with original header information
    m_nii =     nii;
    m_nii.img = mIMG;
    save_untouch_nii(m_nii, fullfile(subset_path, ['con' num2str(cond_idx) '_mean.nii']) );
    %     clearvars mIMG;
    
    s_nii =     nii;
    s_nii.img = sIMG;
    save_untouch_nii(s_nii, fullfile(subset_path, ['con' num2str(cond_idx) '_sem.nii']) );
    %     clearvars sIMG;
    
    t_nii =     nii;
    t_nii.img = tIMG;
    save_untouch_nii(t_nii, fullfile(subset_path, ['con' num2str(cond_idx) '_T.nii']) );
    %     clearvars tIMG;
    
    p_nii =     nii;
    p_nii.img = pIMG;
    save_untouch_nii(p_nii, fullfile(subset_path, ['con' num2str(cond_idx) '_P.nii']) );
    
    % save group-level images to output_struct
    output_struct(cond_idx).subset_path = subset_path;
    output_struct(cond_idx).mean_img =  mIMG;
    output_struct(cond_idx).sem_img =   sIMG;
    output_struct(cond_idx).t_img =     tIMG;
    output_struct(cond_idx).p_img =     pIMG;
    
end% FOR cond_idx

disp('*** DONE ***');

end% FUNCTION