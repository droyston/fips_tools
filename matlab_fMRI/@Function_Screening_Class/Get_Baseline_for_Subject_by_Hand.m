function [Screening_DOM,hand,hand_str] = Get_Baseline_for_Subject_by_Hand(Screening_all,current_subject,hand)
% Get all screening info for a subject (specific to NF study)
% Return baseline values for a given hand
% hand: 'RT,'LT','DOM','nonDOM'
%
% EXAMPLE:
%
% 2015-04-14 Foldes
% UPDATES:
%

if ~exist('hand')
    hand = 'DOM';
end

% Get all screening data for a subject
clear crit Screening
crit.subject =  current_subject;
crit.session = 'Baseline';

Screening = Screening_all( DB_Find_Entries_By_Criteria(Screening_all,crit) );

hand_str =      Screening.Dominant_Hand;
hand_str_short =  upper( hand_str([1,end]) ); % Left = LT, Right = RT


field_list = properties(Screening);

%% Get list of handed field names
handed_measures = []; handed_measure_cnt = 0;
unhanded_measures = []; unhanded_measure_cnt = 0;
for ifield = 1:length(field_list)
    measure_name = field_list{ifield};
    hand_find_idx = findstr(measure_name,'_RT');
    
    if ~isempty(hand_find_idx)
        handed_measure_cnt = handed_measure_cnt + 1;
        handed_measures{handed_measure_cnt} = measure_name;
    else
        if isempty( findstr(measure_name,'_LT') )
            unhanded_measure_cnt = unhanded_measure_cnt + 1;
            unhanded_measures{unhanded_measure_cnt} = measure_name;
        end
    end
end % field

%% Copy un-handed properties
clear Screening_DOM
for ifield = 1:length(unhanded_measures)
    Screening_DOM.(unhanded_measures{ifield}) = Screening.(unhanded_measures{ifield});
end

%% Copy handed values
for ifield = 1:length(handed_measures)
    measure_name = handed_measures{ifield};
    
    hand_find_idx = findstr(measure_name,'_RT');
    % Sanitize name
    clean_name = measure_name;
    clean_name(hand_find_idx:hand_find_idx+2) = [];
    
    switch lower( hand )
        case 'dom'
            switch hand_str
                case 'Left'
                    measure_name(hand_find_idx:hand_find_idx+2) = '_LT';
                case 'Right'
                    measure_name(hand_find_idx:hand_find_idx+2) = '_RT'; % keep the same
            end
            
        case 'nondom'
            % If Left, replace RT w/ LT
            switch hand_str
                case 'Left'
                    measure_name(hand_find_idx:hand_find_idx+2) = '_RT';
                case 'Right'
                    measure_name(hand_find_idx:hand_find_idx+2) = '_LT';
            end
            
        case {'rt','right','r'}
            measure_name(hand_find_idx:hand_find_idx+2) = '_RT'; % keep the same
        case {'lt','left','l'}
            measure_name(hand_find_idx:hand_find_idx+2) = '_LT';
            
    end % Hand choice
    
    Screening_DOM.(clean_name) = Screening.(measure_name);
end
