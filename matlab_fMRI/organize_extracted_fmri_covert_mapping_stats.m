% 2015-10-26 Dylan Royston
%
%
% Rewritten from organize_extracted-fmri_stats.m to be dedicated to Covert Mapping analysis
% When SCI subjects are added, procedures from above can be re-implemented
%
%
%
% === UPDATES ===
% 2018-04-30 Royston: fixed a stupid code where 1 ROI was assumed to be all
%
%
%
%% Configure inputs from structure

function  output_struct = organize_extracted_fmri_covert_mapping_stats(input_struct)

% reads inputs
original_ROI_path =     input_struct.ROI_path;
paradigms =             input_struct.paradigms;
ROI_list =              input_struct.ROI_list;
study_path =            input_struct.study_path;
subject_list =          input_struct.subject_list;
subject_thresholds =    input_struct.subj_thresh;


% hard-codes paradigm information
for p=1:length(paradigms)
    
    current_paradigm = paradigms{p};
    paradigm_design(p).paradigm = current_paradigm;
    
    %if covert paradigms
    if length(strfind( current_paradigm, 'covert') ) > 0
        paradigm_design(p).conditions =         {'Simple', 'Goal', 'Audio', 'Stim'};
        paradigm_design(p).contrast_number =    {'0001', '0002', '0003', '0004'};
    end
    
    % if overt motor paradigm
    if strcmp(current_paradigm, 'Motor_overt')
        paradigm_design(p).conditions =         {'Lip', 'Wrist', 'Hand', 'Fingers', 'Ankle'};
        paradigm_design(p).contrast_number =    {'0001', '0002', '0003', '0004', '0005'};
    end
    
    % if overt sensory paradigms
    if length(strfind( current_paradigm, 'Sensory_overt') ) > 0
        paradigm_design(p).conditions =         {'Stim'};
        paradigm_design(p).contrast_number =    {'0001'};
    end
    
    % if OLD paradigms (attempted/imagined)
    if length( strfind(current_paradigm, 'attempted') ) > 0
        paradigm_design(p).conditions =         {'Attempted'};
        paradigm_design(p).contrast_number =    {'0001'};        
    end
    
    if length( strfind(current_paradigm, 'imagined') ) > 0
        paradigm_design(p).conditions =         {'Imagined'};
        paradigm_design(p).contrast_number =    {'0001'};        
    end
    
end


% loads all MNI ROIs if 'all' is passed as ROI list
% 2018-04-30 Royston
% if length(ROI_list) == 1
if strcmp(ROI_list{1}, 'all')
    all_ROIs = 1;
else
    all_ROIs = 0;
end

if all_ROIs == 1
    
    all_ROI_data = dir(original_ROI_path);
    
    for r = 1:length(all_ROI_data)
        all_ROIs_full{r} = all_ROI_data(r).name;
    end
    
    for r=3:length(all_ROI_data)
        ROI_list{r-2}  = strtok(all_ROIs_full{r}, '.');
    end
end

output_struct.readable_ROIs = ROI_list;


%% Extract T-vals from SPM_T contrast files
% extracts raw data into Matlab-friendly formatting
display('--- EXTRACTING RAW DATA FROM NII FILES ---');

% print progress
% 224 is hard-coded as the number of conditions/paradigm in a full CM data set
% 4 per 5 covert, 1 per 3 sensory overt, 5 per 1 motor overt
total = length(subject_list)*224;
fprintf('%d / ', total)
fprintf('\n')
counter = 0;

% initializes holder cell array for raw data arrays, to avoid mis-sized arrays
top_tier = cell( length(subject_list), length(paradigms) );



for s=1:length(subject_list)
    
    
    
    % reorients code to be condition-centric
    for p=1:length(paradigms)
        
        % sets current paradigm information
        current_paradigm =      paradigms{p};
        conditions =            paradigm_design(p).conditions;
        contrast_number =       paradigm_design(p).contrast_number;
        
        % initializes data array for current paradigm
        raw_data = cell( length(conditions), length(ROI_list) );
        
        % loops through conditions
        for c=1:length(conditions)
            
            % initializes ROI_stats structure information
            ROI_stats.subject_id =          subject_list{s};
            ROI_stats.condition_name =      conditions{c};
            ROI_stats.current_paradigm =    current_paradigm;          
            ROI_stats.study_path_design =   study_path; 
            ROI_stats.study_path =          str_from_design(ROI_stats, ROI_stats.study_path_design);
            
            cd(ROI_stats.study_path);
 
            % loops through ROIs
            for r=1:length(ROI_list)
                
                
                ROI_stats.current_ROI =     ROI_list{r};
                
                ROI_stats.current_ROI_path = [original_ROI_path '[current_ROI].nii'];
                ROI_path =                  str_from_design(ROI_stats, ROI_stats.current_ROI_path);
                
                % sets correct contrast file name for current condition
                contrast_string =           sprintf('spmT_%s.nii', contrast_number{c} );
                
                
                % HERE'S WHERE THE MAGIC HAPPENS
                raw_data{c, r} =     extract_stats_from_epi(ROI_path, contrast_string);
                
                
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
                
            end % ROI loop       
            
            
        end % condition loop
        
        
        % stores each paradigm's data
        top_tier{s, p} = raw_data;
        
        
    end % paradigm loop
 
end % subject loop

%% Curate desired statistics from raw contrast T-vals
% T-vals are returned in 91x109x91 arrays, so matrix indices should convert to MNI XYZ-coords
display('--- CALCULATING AND CURATING STATISTICS ---')

% creates nested cell-structure for containing  stats
master_list.Subject =       [];
master_list.Paradigm =      [];
master_list.Condition =     [];

% add new stats to struct initialization
master_list.ROI =          struct('Name', [], 'Peak_Val', [], 'Peak_XYZ', []);


for s=1:length(subject_list)
    
    for p=1:length(paradigms)
        
        % sets current paradigm information
        current_paradigm =      paradigms{p};
        conditions =            paradigm_design(p).conditions;
        
        
        for c=1:length(conditions)
            
            master_list(s, p, c).Subject =              subject_list(s);
            master_list(s, p, c).Paradigm =             paradigms(p);
            master_list(s, p, c).Condition =            conditions(c);
            
            for r=1:length(ROI_list)
                % === add new stat extractions here ===
                
                % finds value and location of max
                box_1 =                             top_tier(s, p);
                box_2 =                             (box_1{:});
                voxel_data =                        cell2mat( box_2(c, r) );
                [max_val, max_ind] =                max( voxel_data(:) );
                [ind_X, ind_Y, ind_Z] =             ind2sub(size(voxel_data), max_ind);
                
                master_list(s, p, c).ROI(r).Name =              ROI_list(r);
                master_list(s, p, c).ROI(r).Peak_Val =          max_val;
                master_list(s, p, c).ROI(r).Peak_XYZ =          [ind_X, ind_Y, ind_Z];
                
%                 test_COM =                                      centerOfMass(voxel_data);
                
                % counts the number of active and significant voxels
                active =                            find(voxel_data);
                active_count =                      length(active);
                master_list(s, p, c).ROI(r).Num_Active =    active_count;
                
                master_list(s, p, c).ROI(r).Active_Vals =       voxel_data(active);
                [ind_X, ind_Y, ind_Z] =                         ind2sub(size(voxel_data), active );
                master_list(s, p, c).ROI(r).Active_Locs =    [ind_X, ind_Y, ind_Z];
                
                
                % [x, y, z] =                         ind2sub(size(temp), active);
%                 sig =                                       voxel_data > 2.5;
                
                sig =                                       voxel_data > subject_thresholds(s);

%                 sig =                                       voxel_data > 5.5;
%                 sig =                                       abs(voxel_data) > 2.5;
                sig_count =                                 nnz(sig);
                
                ROI_stats.current_ROI =             ROI_list{r};
                ROI_stats.current_ROI_path =        [original_ROI_path '[current_ROI].nii'];
                ROI_path =                          str_from_design(ROI_stats, ROI_stats.current_ROI_path);
                ROI_file =                          load_nii(ROI_path);
                voxels =                            ROI_file.img;
                num_voxels =                        length( find(voxels) );
                
                sig_count =                         sig_count/num_voxels;
                

                
                master_list(s, p, c).ROI(r).Num_Sig =       sig_count;
                
                sig =                                       find(sig);
                master_list(s, p, c).ROI(r).Sig_Vals =      voxel_data(sig);
                [ind_X, ind_Y, ind_Z] =                     ind2sub(size(voxel_data), sig );
                master_list(s, p, c).ROI(r).Sig_Locs =      [ind_X, ind_Y, ind_Z];
                
            end % ROI loop
            
        end % condition loop
        
    end % paradigm loop
    
end % subject loop




%% Analyze statistics
display('--- ISOLATING CURRENT-WORKSPACE STATS ---')

% extracts desired statistics into separate ROI-centric matrices
for s=1:length(subject_list)
    
    for p=1:length(paradigms)
        
        % sets current paradigm information
        conditions =            paradigm_design(p).conditions;
        
        for c=1:length(conditions)
            
            for r=1:length(ROI_list)
                
                ROI_peak_vals(r, s, p, c) =         master_list(s, p, c).ROI(r).Peak_Val;
                convert =                           2*master_list(s, p, c).ROI(r).Peak_XYZ;
                convert =                           [convert(1)-92, convert(2)-128, convert(3)-74];
                ROI_peak_locs{r, s, p, c} =         convert;
                
                ROI_active_count(r, s, p, c) =     master_list(s, p, c).ROI(r).Num_Active;
                ROI_sig_count(r, s, p, c) =        master_list(s, p, c).ROI(r).Num_Sig;
                
                ROI_active_vals{r, s, p, c} =       master_list(s, p, c).ROI(r).Active_Vals;
                
                convert =                           2*master_list(s, p, c).ROI(r).Active_Locs;
                convert =                           [convert(:, 1)-92, convert(:, 2)-128, convert(:, 3)-74];
                ROI_active_locs{r, s, p, c} =       convert;
                
                
                if ROI_sig_count(r, s, p, c) > 0
                    ROI_sig_vals{r, s, p, c} =          master_list(s, p, c).ROI(r).Sig_Vals;
                    
                    convert =                           2*master_list(s, p, c).ROI(r).Sig_Locs;
                    convert =                           [convert(:, 1)-92, convert(:, 2)-128, convert(:, 3)-74];
                    ROI_sig_locs{r, s, p, c} =          convert;
                end
                
            end % ROI loop
            
        end % condition loop
        
    end % paradigm loop
    
end % subject loop


%% Create output structure

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
output_struct.paradigm_design =          paradigm_design;


end
