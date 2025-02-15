function magPlot(H, plotNegative, subplotMode, omega, yRange, dynamicXRange)
% MAGPLOT - Plots the magnitude of the Fourier Transform.
%
% Syntax:
%   magPlot(H)                              % Default: magnitude plot in new figure
%   magPlot(H, true)                        % Negative values plot in new figure
%   magPlot(H, false, true)                 % Add magnitude plot to subplot
%   magPlot(H, true, true, omega, yRange)   % Add negative plot to subplot with custom omega & yRange
%
% Description:
%   This function plots the magnitude of a given Fourier Transform signal.
%   It allows the user to choose between absolute magnitude or raw values,
%   supports subplots, and dynamically adjusts the frequency and magnitude ranges.
%
% Inputs:
%   H                - Fourier Transform values (vector)
%   plotNegative     - Boolean flag (true = show negative values, false = plot magnitude) (default: false)
%   subplotMode      - Boolean flag (true = do NOT create a new figure, false = create new figure) (default: false)
%   omega            - Frequency axis values (default: linspace(-pi, pi, length(H)))
%   yRange           - Y-axis range (default: dynamically determined based on signal properties)
%   dynamicXRange    - Boolean flag (true = limit X-axis based on values abs(H)>0, false = [-pi, pi]) (default: false)
%
% Outputs:
%   A plot of |H| or H depending on plotNegative, optionally within a subplot.
%
% Example:
%   omega = linspace(-pi, pi, 1000);
%   H = sinc(omega/pi);
%   magPlot(H);
%   magPlot(H, true);
%   magPlot(H, false, true, omega, [-1,1], true);
%
% Notes:
%   - If `plotNegative` is enabled, real values of H will be plotted instead of magnitude.
%   - If `dynamicXRange` is true, the X-axis limits are dynamically adjusted based on the presence of significant values.
%   - Uses LaTeX formatting for axis labels.
%
% See also: plotReIm

    % Set default plotNegative to false (plot abs(H))
    if nargin < 2 || isempty(plotNegative)
        plotNegative = false;
    end

    % Get the variable name for labeling
    name = inputname(1);
    if isempty(name)
        name = 'H';
    end
    formattedName = strrep(name, '_', '\_');

    % Determine whether to plot absolute magnitude or raw values
    if plotNegative
        if isreal(H)
            yData = H;
        else
            warning(['Cannot plot "negative magnitude" for complex signal: ', name, '. Use "plotReIm()" for 3D plot.']);
            yData = real(H);
        end
    else
        yData = abs(H);
    end

    % Set default subplotMode to false (create a new figure)
    if nargin < 3 || isempty(subplotMode)
        subplotMode = false;
    end

    % Set default omega if not provided
    if nargin < 4 || isempty(omega)
        omega = linspace(-pi, pi, length(H));
    end
    
    % Set yRange dynamically based on signal min/max if not provided
    if nargin < 5 || isempty(yRange)
        dataMin = min(yData);
        dataMax = max(yData);
        tolerance = 1e-6 * abs(dataMax);
    
        if abs(dataMax - dataMin) < tolerance
            buffer = max(0.05 * abs(dataMin), 0.05);
            yRange = [dataMin - buffer, dataMax + buffer];
        else
            buffer = 0.1 * (dataMax - dataMin);
            yRange = [dataMin - buffer, dataMax + buffer];
        end
    end
    
    % Set dynamicXRange to false if not provided
    if nargin < 6 || isempty(dynamicXRange)
        dynamicXRange = false;
    end
    if dynamicXRange
        bounds = find(abs(yData) > 0);
        xmin = max(omega(bounds(1)) * 1.05, -pi);
        xmax = min(omega(bounds(end)) * 1.05, pi);
    else
        xmin = -pi; xmax = pi;
    end

    % Define tick values and labels for the x-axis
    xtick_vals = [-pi, -pi*3/4, -pi/2, -pi/4, 0, pi/4, pi/2, pi*3/4, pi];
    xtick_labels = {'-\pi', '-3\pi/4', '-\pi/2', '-\pi/4', '0', '\pi/4', '\pi/2', '3\pi/4', '\pi'};

    % Create a new figure only if subplotMode is false
    if ~subplotMode
        figure;
    end

    % Plot the data
    plot(omega, yData, 'LineWidth', 1.5);
    title(['Magnitude of ', formattedName, '(e^{j\omega})']);
    xlabel('\omega');
    ylabel(['|', formattedName, '(e^{j\omega})|']);
    xticks(xtick_vals);
    xticklabels(xtick_labels);
    ylim(yRange);
    xlim([xmin, xmax]);
    grid on;
end
