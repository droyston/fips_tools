function h = errorbar_abs(X,Y,L_abs,U_abs,varargin)
% h = errorbar_abs(X,Y,L_abs,U_abs,'LineWidth','Color','MarkerSize','LineStyle','fig'
% UNLIKE errorbar.m, L_abs AND U_abs ARE ACTUAL VALUES, not relative to the center
% Freaking Matlab changed errorbar in 2014b without documenting it, so 
% I just made mine own and I made it work better for interquarile range
% It also looks better, come on
%
% % Interquartile Range
%   Y =   quantile( data, .50 );
%   L =   quantile( data, .25 );
%   U =   quantile( data, .75 );
%
% 2014-11-21 Foldes
% UPDATES:
% 2014-12-04 Foldes: Removed 'Marker' parameter
% 2014-12-08 Foldes: Added 'Marker'

%% DEFAULTS

parms.Color =       'k';
parms.LineStyle =   '-';
parms.LineWidth =   4;
parms.Marker =      '.';
parms.MarkerSize =  40;
parms.fig =         [];

parms = varargin_extraction(parms,varargin);

if isempty(parms.fig)
    parms.fig = figure(gcf);
end


%% PLOT
hold all

% Error bars
for ibar = 1:length(X)
    plot([X(ibar) X(ibar)],[L_abs(ibar) U_abs(ibar)],'-','LineWidth',parms.LineWidth,'Color',parms.Color)
end

% Middle dot
plot(X,Y,'Color',parms.Color,'LineStyle',parms.LineStyle,'LineWidth',parms.LineWidth,'Marker',parms.Marker,'MarkerSize',parms.MarkerSize)


