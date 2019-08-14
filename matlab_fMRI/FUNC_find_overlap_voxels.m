% 2019-05-14 Dylan Royston
%
% Function to identify overlapping voxels between multiple fMRI clusters
% Returns #set * #set) matrix of shared voxels and the %overlap (#shared/#total)
%
%
%
%
%
%
%%

function output_struct = FUNC_find_overlap_voxels(input_struct)

% extract input variables/initialize output variables
voxel_locs =        input_struct.voxel_locs;
num_sets =          length(voxel_locs);

common_voxels =     cell(num_sets, num_sets);
overlap =           NaN(num_sets, num_sets);

% calculate overlaps for each set of coxels
for set1 = 1 : num_sets
    
    main_locs =         voxel_locs{set1};
    
    % compare each set to each other
    for set2 = 1 : num_sets
        
        % fill diagonal with tautological values
        if set1 == set2
            common_voxels{set1, set2} =     main_locs;
            overlap(set1, set2) =           100;
        else
            sec_locs =                      voxel_locs{set2};
            [common, ~, ~] =                intersect(main_locs, sec_locs, 'rows');
            common_voxels{set1, set2} =     common;
            overlap(set1, set2) =           100*( length(common) / ( length(main_locs) + length(sec_locs) ) );
        end% IF
        
    end% FOR, set2
    
end% FOR, set1

output_struct.shared_voxels =       common_voxels;
output_struct.overlap =             overlap;

end