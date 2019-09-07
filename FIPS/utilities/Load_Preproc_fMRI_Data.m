% 2016-07-26 Dylan Royston
%
% Partner function to Save_Preproc_fMRI_data
% Loads pre-processed data if parameters are shared
%
%
% === UPDATES ===
% 2016-08-09 Royston: updated in tandem with Save_Preproc to load multi-subject data individually
%
%%

function data_struct = Load_Preproc_fMRI_Data(metadata_struct, save_path)

subject_list =  metadata_struct.subject_list;

ROI_list =      metadata_struct.ROI_list;
paradigms =     metadata_struct.paradigms;


% 2016-08-09 Royston
% if length(subject_list) == 1
%     data_load_path = [save_path subject_list{1} '_DATA.mat'];
%     meta_load_path = [save_path subject_list{1} '_META_DATA.mat'];
% else
%     data_load_path = [save_path 'MULTI_SUBJECT_DATA.mat'];
%     meta_load_path = [save_path 'MULTI_SUBJECT_META_DATA.mat'];
% end

data_load_path = [save_path subject_list{1} '_DATA.mat'];
meta_load_path = [save_path subject_list{1} '_META_DATA.mat'];


% if processed data exists, load it; if not, process and save it
if exist(data_load_path, 'file') == 2
    
    % only load data if preprocessed metadata matches parameters specified above
    load(meta_load_path);% = metadata_struct
    preproc_subject_list =      metadata_struct.subject_list;
    preproc_ROI_list =          metadata_struct.ROI_list;
    preproc_paradigm_list =     metadata_struct.paradigms;
    
    % 2016-08-09 Royston: should be superfluous, but left for validation
    % subject check
    if length(preproc_subject_list) == length(subject_list)
        subject_check_idx =         cellfun(@strcmp, preproc_subject_list, subject_list);
        % subject list check
        switch unique(subject_check_idx)
            case 1
                subject_match = 1;
            otherwise
                display('SUBJECT MISMATCH')
                subject_match = 0;
        end
    else
        subject_match = 0;
    end
    
    % ROI check
    if length(preproc_ROI_list) == length(ROI_list)
        ROI_check_idx =             cellfun(@strcmp, preproc_ROI_list, ROI_list);
        
        % ROI list check
        switch unique(ROI_check_idx)
            case 1
                ROI_match = 1;
            otherwise
                display('ROI MISMATCH')
                ROI_match = 0;
        end
    else
        ROI_match = 0;
    end
    
    % paradigm check
    if length(preproc_paradigm_list) == length(paradigms)
        paradigm_check_idx =        cellfun(@strcmp, preproc_paradigm_list, paradigms);
        % paradigm list check
        switch length( unique(paradigm_check_idx) )
            case 1
                paradigm_match = 1;
            otherwise
                display('PARADIGM MISMATCH')
                paradigm_match = 0;
        end
    else
        paradigm_match = 0;
    end
    
    % load/reprocess decision
    if ROI_match == 1 && paradigm_match == 1 && subject_match == 1
        display('*** LOADING PROCESSED DATA ***')
        data_struct = load(data_load_path);% = data_struct
        data_struct.reprocess_data = 0;
    else
        display('PARAMETER MISMATCH, REPROCESSING DATA')
        data_struct.reprocess_data = 1;
    end
    
else% if data doesn't already exist, make it
    data_struct.reprocess_data = 1;
end% exist check





end% function



