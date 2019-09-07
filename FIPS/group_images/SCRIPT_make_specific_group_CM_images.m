% 2019-08-09 Dylan Royston
%
% SCRIPT to generate specific group-level beta images for final analysis of CM project
%
% Is VERY hard-coded to use all valid subjects for S/G/A conditions and split groupwise on Stim
%
% WILL OVERWRITE files with specified set names
% Directing to a clean set folder for clarity
%
%
%% Initialize data to load

clear; clc;

% paths to individual subject files (source_data_dir) and group-level repository (active_data_dir)
source_data_dir =   '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/%s/NIFTI/%s';
% active_data_dir =   '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/%s/BETAS/%s';

% multi-subject
active_data_dir =   '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/new_group_level';


% list of "all" valid AB subjects (for use in 3/4 of conditions)
AB_all_list =       {'CMC01', 'CMC03', 'CMC04', 'CMC05', 'CMC07', 'CMC09', 'CMC10', 'CMC11', 'CMC12', 'CMC13',...
        'CMC14', 'CMC15', 'CMC17', 'CMC18', 'CMC20', 'CMC22', 'CMC23', 'CMC24', 'CMC26', 'CMC27'};
    
% partial subset lists for Stim condition    
AB_hand =    {'CMC01', 'CMC03', 'CMC04', 'CMC05', 'CMC07', 'CMC09', 'CMC23', 'CMC24', 'CMC26'};
AB_ref =     {'CMC10', 'CMC11', 'CMC12', 'CMC13', 'CMC14', 'CMC15', 'CMC17', 'CMC18', 'CMC20', 'CMC22', 'CMC27'};
    
% SCI subject list
SCI_all_list =      {'CMS01', 'CMS02', 'CMS03', 'CMS04', 'CMS06', 'CMS07', 'CMS09', 'CMS13'};


% list of set images to produce
% currently scripted for motor tasks during development
task_list =     {'MO', 'MCW', 'MCH', 'MCF'}; 
file_tasknames = {'Motor_overt', 'Motor_covert_wrist', 'Motor_covert_hand', 'Motor_covert_fingers'};

%% AB: Generate group images
% AB is separate because groups must be split for Stim

subject_group = 'SCI';


for task_idx = 1 : length(task_list)
    
    current_task =      task_list{task_idx};
    
    disp(['*** ' current_task ' ***']);
    
    filenames =         file_tasknames{task_idx};
    
    
    switch subject_group
        case 'AB'
            
            switch current_task
                case 'MO'
                    
                    subjects_to_use =   AB_all_list;
                    con_list =          1:5;
                    
                    set_names =         {'AB_all_MO'};
                    
                otherwise
                    
                    subjects_to_use =   {AB_hand; AB_ref};
                    con_list =          {1:3; 4};
                    set_names =         {['AB_all_' current_task]; ['AB_hand_' current_task '_stim']; ['AB_ref_' current_task '_stim']};
            end% SWITCH current_task
            
        case 'SCI'
            
             switch current_task
                case 'MO'
                    
                    subjects_to_use =   SCI_all_list;
                    con_list =          1:5;
                    
                    set_names =         {'SCI_all_MO'};
                    
                otherwise
                    
                    subjects_to_use =   SCI_all_list;
                    con_list =          {1:4};
                    set_names =         {['SCI_all_' current_task]};
             end% SWITCH current_task
            
            
    end% SWITCH subject_group
    
    
    
    % generate each set using appropriate subject list
    for set_idx = 1 : length(set_names)
        
        curr_setname =          set_names{set_idx};
        
        disp(['*- ' curr_setname ' -*']);
        
        group_parts =           strsplit(curr_setname, '_');
        
        group_label =           [group_parts{1} '_' group_parts{2}];
        
        task_label =            [group_parts{2} '_' group_parts{3}];
        
        switch task_label
            case 'all_MO'
                subjects =          subjects_to_use;
                
                clearvars input_struct output_struct
                input_struct.load_path =    source_data_dir;
                input_struct.save_path =    active_data_dir;
                input_struct.set_handle =   curr_setname;
                input_struct.subjects =     subjects;
                input_struct.task =         filenames;
                input_struct.conds =        con_list;
                
                func_flags.return_indiv =   0;
                func_flags.save_new =       1;
                input_struct.flags =        func_flags;
                
                output_struct =             FUNC_create_group_beta_images(input_struct);
                
            % if a covert condition    
            otherwise
                
                switch group_label
                    % if a non-stim set
                    case 'AB_all'
                        subjects =          AB_all_list;
                        cons_to_use =       1:3;
                        
                    case 'AB_hand'
                        subjects =          subjects_to_use{1};
                        cons_to_use =       4;
                        
                    case 'AB_ref'
                        subjects =          subjects_to_use{2};
                        cons_to_use =       4;
                    case 'SCI_all'
                        subjects =          subjects_to_use;
                        cons_to_use =       1:4;
                        
                end% SWITCH group_label
                
                clearvars input_struct output_struct
                input_struct.load_path =    source_data_dir;
                input_struct.save_path =    active_data_dir;
                input_struct.set_handle =   curr_setname;
                input_struct.subjects =     subjects;
                input_struct.task =         filenames;
                input_struct.conds =        cons_to_use;
                
                func_flags.return_indiv =   0;
                func_flags.save_new =       1;
                input_struct.flags =        func_flags;
                
                output_struct =             FUNC_create_group_beta_images(input_struct);
                
        end% SWITCH curr_setname
        
    end% FOR set_idx
    
end% FOR task_idx



