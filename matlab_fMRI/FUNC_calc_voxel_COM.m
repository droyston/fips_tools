% 2019-08-08 Dylan Royston
%
% Function to calculate the center of mass (COM) of a given voxel cluster
%
%
%
%
%
%
%
%%

function output_struct = FUNC_calc_voxel_COM(voxel_vals, voxel_locs)

% hard-coded spatial range for M1/S1 cluster analysis (used for generating new blank image)
SM_range = [-80 20; -40 20; 0 100];

% % debug figure - raw voxels
% clearvars temp_in
% temp_in.point_vals = voxel_vals;
% temp_in.point_locs = voxel_locs;
% temp_in.cmap = 'jet';
% temp_in.clim = [2 6];
% temp_out = FUNC_plot_3D_fMRI_data(temp_in);

% calculate new image coordinates
x_range =               [min(voxel_locs(:, 1)):max(voxel_locs(:, 1))];
y_range =               [min(voxel_locs(:, 2)):max(voxel_locs(:, 2))];
z_range =               [min(voxel_locs(:, 3)):max(voxel_locs(:, 3))];

new_img =               NaN( length( SM_range(1, 1) : SM_range(1, 2) ),...
                        length( SM_range(2, 1) : SM_range(2, 2) ),...
                        length( SM_range(3, 1) : SM_range(3, 2) ) );

% insert cluster values into clean image
for point_idx = 1 : length(voxel_vals)
    
    point_coords =          voxel_locs(point_idx, :);
    x_idx =                 find( x_range == point_coords(1) );
    y_idx =                 find( y_range == point_coords(2) );
    z_idx =                 find( z_range == point_coords(3) );
    
    new_img(x_idx, y_idx, z_idx) = voxel_vals(point_idx);
    
end% FOR point_idx

% calculate COM
[xloc, yloc, zloc] =    COG(new_img);
rounded_idx =           [round(xloc), round(yloc), round(zloc)];
real_coords =           [x_range(rounded_idx(1)), y_range(rounded_idx(2)), z_range(rounded_idx(3))];


% identify matching voxel at COM coordinates
[C, ia, ib] =           intersect(voxel_locs, real_coords, 'rows');

output_struct.COM_loc =     real_coords;
output_struct.COM_val =     voxel_vals(ia);
output_struct.COM_idx =     ia;

end% FUNCTION