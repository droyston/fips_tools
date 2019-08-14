% Function to extract timeseries information from an EPI file for ROI
% Specify the ROI .nii file, 4D EPI .nii file, and an output .txt filename
% Kevin Jarbo
%
%
% Used in this context to extract T-values from spmT_000X.nii contrast files
% Pads EPI/spmT data to match the origins of functional and ROI files
% Uses functions from "Tools for NIFTI and ANALYZE image", on Matlab file exchange
% ONLY works on normalized data with normalized ROIs
% Individual data could probably be used with functionally defined ROIs, but coordinate systems must be consistent
%
% === UPDATES ===
% 2015-04-15 Royston: edited to work with HRNEL covert mapping fMRI data
%
%

function ts = extract_stats_from_epi(roi_file, epi_file)%, do_x_flip)


% if nargin < 4 | isempty(do_x_flip);
% 	do_x_flip =         0;
% end;
do_x_flip =             0;% current data does not need LR-flip

% load objects (e.g., 'L_putamen.nii', '0123_epi_RestingState.nii',
% '0123_ts.txt')
roi =                   load_nii(roi_file);% load ROI, which is already normalized
epi =                   load_nii(epi_file);% load warped EPI, to preserve normalization

% flip ROI mask
if do_x_flip;
    roi.img =           flipdim(roi.img,1);
end;

% find indexes for anything that is NOT 0 in the ROI file
roi_vox =               find(roi.img(:) > 0);

% find differences between ROI/functional origins
epi_origin =            epi.hdr.hist.originator(1:3);
roi_origin =            roi.hdr.hist.originator(1:3);
origin_diffs =          roi_origin - epi_origin;

% pad EPI/contrast file to match origins with ROI
% 2017-04-12 Royston: added ifs to correct for negative diffs
neg_check =             find(origin_diffs < 0);
clearvars opt

if ~isempty(find(neg_check == 1) )% if pad_from_L is negative
    opt.pad_from_R =    -1* origin_diffs(1);
else
    opt.pad_from_L =        origin_diffs(1);
end

if ~isempty(find(neg_check == 2) )% if pad_from_P is negative
    opt.pad_from_A =    -1* origin_diffs(2);
else
    opt.pad_from_P =        origin_diffs(2);
end

if ~isempty(find(neg_check == 3) )% if pad_from_I is negative
    opt.pad_from_S =    -1* origin_diffs(3);
else
    opt.pad_from_I =        origin_diffs(3);
end
% 
% opt.pad_from_L =        origin_diffs(1);
% opt.pad_from_P =        origin_diffs(2);
% opt.pad_from_I =        origin_diffs(3);
new_epi =               pad_nii(epi, opt);

% INITIALIZE TMP WITH SIZE OF EPI SO THAT OUTPUT SIZES ARE UNIVERSAL
tmp = zeros( size( roi.img) );


% Loop through all the nonzero voxels in the ROI image
for v = 1:length(roi_vox)
    vox_index =         roi_vox(v); % give the index number for each voxels
    [x, y, z] =         ind2sub(size(roi.img), vox_index); % converts index into dimension-index
    
    if(x > size(new_epi.img, 1) || y > size(new_epi.img, 2) || z > size(new_epi.img, 3))
        tmp(:,v) =       0;% ignores EPI values outside the ROI
    else
        tmp(x, y, z) =  new_epi.img(x, y, z); % gets T-value of each voxel in the epi masked by the ROI
    end
end

ts = tmp;

out_file = 'time_series.txt';

dlmwrite(out_file, ts); % saves out text file of the mean time series
% optional, serves no purpose in current context


