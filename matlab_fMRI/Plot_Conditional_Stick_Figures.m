% 2016-09-19 Dylan Royston
%
% Function to create stick plots (scatter+line) for fMRI data
%
% Inputs:
%   - data_in: 4D matrix, (ROI, subject, paradigm, condition)
%
%
%
%
%
%%

function fig_handle = Plot_Conditional_Stick_Figures(data_in, paradigm_info, ROI_info)

paradigm_name =     paradigm_info.paradigm;
conditions =        paradigm_info.conditions;
num_conditions =    length(conditions);
ROI_labels =        ROI_info;

num_ROIs =          length(ROI_labels);

fig_handle =        figure;
hold on;

% assign ROI-specific line details
for r = 1 : num_ROIs
    switch r
        case 1% Left M1
            emphasis_width = 3;
            emphasis_style = '-';
            emphasis_color = [0 0.4470 0.7410];
        case 2% Left S1
            emphasis_width = 3;
            emphasis_style = '-';
            emphasis_color = [0.8500 0.3250 0.0980];
        case 3% Left SMA
            emphasis_width = 1;
            emphasis_style = '-';
            emphasis_color = [0.9290 0.6940 0.1250];
        case 4% Left PPC
            emphasis_width = 1;
            emphasis_style = '-';
            emphasis_color = [0.4940 0.1840 0.5560];
        case 5% Right M1
            emphasis_width = 1;
            emphasis_style = '--';
            emphasis_color = [0 0.4470 0.7410];
        case 6% Right S1
            emphasis_width = 1;
            emphasis_style = '--';
            emphasis_color = [0.8500 0.3250 0.0980];
        case 7% Right SMA
            emphasis_width = 1;
            emphasis_style = '--';
            emphasis_color = [0.9290 0.6940 0.1250];
        case 8% Right PPC
            emphasis_width = 1;
            emphasis_style = '--';
            emphasis_color = [0.4940 0.1840 0.5560];
    end% ROI switch
    
    current_ROI_vals =      squeeze(data_in(r, 1:num_conditions));
    mean_ROI_vals(r, :) =   mean(current_ROI_vals, 1);
    std_ROI_vals(r, :) =    std(current_ROI_vals, 1);
    
    % scatter/line plots
    l =                     plot(mean_ROI_vals(r, :), 'LineWidth', emphasis_width, 'LineStyle', emphasis_style, 'Color', emphasis_color);
    current_color(r, :) =   get(l, 'Color');
    
end% ROI loop

legend(ROI_labels, 'Location', 'best');

% adds scatter points after legend to keep a readable legend
for r = 1 : num_ROIs
    scatter(1:num_conditions, mean_ROI_vals(r, :), 40, current_color(r, :), 'filled' );
end

% figure settings
print_name = strrep(paradigm_name, '_', ' ');
title(print_name);
xlim([0.5 num_conditions+0.5])
curr_ylim = get(gca, 'ylim');
ylim([0 curr_ylim(2)]);
xlabel('Enrichment Condition')

% labels correct XTicks with respective condition
condition_ticks = get(gca, 'XTickLabels');
tick_counter = 0;

for tick_idx = 1 : length(condition_ticks)
    curr_tick =             str2double(condition_ticks{tick_idx});
    is_whole(tick_idx) =    rem(curr_tick, 1);
    
    if is_whole(tick_idx) == 0
        tick_counter =              tick_counter + 1;
        tick_display{tick_idx} =    conditions{tick_counter};
    else
        tick_display{tick_idx} =    '';
    end
    
end

set(gca, 'XTickLabels', tick_display)



end