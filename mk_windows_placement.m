%% Set current window's position and dimensions
% Source: http://www.mathworks.com/help/matlab/creating_plots/positioning-figures.html
% Input:
%   - windows_placement_vector = [x_desired y_desired Lx_desired Ly_desired]
%     - x and y denote windows's bottom-left corner desired placement as percent of Lx and Ly respectively, where Lx and Ly are
%     Screen's x and y size respectively;
%   - Lx_desire and Ly_desired denote windows's desired dimensions
%   - monitor_identifier - desired monitor to place figure on; optional - if
%                      empty then default value "1" is set on
%
% TODO
% - windows bar covers plot-windows
%%
%%
function mk_windows_placement(windows_placement_vector, monitor_identifier)    
    %
    % Welcome screen
    disp('');
    %
    % Monitor & screen
    set(0,'Units','pixels');
    scnsize = get(0,'MonitorPositions'); % get(0,'ScreenSize') - works for one monitor
    if (size(scnsize,1) == 1) || (exist('monitor_identifier','var') == 0)% Return to Default Monitor 1 when inly 1 is available
        monitor_identifier = 1;
    end    
    monitor_x = scnsize(monitor_identifier,1);
    monitor_y = scnsize(monitor_identifier,2);    
    Lx = scnsize(monitor_identifier,3) - scnsize(monitor_identifier,1);
    Ly = scnsize(1,4) - scnsize(1,2); % problem when 2nd monitor is placed arbitrary, position is swimming | scnsize(monitor_identifier,4) - scnsize(monitor_identifier,2);           
    %
    % Figure, get
    fig = figure(gcf); %get current figure's handle
    %
    % Something
    %position = get(fig,'Position');
    %outerpos = get(fig,'OuterPosition');
    %borders = outerpos - position;
    %edge = -borders(1)/2;
    %
    % Default behaviour if function called without windows_position_vector,
    % calls_count counts how many times function was called inside given
    % program.
    % http://www.mathworks.com/matlabcentral/newsreader/view_thread/289732
    persistent calls_count
    if isempty(calls_count)
        calls_count=1;
    else
        calls_count = calls_count + 1;
    end
    if ~nargin %exist('windows_placement_vector','var') || isempty(windows_placement_vector)
        %windows_placement_vector = [0.2892 0 0.4217 0.6667];
        windows_placement_vector = [0.5*rem(calls_count-1,2) 0.5*(1-rem(floor((calls_count-1)/2),2)) 1/2 1/2];
    end
    %
    % Position out
    pos_out = windows_placement_vector.*[Lx Ly Lx Ly] + [monitor_x monitor_y 0 0]; % modifications involving adding/substracting edge are optional
    %
    % Something
%     http://www.mathworks.com/matlabcentral/answers/93295
%     set(0,'DefaultTextinterpreter','none')
%     h=title(plot_title);
%     set(h,'units','normalized')
%     axpos = get(gca,'Position')
%     extent = get(hh,'Extent')
    %
    set(fig,'OuterPosition',pos_out);    
    %% Ende
    
    