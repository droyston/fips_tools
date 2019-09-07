% 2019-08-26 Dylan Royston
%
% Function to extract condition labels from PsychoPy experiment logs
%
%
%
%
%
%
%
%%

function output_data = FUNC_parse_psychopy_logs(full_log_path)

log_contents =  readtable(full_log_path);
output_data =   log_contents.text;

end% FUNCTION
