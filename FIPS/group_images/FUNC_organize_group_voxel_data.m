% 2019-09-05 Dylan Royston
%
% Subfunction to organize voxel stats for SHELL_analyze_CM_clusters (and related shell scripts)
%
%
%
%
%
%
%
%%

function output_data = FUNC_organize_group_voxel_data(input_data)

sig_T_thresh =          2;


ROI_stats =         input_data;

num_sets =          size(ROI_stats, 2);

num_conds =          size(ROI_stats{1}, 1);
num_ROIs =          size(ROI_stats{1}, 2);

output_sig_vals =      cell(num_ROIs, num_conds);
temp_vals  =            cell(2, 2);

group_counter = 1;

% SM_range = [-80 20; -40 20; 0 100];
clearvars output_t_vals output_b_vals subgroup_t_vals subgroup_b_vals group_t_vals group_b_vals


for set_idx = 1 : num_sets
    
    % get T values
    curr_t_data =     ROI_stats{1, set_idx};
    
    curr_b_data =       ROI_stats{2, set_idx};
    
    is_all =            size(curr_t_data, 1);
    
    subgroup_t_vals =     cell(1, 2);
    subgroup_b_vals =     cell(1, 2);
    
    
    for ROI_idx = 1 : num_ROIs
        
        %         curr_hub_locs =     move_hub_locs{ROI_idx};
        
        for cond_idx = 1 : num_conds
            
            curr_ROI_vals =         squeeze( curr_t_data(cond_idx, ROI_idx).active_vals );
            
            curr_ROI_locs =         squeeze( curr_t_data(cond_idx, ROI_idx).active_coords );
            
            pos_sig_idx =           find(curr_ROI_vals > sig_T_thresh);
            
            
            sig_T_vals =            curr_ROI_vals(pos_sig_idx);
            sig_locs =              curr_ROI_locs(pos_sig_idx, :);
            
            
            all_beta_vals =         squeeze( curr_b_data(cond_idx, ROI_idx).active_vals);
            
            sig_beta_vals =         all_beta_vals(pos_sig_idx);
            
            
            
            switch is_all
                case 5
                    output_t_vals{ROI_idx, cond_idx} = sig_T_vals;
                    output_b_vals{ROI_idx, cond_idx} = sig_beta_vals;
                    output_locs{ROI_idx, cond_idx} = sig_locs;
                case 3
                %                 output_sig_vals{ROI_idx, cond_idx} = output_struct;
                output_t_vals{ROI_idx, cond_idx} = sig_T_vals;
                output_b_vals{ROI_idx, cond_idx} = sig_beta_vals;
                
                output_locs{ROI_idx, cond_idx} = sig_locs;
                
                otherwise
                %                 subgroup_vals{ROI_idx} = output_struct;
                subgroup_t_vals{ROI_idx} = sig_T_vals;
                subgroup_b_vals{ROI_idx} = sig_beta_vals;
                
                subgroup_locs{ROI_idx} = sig_locs;
                
            end% SWITCH
            
        end% FOR cond_idx
        
        
    end% FOR ROI_idx
    
    switch is_all
        case 3
        case 5
        otherwise
        group_t_vals{group_counter} = subgroup_t_vals;
        group_b_vals{group_counter} = subgroup_b_vals;
        
        group_locs{group_counter} = subgroup_locs;
        
        group_counter = group_counter + 1;
    end
    
end% FOR set_idx








if ~isempty(subgroup_t_vals{1})
   

t_swapper = cell(2, 2);
t_swapper{1, 1} = group_t_vals{1}{1};
t_swapper{1, 2} = group_t_vals{2}{1};
t_swapper{2, 1} = group_t_vals{1}{2};
t_swapper{2, 2} = group_t_vals{2}{2};

output_t_vals(1, 4) = t_swapper(1, 1);
output_t_vals(2, 4) = t_swapper(2, 1);

output_t_vals(1, 5) = t_swapper(1, 2);
output_t_vals(2, 5) = t_swapper(2, 2);



b_swapper = cell(2, 2);
b_swapper{1, 1} = group_b_vals{1}{1};
b_swapper{1, 2} = group_b_vals{2}{1};
b_swapper{2, 1} = group_b_vals{1}{2};
b_swapper{2, 2} = group_b_vals{2}{2};

output_b_vals(1, 4) = b_swapper(1, 1);
output_b_vals(2, 4) = b_swapper(2, 1);

output_b_vals(1, 5) = b_swapper(1, 2);
output_b_vals(2, 5) = b_swapper(2, 2);



loc_swapper = cell(2, 2);
loc_swapper{1, 1} = group_locs{1}{1};
loc_swapper{1, 2} = group_locs{2}{1};
loc_swapper{2, 1} = group_locs{1}{2};
loc_swapper{2, 2} = group_locs{2}{2};

output_locs(1, 4) = loc_swapper(1, 1);
output_locs(2, 4) = loc_swapper(2, 1);

output_locs(1, 5) = loc_swapper(1, 2);
output_locs(2, 5) = loc_swapper(2, 2);

end


output_data.t_vals = output_t_vals;
output_data.b_vals = output_b_vals;
output_data.locs = output_locs;







end% FUNC