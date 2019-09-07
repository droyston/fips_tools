% 2019-08-08 Dylan Royston
%
% Clean version of SHELL_group_level_beta_maps
% Original was rush-scripted for VA report, restarting for updated manuscript analyses
%
% Pulls data from both group-level images (can also create new images)
%
% Currently hard-coding as a script to produce results, should come back and functionalize for smoother operations
%
% Begins with data extraction;
% new image calculation moved to SCRIPT_make_specific_group_CM_images
% manual move-hub calculation moved to SCRIPT_make_group_move_hub
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

movement_list =     {'Wrist', 'Hand', 'Fingers'};

cond_names =        {'Simple', 'Goal', 'Audio', 'Stim'};

% path to previously-saved hub coordinates
hub_path =          fullfile(active_data_dir, 'AB_all_MO', 'AB_all_move_hub_locs.mat');


%% Extract volumetric voxel data from group-level beta maps (first from Overt)

disp('*** EXTRACTING VOLUMETRIC DATA ***');

clearvars ROI_stats

% set_list = 'AB_all_MO';
% set_list = 'all';
% set_list = 'type_sensory';
% set_list = 'type_motor';

set_list =  'type_MCF';
% set_list = 'type_MCH';
% set_list = 'type_MCW';

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

map_type = 'B';


% load group Tmaps
for set_idx = 1 : length(set_list)
    
    set_name =      set_list{set_idx};
    
    disp(['*** PROCESSING SET: ' set_name ' ***']);
    
    output_data =    FUNC_load_data_from_group_images(active_data_dir, set_name, ROI_path_list{1}, ROI_name_list, map_type);
    
    ROI_stats{set_idx} = output_data;
    
end% FOR set_idx

disp('*** DONE ***');

%% cluster extraction (current method: custom cluster-extraction for each ROI)
% also needs to organize data in a coherent way for plotting (multiple boxes for Stim might be tricky)

loaded_hub_data =     load(hub_path);
move_hub_locs =       loaded_hub_data.hub_coords;

real_cond_counter =   1;

output_beta_vals =      cell(2, 4);
temp_vals  =            cell(2, 2);

group_counter = 1;

for set_idx = 1 : length(set_list)
    
    curr_set_data =     ROI_stats{set_idx};
    
    is_all =            size(curr_set_data, 1);
    
    subgroup_vals =     cell(1, 2);
    
    for ROI_idx = 1 : 2
        
        curr_hub_locs =     move_hub_locs{ROI_idx};
        
        for cond_idx = 1 : size(curr_set_data, 1)
            
            curr_ROI_vals =         squeeze( curr_set_data(cond_idx, ROI_idx).active_vals );
            
            curr_ROI_locs =         squeeze( curr_set_data(cond_idx, ROI_idx).active_coords );
            
            [C, ia, ib] =           intersect(curr_ROI_locs, curr_hub_locs, 'rows');
            
            valid_vals =            curr_ROI_vals(ia);
            
            if is_all == 3
                output_beta_vals{ROI_idx, cond_idx} = valid_vals;
            else
                subgroup_vals{ROI_idx} = valid_vals;
            end
                        
        end% FOR cond_idx
        
        
    end% FOR ROI_idx
    
    if is_all ~= 3
        group_vals{group_counter} = subgroup_vals;
        group_counter = group_counter + 1;
    end
    
end% FOR set_idx

% dumb and probably extraneous data-manipulation to get Stim sets where they belong
swapper = cell(2, 2);
swapper{1, 1} = group_vals{1}{1};
swapper{1, 2} = group_vals{2}{1};
swapper{2, 1} = group_vals{1}{2};
swapper{2, 2} = group_vals{2}{2};


output_beta_vals(1, 4) = swapper(1, 1);
output_beta_vals(1, 5) = swapper(1, 2);

output_beta_vals(2, 4) = swapper(2, 1);
output_beta_vals(2, 5) = swapper(2, 2);

%% Plot beta values for each condition


figure;

curr_colormap =         jet(length(cond_names)+1);

new_cond_names =        {cond_names{:} 'Stim ref'};

for ROI_idx = 1 : 2

subplot(2, 1, ROI_idx); hold on;
line([0.5 5.5], [0 0], 'Color', 'k', 'LineStyle', '--');
    

values_to_plot =            output_beta_vals(ROI_idx, 1:5);
    
clearvars input_struct
input_struct.data_cells =   values_to_plot;
input_struct.cmap =         curr_colormap;
input_struct.set_labels =   new_cond_names;
input_struct.new_fig_flag = 0;
FUNC_boxplot_from_cells(input_struct);
ylabel('\beta values');

% sub_vals =                  output_beta_vals{ROI_idx, 4};

% loc_mat =                   repmat(4, length(sub_vals{2}), 1 );

% scatter(loc_mat, sub_vals{2}, [], 'r');

% boxplots are tricky for this, maybe notBoxPlot, currently scatter
% boxplot(sub_vals{1}, 'positions', 4, 'labels', cond_names(4));

[pvals, pairs] = FUNC_full_stat_compare(values_to_plot, 'ranksum');


end






































