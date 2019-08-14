function Screening = Get_Screening_for_Subject(Screening_all,current_subject)
% Get all screening info for a subject (specific to NF study)
% Screening is a struct with .baseline, .NF_pre(x), .NF_post(x)
%
% EXAMPLE:
%     current_subject =   upper( DB_short(iDB).subject );
%     Screening =         Get_Screening_for_Subject(Screening_all,current_subject);
% 
%     hand =      Screening.baseline.Dominant_Hand; 
%     hand_str =  upper( hand([1,end]) ); % Left = LT, Right = RT
%     eval( ['grip_str = Screening.NF_pre(2).Grip_' hand_str '_Strength'] )
%
% 2015-04-14 Foldes
% UPDATES:
%   2015-09-24 Foldes: removed 'CANCEL'

% Get all screening data for a subject
clear crit Screening
crit.subject =      current_subject;
Screening_subject = Screening_all( DB_Find_Entries_By_Criteria(Screening_all,crit) );

session_type_list = DB_lookup_unique_entries(Screening_subject,'session');

for itype = 1:length(session_type_list)
    
    crit.session = session_type_list{itype};
    
    switch crit.session
        case 'CANCEL'
            % Nothing
        case 'Baseline'
            session_type =  'baseline';
            Screening.(session_type) = Screening_subject( DB_Find_Entries_By_Criteria(Screening_subject,crit) );
        case 'V2 pre'
            session_type =  'V2_pre';
            Screening.(session_type) = Screening_subject( DB_Find_Entries_By_Criteria(Screening_subject,crit) );
        case 'V2 post'
            session_type =  'V2_post';
            Screening.(session_type) = Screening_subject( DB_Find_Entries_By_Criteria(Screening_subject,crit) );
        otherwise % ALL NF
            session_num = str2num( crit.session(3:4) );
            pre_flag =    strcmpi(crit.session(end-2:end),'pre'); % 1 = pre, 0 = post
            if pre_flag
                Screening.NF_pre(session_num) =     Screening_subject( DB_Find_Entries_By_Criteria(Screening_subject,crit) );
            else % post
                Screening.NF_post(session_num) =    Screening_subject( DB_Find_Entries_By_Criteria(Screening_subject,crit) );
            end
    end
end