% 2019-08-08 Dylan Royston
%
% Function to calculate discrete clusters out of specified voxel values/locations
%
%
%
%
%
%
%
%%

function output_struct = FUNC_generate_fMRI_cluster(input_struct)

all_vals =              input_struct.voxel_vals;
all_locs =              input_struct.voxel_locs;

make_figs =             input_struct.make_figures;

sig_thresh =            input_struct.sig_thresh;


radius =                25;

% % extract voxels from around peak value
% identify peak voxel
[peak_val, peak_idx] = max(all_vals);
peak_loc =             all_locs(peak_idx, :);

% calculate distance between voxels and peak, pull voxels within radius
for point_idx = 1 : length(all_vals)
    
    curr_point =            all_locs(point_idx, :);
    distance(point_idx) =   sqrt( ( peak_loc(1) - curr_point(1) ).^2 + (peak_loc(2)-curr_point(2)).^2 + (peak_loc(3)-curr_point(3)).^2 );
    
end% FOR point_idx

target_voxel_idx =     find(distance < radius);
sphere_vals =          all_vals(target_voxel_idx);
sphere_locs =          all_locs(target_voxel_idx, :);



% % limit to voxels above significance threshold
sphere_sig_idx =      find(sphere_vals > sig_thresh);
sig_locs =            sphere_locs(sphere_sig_idx, :);
separation =          squareform(pdist(sig_locs));
average_dists =       mean(separation);
outlier_idx =         find( isoutlier(average_dists) );



clean_cluster_locs =  sig_locs;
clean_cluster_locs(outlier_idx, :) = [];

clean_cluster_vals =  sphere_vals(sphere_sig_idx);
clean_cluster_vals(outlier_idx) = [];
%


% preserve subset-indexing of output-cluster within input-voxels
new_cluster_idx =     target_voxel_idx(sphere_sig_idx);
new_cluster_idx(outlier_idx) = [];

% additionally calculate COM of new cluster
temp_out =              FUNC_calc_voxel_COM(clean_cluster_vals, clean_cluster_locs);

do_figures = ~isempty( find(make_figs == 1) );

if do_figures == 1
    
    if make_figs(1)==1
        % % debug figure - raw values
        clearvars temp_in output_struct
        temp_in.point_vals = all_vals;
        temp_in.point_locs = all_locs;
        temp_in.cmap =      'jet';
        temp_in.clim =      [2 6];
        output_struct =         FUNC_plot_3D_fMRI_data(temp_in);
    end
    
    if make_figs(2)==1
        % % debug figure - sphere values
        clearvars temp_in output_struct
        temp_in.point_vals = sphere_vals;
        temp_in.point_locs = sphere_locs;
        temp_in.cmap =      'jet';
        temp_in.clim =      [2 6];
        output_struct =     FUNC_plot_3D_fMRI_data(temp_in);
    end
    
    if make_figs(3)==1
        % debug figure - cluster values
        clearvars temp_in output_struct
        temp_in.point_vals = clean_cluster_vals;
        temp_in.point_locs = clean_cluster_locs;
        temp_in.cmap =      'jet';
        temp_in.clim =      [2 6];
        output_struct =     FUNC_plot_3D_fMRI_data(temp_in);
        line_handles =          FUNC_draw_3D_intersect(gcf, temp_out.COM_loc);
    end
    
end

output_struct.cluster_vals =        clean_cluster_vals;
output_struct.cluster_locs =        clean_cluster_locs;
output_struct.cluster_idx =         new_cluster_idx;
output_struct.COM_loc =             temp_out.COM_loc;
output_struct.COM_val =             temp_out.COM_val;
output_struct.COM_idx =             temp_out.COM_idx;


end% FUNCTION