
% 2019-05-01 Dylan Royston
%
% New sandbox code to test out updated fMRI analysis
% Currently testing different end-stage metrics while BIDS processing gets debugged
%
%
%
%
%
%
%
%
%% 1. Set up variables for processing
clear;
clc;

display('*** INITIALIZING VARIABLES ***');

% flags
figure_flag =           1;% 0 = don't save, 1 = save
ROI_path_flag =         0;% 0 = standardized, 1 = custom
% analysis_method =       'mean';% can be 'indiv' for individual subjects, or 'mean' for across-subject analysis
analysis_method =       'indiv';% can be 'indiv' for individual subjects, or 'mean' for across-subject analysis
reprocess_data =        0;


% plot flags
bar_plots =         0;
scatter_plots =     1;
stat_to_plot =      'peak';
% stat_to_plot =      'vol';


% file path to subject folders
if isunix
    %     study_path =        '/home/dar147/Desktop/test_data/[subject_id]/NIFTI/[current_paradigm]';
    study_path =        '/home/dar147/data/rnel-fs-1/data_generated/human/covert_mapping/SUBJECT_DATA_STORAGE/[subject_id]/NIFTI/[current_paradigm]';
else
    study_path =        'R:\data_generated\human\covert_mapping\SUBJECT_DATA_STORAGE\[subject_id]\NIFTI\[current_paradigm]';
end
% study_path =        'R:\data_generated\human\covert_mapping\SUBJECT DATA STORAGE\[subject_id]\FunctionalData\[current_paradigm]';

% study_path =        'C:\Users\hrnel\Documents\MATLAB\fMRI Analysis\fMRI Analysis Storage\Renamed Folders\[subject_id]\NIFTI\[current_paradigm]\';

% list of subjects to process
% subject_list =          {'CMC01', 'CMC03', 'CMC04', 'CMC05', 'CMC07', 'CMC10', 'CMC11', 'CMC12', 'CMC13', 'CMC14', 'CMC15', 'CMC17',...
%                         'CMC18', 'CMC19', 'CMC22', 'CMC23', 'CMC24', 'CMC25', 'CMC26', 'CMC27',...
%                         'CMS01', 'CMS02', 'CMS03', 'CMS04', 'CMS07', 'CMS13'};
subject_list =          {'CMC01', 'CMC03', 'CMC04', 'CMC05', 'CMC07', 'CMC10', 'CMC12', 'CMC13', 'CMC14',...
                        'CMC18', 'CMC23', 'CMC24', 'CMC25', 'CMC26', 'CMC27',...
                        'CMS01', 'CMS02', 'CMS03', 'CMS04', 'CMS06', 'CMS07', 'CMS13'};




% subject_list =          {'CMC01', 'CMC03', 'CMC05', 'CMC07', 'CMC10', 'CMC12', 'CMC13', 'CMC14', 'CMC17'};

% subject_list =          {'CMC10', 'CMC11', 'CMC12', 'CMC13', 'CMC14', 'CMC15', 'CMC17'};
% subject_list =          {'CMS01', 'CMS02', 'CMS03'};
% subject_list =          {'CMC03'};
% subject_list =          {'CMC03', 'CMC17'};


% subject_list =          {'NC01', 'NC02', 'NC03', 'NC04', 'NC05', 'NC06', 'NC07', 'NC08', 'NC09', 'NC10', 'NC11', 'NC12', 'NC13', 'NC14'};

num_subjects =          length(subject_list);

% paradigms = {'Motor_covert_fingers'};
% plaintext_paradigms = {'Motor Covert Fingers'};


% list of conditions to process
% paradigms = {'Motor_covert_fingers', 'Motor_covert_hand', 'Motor_covert_wrist', 'Motor_overt',...
%     'Sensory_covert_fingers', 'Sensory_covert_wrist'};

paradigms = {'Motor_overt'};

task_conditions = {'Lip', 'Wrist', 'Hand', 'Fingers', 'Ankle'};

num_paradigms = length(paradigms);
%
% plaintext_paradigms = {'Motor Covert Fingers', 'Motor Covert Hand', 'Motor Covert Wrist', 'Motor Overt',...
%     'Sensory Covert Fingers', 'Sensory Covert Wrist'};
% plaintext_paradigms = {'Sensory Overt Fingers'};
%


% ALL
% paradigms = {'Motor_covert_fingers', 'Motor_covert_hand', 'Motor_covert_wrist', 'Motor_overt',...
%     'Sensory_covert_fingers', 'Sensory_covert_wrist',...
%     'Sensory_overt_fingers', 'Sensory_overt_hand', 'Sensory_overt_wrist'};

% plaintext_paradigms = {'Motor Covert Fingers', 'Motor Covert Hand', 'Motor Covert Wrist', 'Motor Overt',...
%     'Sensory Covert Fingers', 'Sensory Covert Wrist',...
%     'Sensory Overt Fingers', 'Sensory Overt Hand', 'Sensory Overt W% 
% for cond_idx = 1 : 5
%     
%     
%     current_
% 
%     
%     
%     
%     
%     
% end


% paradigms = {'Motor_covert_hand', 'Motor_covert_wrist', 'Motor_overt','Sensory_covert_wrist'};

% plaintext_paradigms = {'Motor Covert Hand', 'Motor Covert Wrist', 'Motor Overt','Sensory Covert Wrist'};

% establishes custom class/structure for subject/condition/ROI data structure
ROI_stats =             ROI_stats_class;

% Sets which ROIs to be analyzed (calibrated for MNI regions
% Individual data can be analyzed similarly but may require inverse-normalization transformation matrix
% ROI_list =              {'MNI_Precentral_L_ROI', 'MNI_Postcentral_L_ROI', 'MNI_Supp_Motor_Area_L_ROI', 'MNI_Parietal_Combined_L', ...
%     'MNI_Precentral_R', 'MNI_Postcentral_R', 'MNI_Supp_Motor_Area_R', 'MNI_Parietal_Combined_R'};
% ROI_list = {'MNI_Precentral_L_ROI', 'MNI_Postcentral_L_ROI'};

% ROI_list = {'masked_hand_knob_10mm_resave', 'm1_midline_resave'};
ROI_list = {'all_m1_dilated'};


% plaintext_ROIs =        {'L Precentral', 'L Postcentral', 'L SMA', 'L PPC', 'R Precentral', 'R Postcentral', 'R SMA', 'R PPC'};
% plaintext_ROIs =        {'Motor cortex', 'Somatosensory cortex'};
% plaintext_ROIs =            {'Hand knob', 'Midline'};
plaintext_ROIs =            {'Motor cortex'};

num_ROI =               length(ROI_list);

if isunix
    ROI_path =              '/home/dar147/data/rnel-fs-1/data_generated/human/covert_mapping/CM_Analysis_Tools/ROI/marsbar-aal-0.2_NIFTIS/';
    ROI_path =              '/home/dar147/data/rnel-fs-1/data_generated/human/covert_mapping/CM_Analysis_Tools/ROI/Custom ROIs/';
else
%     ROI_path =              'R:\data_generated\human\covert_mapping\CM_Analysis_Tools\ROI\marsbar-aal-0.2_NIFTIS\';
        ROI_path =              'R:\data_generated\human\covert_mapping\CM_Analysis_Tools\ROI\Custom ROIs\';
end

% ======================================== Stat extraction =================================================


% % 2016-07-06 Royston: implementing data-saving and loading protocol
if isunix
    save_path =         '/home/dar147/data/rnel-fs-1/data_generated/human/covert_mapping/SUBJECT_DATA_STORAGE/PROCESSED_DATA/';
else
    save_path =         'R:\data_generated\human\covert_mapping\SUBJECT_DATA_STORAGE\PROCESSED_DATA\';
end


% sets up inputs for organization function
metadata_struct.subject_list =         subject_list;
metadata_struct.paradigms =            paradigms;
metadata_struct.ROI_list =             ROI_list;
metadata_struct.ROI_path =             ROI_path;
metadata_struct.study_path =           study_path;
metadata_struct.subj_thresh =          [5.0393 4.8459 4.6165 4.8746 5.0260 4.9083 ...
                                        5.1143 4.7825 4.8378 4.8417 4.9849 4.8168 5.0126 4.9026 4.9161...
                                        5.0704 4.9617 5.0661 4.8525 4.8611 4.9508 4.7406];
loaded_data =       Load_Preproc_fMRI_Data(metadata_struct, save_path);

if ~exist('reprocess_data', 'var')
    reprocess_data =    loaded_data.reprocess_data;
end

if reprocess_data == 1
    
    display('*** EXTRACTING STATS FROM CONTRAST FILES ***')
    
    % extracts and organizes data from spmT contrast files
    data_struct =     organize_extracted_fmri_covert_mapping_stats(metadata_struct);
        Save_Preproc_fMRI_Data(data_struct, metadata_struct, save_path, reprocess_data);
    
else
    data_struct =       loaded_data.data_struct;
end

% hard-coded transformations, not needed for anything
% x_transform =                       output_struct.x_transform;
% y_transform =                       output_struct.y_transform;
% z_transform =                       output_struct.z_transform;

% organizes function outputs, indexed by ROI/subject/paradigm/condition
master_list =                    data_struct.master_list;
ROI_peak_vals =                  data_struct.ROI_peak_vals;
ROI_peak_locs =                  data_struct.ROI_peak_locs;
ROI_active_count =               data_struct.ROI_active_count;
ROI_active_vals =                data_struct.ROI_active_vals;
ROI_active_locs =                data_struct.ROI_active_locs;
ROI_sig_count =                  data_struct.ROI_sig_count;
ROI_sig_vals =                   data_struct.ROI_sig_vals;
ROI_sig_locs =                   data_struct.ROI_sig_locs;
paradigm_design =                data_struct.paradigm_design;


% define which figures to actually plot
figures.voxel_scatter =     0;
figures.sphere_scatter =    0;
figures.cluster_distances = 0;
figures.cluster_scatter =   0;
figures.multitask_clusters = 1;

%% plotting contrast data in 3D

M1_range = [-80 20; -40 20; 0 78];

% condition_idx = 3;
for cond_idx = 1 : 5
    
    % pull data from a single task, single subject, single ROI, single condition
    test_locs =             ROI_active_locs{1, 2, 1, cond_idx};
    test_vals =             ROI_active_vals{1, 2, 1, cond_idx};
    
    plot_thresh =           4.85;
    
    blank_vals =            NaN( size(test_vals) );
    blank_vals =            test_vals(test_vals>plot_thresh);
    
    
    % find peak voxel
    [peak, peak_idx] =      max(test_vals);
    peak_loc =              [ test_locs(peak_idx, 1) test_locs(peak_idx, 2) test_locs(peak_idx, 3) ];
    
    if figures.voxel_scatter == 1
        
        input_struct.point_vals =   test_vals;
        input_struct.point_locs =   test_locs;
        input_struct.cmap =         'jet';
        input_struct.clim =         [plot_thresh 12];
        
        output_struct =         FUNC_plot_3D_fMRI_data(input_struct);
        title('All M1');
        set(gcf, 'Position', [1929 576 560 420]);
    end
    
    %
    %
    % % find and plot all significant voxels
    % all_sig_voxels =        find(test_vals >= plot_thresh);
    % all_sig_vals =          test_vals(all_sig_voxels);
    % all_sig_locs =          test_locs(all_sig_voxels, :);
    %
    % if figures.sig_voxel_scatter == 1
    %
    %     input_struct.point_vals =   all_sig_vals;
    %     input_struct.point_locs =   all_sig_locs;
    %     input_struct.cmap =         'jet';
    %     input_struct.clim =         [plot_thresh 12];
    %
    %     output_struct =         FUNC_plot_3D_fMRI_data(input_struct);
    %     title('Significant voxels');
    %     set(gcf, 'Position', [1929 63 560 420]);
    %
    % end
    %
    %
    %
    % % find and remove "outlier" voxels that aren't part of main cluster
    % separation =           squareform(pdist(all_sig_locs));
    % average_dists =        mean(separation);
    %
    % threshold =             median(average_dists) + 1*std(average_dists);
    %
    % if figures.cluster_distances == 1
    %     figure;
    %     subplot(2, 1, 1);
    %     imagesc(separation);
    %     c = colorbar;
    %     ylabel(c, 'Euclidean distance');
    %     title('Pairwise voxel distances');
    %
    %     set(gcf, 'Position', [3081 108 727 888]);
    %
    %     subplot(2, 1, 2);
    %     histogram(average_dists, 50, 'normalization', 'pdf');
    %     line([threshold threshold], ylim, 'Color', 'k', 'LineWidth', 2);
    %     xlabel('Distance');
    %     ylabel('Probability');
    %
    % end
    %
    %
    % % extract "significant" voxels within sphere
    % outlier_voxels =        find(average_dists > threshold);
    %
    % clean_cluster_locs =    all_sig_locs;
    % clean_cluster_locs(outlier_voxels, :) = [];
    %
    % clean_cluster_vals =    all_sig_vals;
    % clean_cluster_vals(outlier_voxels) = [];
    %
    % num_cluster_voxels =    length(clean_cluster_vals);
    %
    % if figures.cluster_scatter == 1
    %     input_struct.point_vals =   clean_cluster_vals;
    %     input_struct.point_locs =   clean_cluster_locs;
    %     input_struct.cmap =         'jet';
    %     input_struct.clim =         [plot_thresh 12];
    %
    %     output_struct =         FUNC_plot_3D_fMRI_data(input_struct);
    %     title(['Primary cluster (n = ' num2str(num_cluster_voxels) ')']);
    %     set(gcf, 'Position', [2231 63 560 420]);
    %
    % end
    %
    %
    
    
    %
    
    
    
    % define local cluster
    
    % extract voxels in a sphere around the peak voxel
    radius =            25;
    
    for point_idx = 1 : length(test_locs)
        
        curr_point =            test_locs(point_idx, :);
        distance(point_idx) =   sqrt( ( peak_loc(1) - curr_point(1) ).^2 + (peak_loc(2)-curr_point(2)).^2 + (peak_loc(3)-curr_point(3)).^2 );
        
    end
    
    target_voxels =     find(distance<radius);
    sphere_vals =          test_vals(target_voxels);
    sphere_locs =          test_locs(target_voxels, :);
    
    if figures.sphere_scatter == 1
        
        input_struct.point_vals =   sphere_vals;
        input_struct.point_locs =   sphere_locs;
        input_struct.cmap =         'jet';
        input_struct.clim =         [plot_thresh 12];
        
        output_struct =         FUNC_plot_3D_fMRI_data(input_struct);
        title('25mm sphere');
        set(gcf, 'Position', [2505 576 560 420]);
    end
    
    % calculate initial metrics
    
    sphere_sig_voxels =    find(sphere_vals > plot_thresh);
    
    % find and remove "outlier" voxels that aren't part of main cluster
    sig_locs =             sphere_locs(sphere_sig_voxels, :);
    separation =           squareform(pdist(sig_locs));
    average_dists =        mean(separation);
    
    threshold =             median(average_dists) + 2*std(average_dists);
    
    if figures.cluster_distances == 1
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
    
    % fit a distribution to average voxel distances to identify outliers that are past median+3*std
    % figure;
    % h =                     histogram(average_dists,100,'Normalization','pdf');
    % x =                     h.BinEdges(1:100)+.5*h.BinWidth;
    % y =                     h.Values;
    %
    % gaussFit =              fit(x',y','gauss1');
    % dist_coeffs =           [gaussFit.a1 gaussFit.b1 gaussFit.c1];
    % hold on;
    % dists(1) =              plot(x,gaussFit.a1*exp(-((x-gaussFit.b1)/gaussFit.c1).^2), 'Color', 'r');
    % dist_values =           [dists(1).YData];
    % thresh =                dist_coeffs(2) + 3*dist_coeffs(3)
    % line([thresh thresh], [0 10], 'Color', 'k', 'LineWidth', 2);
    
    % extract "significant" voxels within sphere
    outlier_voxels =        find(average_dists > threshold);
    
    clean_cluster_locs =    sig_locs;
    clean_cluster_locs(outlier_voxels, :) = [];
    
    clean_cluster_vals =    sphere_vals(sphere_sig_voxels);
    clean_cluster_vals(outlier_voxels) = [];
    
    num_cluster_voxels =    length(clean_cluster_vals);
    
    
    % compute and store cluster data
    
    % % CALCULATE CENTER OF GRAVITY
    % generate new 3D image by inserting T-vals back into spatial coords (could instead just load original image)
    
    x_range =               [min(clean_cluster_locs(:, 1)):max(clean_cluster_locs(:, 1))];
    y_range =               [min(clean_cluster_locs(:, 2)):max(clean_cluster_locs(:, 2))];
    z_range =               [min(clean_cluster_locs(:, 3)):max(clean_cluster_locs(:, 3))];
    
%     new_img =               NaN(length(x_range), length(y_range), length(z_range));
    new_img =               NaN( length( M1_range(1, 1) : M1_range(1, 2) ),...
                            length( M1_range(2, 1) : M1_range(2, 2) ),...
                            length( M1_range(3, 1) : M1_range(3, 2) ) );

    for point_idx = 1 : num_cluster_voxels
        
        point_coords =          clean_cluster_locs(point_idx, :);
        x_idx =                 find( x_range == point_coords(1) );
        y_idx =                 find( y_range == point_coords(2) );
        z_idx =                 find( z_range == point_coords(3) );
        
        new_img(x_idx, y_idx, z_idx) = clean_cluster_vals(point_idx);
        
    end
    
    [xloc, yloc, zloc] =    COG(new_img);
    rounded_idx =           [round(xloc), round(yloc), round(zloc)];
    real_coords =           [x_range(rounded_idx(1)), y_range(rounded_idx(2)), z_range(rounded_idx(3))];
    
    
    if figures.cluster_scatter == 1
        input_struct.point_vals =   clean_cluster_vals;
        input_struct.point_locs =   clean_cluster_locs;
        input_struct.cmap =         'jet';
        input_struct.clim =         [plot_thresh 12];
        
        output_struct =         FUNC_plot_3D_fMRI_data(input_struct);
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
    
    cluster_data(cond_idx).volume =   num_cluster_voxels;
    cluster_data(cond_idx).locs =     clean_cluster_locs;
    cluster_data(cond_idx).vals =     clean_cluster_vals;
    cluster_data(cond_idx).COM =      real_coords;
    cluster_data(cond_idx).image =    new_img;
    
end% FOR, cond_idx

%% plot all clusters in same splace

jet_colorbar_rgb =      [ [24 28 137];...
                          [45 123 212];...
                          [148 248 114];...
                          [255 148 43];...
                          [128 26 39] ]/255;

symbols = {'*', '.', 's', 'd', '^'};

plot_range = [2 4];

if figures.multitask_clusters == 1
    
    figure;
    hold on;
    xlim([-80 20])
    ylim([-40 20]);
    zlim([0 78]);
    
    for cond_idx = plot_range(1) : plot_range(2)
        
        curr_size =                     cluster_data(cond_idx).volume;
        curr_locs =                     cluster_data(cond_idx).locs;
        curr_vals =                     cluster_data(cond_idx).vals;
        curr_CoM =                      cluster_data(cond_idx).COM;
        
        scatter3(curr_locs(:, 1), curr_locs(:, 2), curr_locs(:, 3), 160, jet_colorbar_rgb(cond_idx, :), symbols{cond_idx});
        
        line(xlim, [curr_CoM(2) curr_CoM(2)], [curr_CoM(3) curr_CoM(3)], 'Color', jet_colorbar_rgb(cond_idx, :), 'LineStyle', '--', 'LineWidth', 3);
        line([curr_CoM(1) curr_CoM(1)], ylim, [curr_CoM(3) curr_CoM(3)], 'Color', jet_colorbar_rgb(cond_idx, :), 'LineStyle', '--', 'LineWidth', 3);
        line([curr_CoM(1) curr_CoM(1)], [curr_CoM(2) curr_CoM(2)], zlim, 'Color', jet_colorbar_rgb(cond_idx, :), 'LineStyle', '--', 'LineWidth', 3);
        
    end% FOR, cond_idx
    
    set(gca, 'View', [-100 60]);
    
end% IF, figures.multitask_cluster

%% calculate %overlap between conditions

cluster_locs =      {cluster_data(:).locs};
input_struct.voxel_locs = cluster_locs;

overlap_data =      FUNC_find_overlap_voxels(input_struct);
% 
% figure;
% imagesc(overlap_data.overlap);
% hold on;
% for row_idx = 1 : 5
%     for col_idx = 1 : 5
%         text(row_idx, col_idx, num2str(overlap_data.overlap(row_idx, col_idx) ) );
%     end
% end


