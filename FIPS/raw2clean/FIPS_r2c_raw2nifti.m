% 2019-09-08 Dylan Royston
%
% Converts Raw MRI files from MRRC to NIFTI and/or DICOM format.
% Used before Freesurfer and SPM
% MRI_Info can be used. If not included, will use GUIs
% SEE: MRI_Info_Class.m
%
% INPUTS:
%   MRI_Info.raw_data_path: [OPTIONAL] path to where the raw data is. 
%                           If not defined will use UI
%   MRI_Info.epi_path:      [OPTIONAL] path to where the NIFTIs should go.
%                           If not defined will use dir one up from raw, with /NIFTI/
%
% VARARGIN:
%   save_NIFTI: flag to save (1) or remove (0) files [default to save]
%   save_DICOM: [default to remove]
%   DICOM_only: Does DICOM Only, no NIFTI
%
% Adapted from 2012-08-06 (Stephen Foldes via Mike, Betsy, and Tim)
% UPDATES:
% 
%%

function MRI_Info = fMRI_ConvertMRRCdata(MRI_Info,varargin)


%% INITIALIZE
parms.save_NIFTI = 1;
parms.save_DICOM = 1; % delete DICOMs by default
parms.DICOM_only = 0;
parms = varargin_extraction(parms,varargin);

% Turn _design into strings
MRI_Info = design2str_struct(MRI_Info);
% Automatically sets some standard paths if haven't already
MRI_Info=Prep_Paths(MRI_Info);

% path to raw data
if isempty(MRI_Info.raw_data_path)
    % Allows user to specify where the fMRI data is located
    MRI_Info.raw_data_path = uigetdir('Please select the path to the raw MRI data folder');
end

% No epi_path, then just use one up from raw, plus /NIFTI
if isempty(MRI_Info.epi_path)
    MRI_Info.epi_path = [dir_up(MRI_Info.raw_data_path) filesep 'NIFTI'];
end

%% DICOMS
disp('Relabeling Raw Data as DICOMs')
DICOM_folder = [MRI_Info.raw_data_path 'DICOM'];% 2016-06-15 Royston: removed 'filesep' from middle of path
raw2dicom(MRI_Info.raw_data_path,DICOM_folder);

%% NIFTI
if parms.DICOM_only ~= 1
    % Convert DICOM to .nii
    disp('Convert DICOMs to NIFTI')
    
    folder_holder =     dir(DICOM_folder);
    folder_name =       folder_holder(3).name;
    
    % replaced dicom2nifti and all subfunctions with this simpler, much better one
    dicm2nii(DICOM_folder, [MRI_Info.epi_path folder_name], 0);
    
%     dicom2nifti('4dnii',DICOM_folder,MRI_Info.epi_path);
end

%% Remove Files

% if ~parms.save_DICOM
%     rmdir(DICOM_folder,'s');
% end
% 
% if ~parms.save_NIFTI && ~parms.DICOM_only
%     rmdir(temp_NIFTI_folder,'s');
% end


