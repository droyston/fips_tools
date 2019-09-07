% 2015-10-26 Dylan Royston
% 
% Container for extracted fMRI contrasts stats

classdef ROI_stats_class
    
    properties
        
        % Critial
        study_path =            char([]); 
        
        subject_id =            char([]); % Only needed for Freesurfer and UNIX things and designs
        
        condition_name =        char([]);
        
        % added for covert mapping analysis code
        current_paradigm =      char([]);
        
        current_ROI =           char([]);
        
        current_ROI_path =      char([]);
        
        % Misc
%         output_path =           char([]);
%         output_prefix =         char([]);
        
    end
    
    properties (Hidden)
        study_path_design = char([]);
        ROI_path_design =   char([]);
    end
    
    methods
        
        obj = Prep_Paths(obj);
                
    end
end    
    
    
    
    
    
