%% Linear fitting to nonlinear IV data
%  Goal:   Find resistivity R, by fitting linear function (I = 1/R * U) to I-V data that are nonlinear.
%  Method: For each iteration two datapoints are excluded - one for highest and lowest voltage.
%          (Minimum datapoints left for fitting - 4)
%          The linear regression is performed.
%          R is taken from the fit for which the R^2_adjusted is highest.
%  
%  Input
%  - data: [U [V], I [A]]
%  - display_mode:
%    - graphs_all: 'displays all graphs'
%    - graphs_final: 'displays only graph of final fit'
%    - graphs_none: 'displays no graphs'
%  - pause: pause time between graph update
%  - dataset_name: name of the dataset to display on graphs
% Output
%  - myFit - LinearModel object for the best fit  
%  * how to use myFit:
%    * R                  = myFit.Coefficients{2,1} [Ohm]
%    * deltaR             = myFit.Coefficients{2,2} [Ohm]
%    * R_squared_adjusted = myFit.Rsquared.Adjusted [\]
%% Program call for test data
% myFit = IV_linear_fit_to_nonlinear_data(importdata('IV_test-data.txt'), 'graphs_all', 0, 'test-data')
% myFit = IV_linear_fit_to_nonlinear_data(importdata('IV_test-data_2.txt'), 'graphs_all', 0, 'test-data')
function myFit = IV_linear_fit_to_nonlinear_data(data, display_mode, user_pause, dataset_name)
    %% Init
    range              = 0:1:floor(length(data)/2);
    R                  = zeros(1+floor(length(data)/2), 1);
    deltaR             = zeros(1+floor(length(data)/2), 1);
    R_squared_adjusted = zeros(1+floor(length(data)/2), 1);
    dataset_name = strrep(dataset_name, '_', '\_');
%     btn = uicontrol('Style', 'pushbutton', 'String', 'STOP');
    %% Calc
    for i = range         
        tbl = table(data(1+i:end-i,1), data(1+i:end-i,2), 'VariableNames', {'Voltage', 'Current'}); % x:  U (V), y: I (A),  
        myFit = fitlm(tbl,'Current ~ Voltage'); 
        R(i+1)                  = 1/myFit.Coefficients{2,1}; % R [Ohm] = 1/a
        deltaR(i+1)             = abs(myFit.Coefficients{2,2}/myFit.Coefficients{2,1}^2); % deltaR [Ohm] = |delta_a/a^2| 
        R_squared_adjusted(i+1) = myFit.Rsquared.Adjusted;
        switch display_mode % if test mode is active, below figures will be showed
            case 'graphs_all'
                figure(1)
                    % plot unused datapoint in gray, used datapoints in blue, fit in red
                    plot( data([1:i end-(i-1):end],1), data([1:i end-(i-1):end],2), 'o', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.5, 'MarkerSize', 4 )
                    hold on
                    plot(data(1+i:end-i,1), data(1+i:end-i,2), 'ob', 'MarkerSize', 8 )
                    line([data(1+i,1) data(1+i,1)], [min(data(:,2)) max(data(:,2))]) % lowest voltage  
                    line([data(end-i,1) data(end-i,1)], [min(data(:,2)) max(data(:,2))]) % highest voltage
                    plot(data(1+i:end-i,1), myFit.Coefficients{1,1} + data(1+i:end-i,1)*myFit.Coefficients{2,1}, '-r', 'LineWidth', 2)
                    hold off
                    mk_plot([dataset_name ', ' num2str(i) ' data points cut from each side'], 'U [V]', 'I [A]', [], [], 0, [0 0 1/2 1], 'tex')
                figure(2)
                    errorbar(0:i, R(1:i+1), deltaR(1:i+1), '-or')
                    mk_plot(dataset_name, 'Number of cut datapoints from each side', 'R [Ohm]',  [], [], 0, [1/2 1/2 1/2 1/2], 'tex')
            %         ax = get(fig, 'CurrentAxes')
            %         set(ax, 'YScale', 'log')
                figure(3)
                    plot(0:i, R_squared_adjusted(1:i+1), '-.r*')
                    mk_plot(dataset_name, 'Number of cut datapoints from each side', 'R^2_{adjusted} [\\]', [], [], 3*user_pause, [1/2 0 1/2 1/2], 'tex')
        end
    end
    %% Output
    [max_val, idx] = max(R_squared_adjusted(1:end-2)); % when looking for maximum do not include value for fit to 1 R(end) or 2 (or 3) points R(end-1)
    i_max = (idx-1); % i for which R_squared_adjusted was maximal
    tbl = table(data(1+i_max:end-i_max,1), data(1+i_max:end-i_max,2), 'VariableNames', {'Voltage', 'Current'}); 
    myFit = fitlm(tbl,'Current ~ Voltage');    
    R                  = 1/myFit.Coefficients{2,1}; % R [Ohm] = 1/a
    deltaR             = abs(myFit.Coefficients{2,2}/myFit.Coefficients{2,1}^2); % deltaR [Ohm] = |delta_a/a^2|         
    Intercept          = myFit.Coefficients{1,1};
    R_squared_adjusted = myFit.Rsquared.Adjusted;
    switch display_mode
        case 'graphs_none' % do nothing
        otherwise % either 'graphs_all' or 'graphs_final'
            figure(4)
                % plot unused datapoint in gray
                plot( data([1:i_max end-(i_max-1):end],1), data([1:i_max end-(i_max-1):end],2), 'o', 'Color', [0.5 0.5 0.5], 'MarkerSize', 2 )
                hold on
                % plot used datapoints in blue, fit in red
                axes_object_1 = plot(data(1+i_max:end-i_max,1), data(1+i_max:end-i_max,2), 'ob', 'MarkerSize', 8 );
                axes_object_2 = plot(data(1+i_max:end-i_max,1), Intercept + data(1+i_max:end-i_max,1)/R, '-r', 'LineWidth', 2);
                hold off
                legend([axes_object_1, axes_object_2], ...
                       {['Data (' num2str(length(data)-2*i_max) ' points)'], ...
                        ['Fit: '  'R = (' num2str(R,'%.2e') '\pm'  num2str(deltaR, '%.2e') ') \Omega; ' ... % sprintf('\n') for newline character
                         'R^2_{adjusted} = ' num2str(R_squared_adjusted,'%.2f')], ...
                       }, 'Location', 'SouthEast');                
                mk_plot(['Final datapoints and fit with best R^2_{adjusted}, ' dataset_name ', ' num2str(i_max) ' datapoints cut from each side'], 'U [V]', 'I [A]', [], [], 6+user_pause, [0 0 1 1], 'tex')
    end
    %% Ende
end