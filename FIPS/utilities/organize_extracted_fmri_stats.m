% 2015-08-03 Dylan Royston
%
%
% Attempt to move fMRI stat organization operations into stand-alone function
%
%
%
% === INPUTS ===
% = FLAGS
%       - AB_only: whether or not to process SCI subjects
%       - age_match: whether or not to process only the closest age-matched AB subjects
% = subject_list
% = SCI_subject_list
% = trial_list
% = conditions
% = ROI_list
%
%
%
%
% === OUTPUTS ===
%
%
% === UPDATES ===
% 2015-08-05 Royston: added progress counter for giggles
% 2016-07-18 Royston: started major rewrite for fresh analysis
% 2016-07-29 Royston: replaced hard-coded ROI voxel with smarter automatic calculation
%
%% Configure inputs from structure

function  output_struct = organize_extracted_fmri_stats(input_struct)

subject_list =          input_struct.subject_list;
dominance_flag =        input_struct.dominance_flag;

paradigms =             input_struct.paradigms;
ROI_list =              input_struct.ROI_list;
original_ROI_path =              input_struct.ROI_path;
study_path =            input_struct.study_path;



% 2015-09-28 Royston: edited for dominant hand analysis
if dominance_flag == 1
    handedness =            input_struct.handedness;
end


if length(ROI_list) == 1
    all_rois = 1;
else
    all_rois = 0;
end


if all_rois == 1
    
    roi_path = 'C:\hst2\Analysis Code\Dylan\Neuroimaging\ROI\marsbar-aal-0.2_NIFTIS\';
    all_roi_data = dir(roi_path);
    
    for r = 1:length(all_roi_data)
        all_rois_full{r} = all_roi_data(r).name;
    end
    
    for r=3:length(all_roi_data)
        ROI_list{r-2}  = strtok(all_rois_full{r}, '.');
    end
    
end

output_struct.readable_rois = ROI_list;


%% Extract T-vals from SPM_T contrast file, into AB- and SCI-specific cell arrays
display('*** EXTRACTING RAW DATA FROM NII FILES ***');

total = length(subject_list)*length(paradigms)*length(ROI_list);
fprintf('%d / ', total)

fprintf('\n')

raw_data = cell( length(subject_list), length(paradigms), length(ROI_list) );

counter = 0;



for s=1:length(subject_list)
    for c=1:length(paradigms)
        
        ROI_stats.subject_id =          subject_list{s};
        
        
        % update
        if dominance_flag == 1
            ROI_stats.side =                handedness{s};
            
            ROI_stats.trial_design =        paradigms{c};
            ROI_stats.condition_name =      str_from_design(ROI_stats, ROI_stats.trial_design);
        else
            ROI_stats.condition_name = paradigms{c};
        end
        
        
        % access correct stat folders (currently reliant on pre-curated folder structure)
        
%         ROI_stats.study_path_design = 'R:\data_generated\human\fMRI_motor_imagery\New subject data storage\[subject_id]\NIFTI\[condition_name]';
        

        % 2016-07-22 Royston: updated to search subject folder for desired tasks
        ROI_stats.study_path_design = 'R:\data_generated\human\fMRI_motor_imagery\New subject data storage\[subject_id]\NIFTI';

        ROI_stats.study_path =          str_from_design(ROI_stats, ROI_stats.study_path_design);
        
        cd(ROI_stats.study_path);

        contained_task_list = dir;
        
        num_files = length(contained_task_list);
        
        for file_idx = 3 : num_files
            
            task_name = contained_task_list(file_idx).name;
            
            all_task_names{file_idx-2} = task_name;
            
            task_to_match = ROI_stats.condition_name;
            
            task_match = strfind(task_name, task_to_match);
            
            if ~isempty(task_match)
                file_to_load = file_idx;
            end%if
                
        end% file loop
        
        ROI_stats.condition_name = contained_task_list(file_to_load).name;
        ROI_stats.study_path_design = 'R:\data_generated\human\fMRI_motor_imagery\New subject data storage\[subject_id]\NIFTI\[condition_name]';
        
        ROI_stats.study_path =          str_from_design(ROI_stats, ROI_stats.study_path_design);
           
        cd(ROI_stats.study_path);
        
        for r=1:length(ROI_list)
            
            
            ROI_stats.current_ROI =             ROI_list{r};
            ROI_stats.current_ROI_path =        [original_ROI_path '[current_ROI].nii'];
            ROI_path =                          str_from_design(ROI_stats, ROI_stats.current_ROI_path);
            contrast_string =                   'spmT_0001.nii';
            
            
            % HERE'S WHERE THE MAGIC HAPPENS
            raw_data{s, c, r} =     extract_stats_from_epi(ROI_path, contrast_string);
            
            % vanity check, prints progress
            check = numel( num2str(counter) );
            counter = counter + 1;
            switch check
                case 1
                    fprintf('\b');
                case 2
                    fprintf('\b');
                    fprintf('\b');
                    
                case 3
                    fprintf('\b');
                    fprintf('\b');
                    fprintf('\b');
            end
            fprintf('%d', counter)
        end
        
        % provides index for stats
        data_lookup{s, c} =     [ROI_stats.subject_id, ' ', ROI_stats.condition_name];
        
        
    end
end

fprintf('\r')


%% Curate desired statistics from raw contrast T-vals
% T-vals are returned in 91x109x91 arrays, so matrix indices should correspond to MNI XYZ-coords
display('*** CALCULATING AND CURATING STATISTICS ***')

% creates nested cell-structure for containing AB stats
% could be edited to do Control/SCI stats together, later
master_list.Subject =       [];
master_list.Condition =     [];
% add new stats to struct initialization
master_list.ROI =          struct('Name', [], 'Peak_Val', [], 'Peak_XYZ', []);


for s = 1:length(subject_list)
    for c = 1:length(paradigms)
        
        [subject, cond] =                    strtok(data_lookup{s, c});
        master_list(s, c).Subject =          subject;
        master_list(s, c).Condition =        cond;
        
        for r = 1:length(ROI_list)
            % === add new stat extractions here ===
            
            % finds value and location of max
            temp =                              cell2mat( raw_data(s, c, r) );
            [max_val, max_ind] =                max( temp(:) );
            [ind_X, ind_Y, ind_Z] =             ind2sub(size(temp), max_ind);
            
            master_list(s, c).ROI(r).Name =              ROI_list(r);
            master_list(s, c).ROI(r).Peak_Val =          max_val;
            master_list(s, c).ROI(r).Peak_XYZ =          [ind_X, ind_Y, ind_Z];
            
            
            % counts the number of active and significant voxels'
            active =                                  find(temp);
            active_count =                            length(active);
            master_list(s, c).ROI(r).Num_Active =     active_count;
            
            master_list(s, c).ROI(r).Active_Vals =    temp(active);
            [ind_X, ind_Y, ind_Z] =                   ind2sub(size(temp), active );
            master_list(s, c).ROI(r).Active_Locs =    [ind_X, ind_Y, ind_Z];
            
            
            %             [x, y, z] =                         ind2sub(size(temp), active);
            sig =                                       abs(temp) > 2.5;
            sig_count =                                 nnz(sig);
            
            ROI_stats.current_ROI =             ROI_list{r};
            ROI_stats.current_ROI_path =        [original_ROI_path '[current_ROI].nii'];
            ROI_path =                          str_from_design(ROI_stats, ROI_stats.current_ROI_path);
            ROI_file =                          load_nii(ROI_path);
            voxels =                            ROI_file.img;
            num_voxels =                        length( find(voxels) );
            
            sig_count = sig_count/num_voxels;
%             
%             %2015-10-12 added a frankly offensive hard-code division to change sig_count into a percentage of the new masked ROIs
%             if strcmp(ROI_list(r), 'masked_left_m1_15mm')
%                 sig_count = sig_count/1243;
%             end
%             if strcmp(ROI_list(r),'masked_left_s1_15mm')
%                 sig_count = sig_count/1008;
%             end
%             if strcmp(ROI_list(r),'masked_right_m1_15mm')
%                 sig_count = sig_count/913;
%             end
%             if strcmp(ROI_list(r),'masked_right_s1_15mm')
%                 sig_count = sig_count/952;
%             end
%             if strcmp(ROI_list(r),'MNI_Parietal_Sup_L')
%                 sig_count = sig_count/2065;
%             end
%             if strcmp(ROI_list(r),'MNI_Parietal_Sup_R')
%                 sig_count = sig_count/2222;
%             end
%             if strcmp(ROI_list(r),'MNI_Supp_Motor_Area_L_roi')
%                 sig_count = sig_count/2147;
%             end
%             if strcmp(ROI_list(r),'MNI_Supp_Motor_Area_R')
%                 sig_count = sig_count/2371;
%             end
%             if strcmp(ROI_list(r), 'MNI_Frontal_Sup_L')
%                 sig_count = sig_count/3599;
%             end
%             if strcmp(ROI_list(r), 'MNI_Frontal_Sup_R')
%                 sig_count = sig_count/4056;
%             end
            
            master_list(s, c).ROI(r).Num_Sig =       sig_count;
            
            sig =                                    find(sig);
            master_list(s, c).ROI(r).Sig_Vals =      temp(sig);
            [ind_X, ind_Y, ind_Z] =                  ind2sub(size(temp), sig );
            master_list(s, c).ROI(r).Sig_Locs =      [ind_X, ind_Y, ind_Z];
            
        end
        
    end
    
end




%% Analyze statistics
display('*** ISOLATING CURRENT-WORKSPACE STATS ***')

% extracts desired statistics into separate matrices
for s=1:size(master_list, 1)
    for c=1:size(master_list, 2)
        for r=1:length(ROI_list)
            
            ROI_peak_vals(r, s, c) =            master_list(s, c).ROI(r).Peak_Val;
            convert =                           2*master_list(s, c).ROI(r).Peak_XYZ;
            convert =                           [convert(1)-92, convert(2)-128, convert(3)-74];
            ROI_peak_locs{r, s, c} =            convert;
            
            ROI_active_count(r, s, c) =         master_list(s, c).ROI(r).Num_Active;
            ROI_sig_count(r, s, c) =            master_list(s, c).ROI(r).Num_Sig;
            
            ROI_active_vals{r, s, c} =          master_list(s, c).ROI(r).Active_Vals;
            
            convert =                           2*master_list(s, c).ROI(r).Active_Locs;
            convert =                           [convert(:, 1)-92, convert(:, 2)-128, convert(:, 3)-74];
            ROI_active_locs{r, s, c} =          convert;
            
            
            if ROI_sig_count(r, s, c) > 0
                ROI_sig_vals{r, s, c} =          master_list(s, c).ROI(r).Sig_Vals;
                
                convert =                        2*master_list(s, c).ROI(r).Sig_Locs;
                convert =                        [convert(:, 1)-92, convert(:, 2)-128, convert(:, 3)-74];
                ROI_sig_locs{r, s, c} =          convert;
            end
            
        end
    end
end


% Hard-coded transformation for converting matlab indices into MNI coordinates
output_struct.x_transform = [2 -92];
output_struct.y_transform = [2 -128];
output_struct.z_transform = [2 -74];


output_struct.master_list =              master_list;
output_struct.ROI_peak_vals =            ROI_peak_vals;
output_struct.ROI_peak_locs =            ROI_peak_locs;
output_struct.ROI_active_count =         ROI_active_count;
output_struct.ROI_active_vals =          ROI_active_vals;
output_struct.ROI_active_locs =          ROI_active_locs;
output_struct.ROI_sig_count =            ROI_sig_count;
output_struct.ROI_sig_vals =             ROI_sig_vals;
output_struct.ROI_sig_locs =             ROI_sig_locs;


end
