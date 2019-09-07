
function onset_times = eprimeparse(string_in)


%
% 2014-04-14 Stephen Foldes
%
% === UPDATES ===
% 2015-04-06 Royston: updated for covert mapping Eprime logs
% 2015-09-18 Royston: updated text checking to account for Matlab's bizarre formatting
% 2016-03-07 Royston: converted to function for automating SPM processing (referenced in SCRIPT_Run_fMRI_Analysis.m)
% 2016-09-01 Royston: added extra audio_check to catch +audio instead of +sound in EPrime logs
%
%
% ==== Basic Extract ====
% maintained here as a pristine example of this script's core function
%
% match_txt = 'Text:';
% match_txt = 'Procedure:';
% num_flag = 0;
%
% match_idx = find(strcmp(txt,match_txt)==1) + 1; % +1 to be the next str
% clear value
% for imatch = 1:length(match_idx)
%     if num_flag
%         value(imatch,1) = str2num( txt{match_idx(imatch)} );
%     else
%         value{imatch,1} = txt{match_idx(imatch)};
%     end
% end





% clear;clc;
%% Get data from eprime txt
% txt_file = 'C:\Users\hrnel\Documents\MATLAB\fMRI Analysis\fMRI Analysis Storage\CMC02\Covert_Mapping_wrist_flex_randomized-343-1-EDITED.txt';% sets file to be opened
% txt_file = 'C:\Users\hrnel\Documents\MATLAB\fMRI Analysis\fMRI Analysis Storage\CMC02\Covert_Mapping_sensory_enrichment_hand-343-2.txt';% sets file to be opened
% txt_file = 'C:\Users\hrnel\Documents\MATLAB\fMRI Analysis\fMRI Analysis Storage\CMC02\Covert_Mapping_overt_motor-343-3.txt';% sets file to be opened

if isempty(string_in)
    txt_file = 'C:\Users\hrnel\Documents\MATLAB\fMRI Analysis\fMRI Analysis Storage\COVERT MAPPING\CMC05\EPrime Logs\Motor_covert_fingers-05-11.txt';
else
    txt_file = string_in;
end

fileID = fopen(txt_file);% opens file in matlab

clear txt txt_*% clears superfluous temporary variable of txt_file
txt_raw = textscan(fileID,'%s');% extracts text from file
fclose(fileID);% closes file in matlab

txt = txt_raw{1} ;% extracts text from meta-array

% removes random null characters, probably an upstream fix when there's time
for i=1:length(txt)
    if(ischar(txt{i}))
        temp = txt{i};
        temp(temp==0) = [];
        txt{i} = temp;
    end
end


%% Extracts desired criteria from log
% Gets enrichment conditions and onset/offset times

% gets condition labels from pre-stimulus text prompt
% match_txt = 'Procedure:';% depending on EPrime design this can also be "Text:" or "Movie:" to be unique
match_txt = 'Text:';
% match_txt = 'Movie:';
num_flag = 0;

% match_idx = find(strcmp(txt,match_txt)==1) + 1; % finds given string, +1 to be the next str
match_idx = strfind(txt, match_txt);
match_idx = find(~cellfun(@isempty, match_idx));
match_idx = match_idx + 1;

% 2015-09-18 Royston
for imatch = 1:length(match_idx)
    if num_flag
        entry(imatch,1) = str2num( txt{match_idx(imatch)} );
    else
        if length(txt{match_idx(imatch)+1}) < 2 && length(txt{match_idx(imatch)+2}) < 2
            entry{imatch,1} = [txt{match_idx(imatch)}];
        end
        if length(txt{match_idx(imatch)+1}) > 2 && length(txt{match_idx(imatch)+2}) < 2
            entry{imatch,1} = [txt{match_idx(imatch)} txt{match_idx(imatch)+1} ];
        end
        if length(txt{match_idx(imatch)+1}) > 2 && length(txt{match_idx(imatch)+2}) > 2
            entry{imatch,1} = [txt{match_idx(imatch)} txt{match_idx(imatch)+1} txt{match_idx(imatch)+2} ];
        end
    end
end

cue_name = entry;
match_idx_cue = match_idx;


% % Gets offset times
% match_txt = 'CueMovie.OffsetTime:';
% num_flag = 1;
%
% match_idx = find(strcmp(txt,match_txt)==1) + 1; % +1 to be the next str
% clear entry
% for imatch = 1:length(match_idx)
%     if num_flag
%         entry(imatch,1) = str2num( txt{match_idx(imatch)} );
%     else
%         entry{imatch,1} = txt{match_idx(imatch)};
%     end
% end
%
% time_off = entry;
% match_idx_time_off = match_idx;


% Gets onset times
match_txt = 'FirstFrameTime:';
% match_txt1 = 'CueMovie1.FirstFrameTime:';
% match_txt2 = 'CueMovie2.FirstFrameTime:';
% match_txt3 = 'CueMovie3.FirstFrameTime:';

num_flag = 1;

% match_idx = find(strcmp(txt,match_txt)==1) + 1; % +1 to be the next str
match_idx = strfind(txt,match_txt); % +1 to be the next str
match_idx = find(~cellfun(@isempty, match_idx));
match_idx = match_idx + 1;

clear entry
for imatch = 1:length(match_idx)
    if num_flag
        entry(imatch,1) = str2num( txt{match_idx(imatch)} );
    else
        entry{imatch,1} = txt{match_idx(imatch)};
    end
end

time_on = entry;
match_idx_time_on = match_idx;



%% Get event-start times for each condition

% if there was an error, there might be incomplete trials
num_events = min([length(match_idx_cue) length(match_idx_time_on) ]);% length(match_idx_time_off)]);
cue_list = unique(cue_name);
% initialize
clearvars event_list
for icue = 1:length(cue_list)
    event_list(icue).cue_name =     cue_list{icue};
    event_list(icue).cue_num =      [];
    event_list(icue).cue_scan =     [];
end

% remove time-offset, and add your own
first_movie_offset = min(time_on)-(15*2000); % 30s
% first_movie_offset = 0;
TR = 2; %2s

event_sequence = [];
for ievent = 1:num_events
    event_idx =                                 find(strcmp(cue_name{ievent},cue_list));
    event_list(event_idx).cue_num(end+1) =      ievent;
    event_list(event_idx).cue_scan(end+1) =     floor( (time_on(ievent) - first_movie_offset)/(2000) );
    
    event_sequence(end+1) = event_idx;
end

% 2016-03-07 Royston
num_conditions = length(cue_list);
clearvars output_ordered
switch num_conditions
    
    case 4% covert, simple/goal/audio/stim
        
        clearvars output_ordered output_conditions
        output_conditions = {'Simple', 'Goal', 'Audio', 'Stim'};
        
        for cond_idx = 1:num_conditions
            
            clearvars simple_check goal_check audio_check stim_check
            
            check_cond = event_list(cond_idx).cue_name;
            
            % simple (AND ONLY SIMPLE) conditions have the body part in the cue text
            simple_check(1) = length(strfind(check_cond, 'Finger') );
            simple_check(2) = length(strfind(check_cond, 'Hand') );
            simple_check(3) = length(strfind(check_cond, 'Wrist') );
            
            % audio conditions have +sound (legacy +audio)
            audio_check = length(strfind(check_cond, '+sound') );
            if audio_check == 0
                audio_check = length(strfind(check_cond, '+audio') );
            end
            
            % stim conditions have +stim
            stim_check = length(strfind(check_cond, '+stim') );
            
            if any(simple_check)
                output_ordered(1, :) = event_list(cond_idx).cue_scan;
            end
            
            if audio_check && ~stim_check
                output_ordered(3, :) = event_list(cond_idx).cue_scan;
            end
            
            if stim_check
                output_ordered(4, :) = event_list(cond_idx).cue_scan;
            end
            
            % goal conditions have none of the above text
            if ~any(simple_check) && ~audio_check && ~stim_check
                output_ordered(2, :) = event_list(cond_idx).cue_scan;
            end
            
        end% condition check loop
        
    case 5% motor overt, lips/wrist/hand/fingers/ankle
        
        clearvars output_ordered
        
        for cond_idx = 1:num_conditions
            
            clearvars body_check
            
            check_cond = event_list(cond_idx).cue_name;
            
            body_check(1) = length(strfind(check_cond, 'Lip') );
            body_check(2) = length(strfind(check_cond, 'Wrist') );
            body_check(3) = length(strfind(check_cond, 'Hand') );
            body_check(4) = length(strfind(check_cond, 'Finger') );
            body_check(5) = length(strfind(check_cond, 'Ankle') );
            
            part_idx = find(body_check);
            
            output_ordered(part_idx, :) = event_list(cond_idx).cue_scan;
            
        end% condition check loop
        
    case 1% sensory overt, stim
        
        output_ordered(1, :) = event_list.cue_scan;
        
end

% for icue = 1:length(cue_list)
%     disp(event_list(icue).cue_name)
%     disp(event_list(icue).cue_scan)    
% end
%  (([1:7*4]*10)+20)/2

onset_times = output_ordered;

end


