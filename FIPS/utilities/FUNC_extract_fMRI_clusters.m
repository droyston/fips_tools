% 2019-05-17 Dylan Royston
%
% Function to isolate and extract fMRI cluster activity
% Currently configured to run on M1 data
%
%
%
%
%
%
%%

function output_struct = FUNC_extract_fMRI_clusters(input_struct)

% initialize primary variables
initial_voxel_locs =        input_struct.voxel_locs;
initial_voxel_vals =        input_struct.voxel_vals;
sig_thresh =                input_struct.sig_thresh;
figure_flags =              input_struct.figure_flags;
plot_range =                input_struct.plot_range;

% find peak voxel
[peak_val, peak_idx] =      max(initial_voxel_vals);
peak_loc =                  [ initial_voxel_locs(peak_idx, 1) initial_voxel_locs(peak_idx, 2) initial_voxel_locs(peak_idx, 3) ];

% optional plot of initial raw voxel values
if figure_flags.voxel_scatter == 1
    
    input_struct.point_vals =   initial_voxel_vals;
    input_struct.point_locs =   initial_voxel_locs;
    input_struct.cmap =         'jet';
    input_struct.clim =         [sig_thresh 12];
    
    figure_handle =             FUNC_plot_3D_fMRI_data(input_struct);
    title('All M1');
    set(gcf, 'Position', [1929 576 560 420]);
end

%% define local cluster
% extract voxels in a sphere around the peak voxel
radius =                    25;

for point_idx = 1 : length(initial_voxel_locs)
    
    curr_point =                initial_voxel_locs(point_idx, :);
    distance(point_idx) =       sqrt( ( peak_loc(1) - curr_point(1) ).^2 + (peak_loc(2)-curr_point(2)).^2 + (peak_loc(3)-curr_point(3)).^2 );

end

target_voxels =             find(distance<radius);
sphere_vals =               initial_voxel_vals(target_voxels);
sphere_locs =               initial_voxel_locs(target_voxels, :);

% optional plot of sphere-contained voxels
if figure_flags.sphere_scatter == 1
    
    input_struct.point_vals =   sphere_vals;
    input_struct.point_locs =   sphere_locs;
    input_struct.cmap =         'jet';
    input_struct.clim =         [sig_thresh 12];
    
    figure_handle =             FUNC_plot_3D_fMRI_data(input_struct);
    title('25mm sphere');
    set(gcf, 'Position', [2505 576 560 420]);
end

% isolate voxels with significant activity
sphere_sig_voxels =         find(sphere_vals > sig_thresh);

% find and remove "outlier" voxels that aren't part of main cluster
sig_locs =                  sphere_locs(sphere_sig_voxels, :);
separation =                squareform(pdist(sig_locs));
average_dists =             mean(separation);
threshold =                 median(average_dists) + 2*std(average_dists);

% optional plot of cluster-voxel distance metrics
if figure_flags.cluster_distances == 1
    figure;
    subplot(2, 1, 1);
    imagesc(separation);
    c = colorbar;
    ylabel(c, 'Euclidean distance');
    title('Pairwise voxel distances');
    
    set(gcf, 'Position', [3081 108 727 888]);
    
    subplot(2, 1, 2);
    histogram(average_dists, 50, 'normalization', 'pdf');
    line([threshold threshold], ylim, 'Color', 'k', 'LineWidth', 2);
    xlabel('Distance');
    ylabel('Probability');
    
end

% extract "significant" voxels within sphere and blank outliers
outlier_voxels =            find(average_dists > threshold);

clean_cluster_locs =        sig_locs;
clean_cluster_locs(outlier_voxels, :) = [];

clean_cluster_vals =        sphere_vals(sphere_sig_voxels);
clean_cluster_vals(outlier_voxels) = [];

num_cluster_voxels =        length(clean_cluster_vals);

% compute and store cluster data

%% CALCULATE CENTER OF GRAVITY
% generate new 3D image by inserting T-vals back into spatial coords

x_range =                   [min(clean_cluster_locs(:, 1)):max(clean_cluster_locs(:, 1))];
y_range =                   [min(clean_cluster_locs(:, 2)):max(clean_cluster_locs(:, 2))];
z_range =                   [min(clean_cluster_locs(:, 3)):max(clean_cluster_locs(:, 3))];

new_img =                   NaN( length( plot_range(1, 1) : plot_range(1, 2) ),...
                            length( plot_range(2, 1) : plot_range(2, 2) ),...
                            length( plot_range(3, 1) : plot_range(3, 2) ) );

% insert voxel vals into new cluster image
for point_idx = 1 : num_cluster_voxels
    
    point_coords =              clean_cluster_locs(point_idx, :);
    x_idx =                     find( x_range == point_coords(1) );
    y_idx =                     find( y_range == point_coords(2) );
    z_idx =                     find( z_range == point_coords(3) );
    
    new_img(x_idx, y_idx, z_idx) = clean_cluster_vals(point_idx);
    
end% FOR, point_idx

% calculate center of gravity
[xloc, yloc, zloc] =        COG(new_img);
rounded_idx =               [round(xloc), round(yloc), round(zloc)];
real_coords =               [x_range(rounded_idx(1)), y_range(rounded_idx(2)), z_range(rounded_idx(3))];

if figure_flags.cluster_scatter == 1
    input_struct.point_vals =   clean_cluster_vals;
    input_struct.point_locs =   clean_cluster_locs;
    input_struct.cmap =         'jet';
    input_struct.clim =         [sig_thresh 12];
    
    fig_handle =                FUNC_plot_3D_fMRI_data(input_struct);
    title(['Primary cluster (n = ' num2str(num_cluster_voxels) ')']);
    set(gcf, 'Position', [2231 63 560 420]);
    
    xlim([-80 20])
    ylim([-40 20]);
    zlim([0 78]);
    
    % plot CoM in cluster
    scatter3(real_coords(1), real_coords(2), real_coords(3), [], 'k', 'filled');
    line(xlim, [real_coords(2) real_coords(2)], [real_coords(3) real_coords(3)], 'Color', 'k', 'LineStyle', '--');
    line([real_coords(1) real_coords(1)], ylim, [real_coords(3) real_coords(3)], 'Color', 'k', 'LineStyle', '--');
    line([real_coords(1) real_coords(1)], [real_coords(2) real_coords(2)], zlim, 'Color', 'k', 'LineStyle', '--');
end

% store outputs
output_struct.peak =    [peak_val, peak_loc];
output_struct.volume =   num_cluster_voxels;
output_struct.locs =     clean_cluster_locs;
output_struct.vals =     clean_cluster_vals;
output_struct.COM =      real_coords;
output_struct.image =    new_img;


end% FUNCTION