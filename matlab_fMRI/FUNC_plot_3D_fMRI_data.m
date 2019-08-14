% 2019-05-10 Dylan Royston
%
% Function to plot fMRI data in 3D space
%
%
%
%
%
%
%
%%

function output_struct = FUNC_plot_3D_fMRI_data(input_struct)

% extract inputs
point_vals =            input_struct.point_vals;
point_locs =            input_struct.point_locs;
cmap =                  input_struct.cmap;
clim =                  input_struct.clim;

voxel_scale =           160;

% create scatter
h = figure;
hold on;
scatter3(point_locs(:, 1), point_locs(:, 2), point_locs(:, 3), voxel_scale, point_vals, '*');
c = colorbar;
caxis(clim);
colormap(cmap);
xlabel('+Medial -Lateral');
ylabel('+Anterior -Posterior');
zlabel('+Superior -Inferior');
suplabel('T-value', 'yy');
set(gca, 'View', [-100 60]);

% highlight peak voxel
[peak_val, peak_idx] =  max(point_vals);
peak_loc =              point_locs(peak_idx, :);

scatter3(peak_loc(1), peak_loc(2), peak_loc(3), voxel_scale, 'k', 'filled');
line(xlim, [peak_loc(2) peak_loc(2)], [peak_loc(3) peak_loc(3)], 'Color', 'k', 'LineStyle', '--');
line([peak_loc(1) peak_loc(1)], ylim, [peak_loc(3) peak_loc(3)], 'Color', 'k', 'LineStyle', '--');
line([peak_loc(1) peak_loc(1)], [peak_loc(2) peak_loc(2)], zlim, 'Color', 'k', 'LineStyle', '--');

output_struct.figure_handle =   h;
output_struct.peak_loc =        peak_loc;

end% FUNCTION