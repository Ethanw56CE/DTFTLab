function magPlot(H, options)
% MAGPLOT - Plots the magnitude of the Fourier Transform.
%
% Syntax:
%   magPlot(H)                        % Default: magnitude plot in new figure
%   magPlot(H, options)                % Customize with name-value pairs
%
% Description:
%   This function plots the magnitude of a given Fourier Transform signal.
%   It allows the user to choose between absolute magnitude or raw values,
%   supports subplots, and dynamically adjusts the frequency and magnitude ranges.
%
% Inputs:
%   H        - Fourier Transform values (vector)
%   options  - Struct with optional fields:
%       • plotNegative (bool)   - Show raw values instead of magnitude (default: false)
%       • subplotMode (bool)    - If true, do not create a new figure (default: false)
%       • omega (vector)        - Frequency axis values (default: linspace(-pi, pi, length(H)))
%       • yRange (vector)       - Y-axis range (default: dynamically determined)
%       • dynamicXRange (bool)  - Adjust X-axis based on significant values (default: false)
%
% Outputs:
%   A plot of |H| or H depending on plotNegative, optionally within a subplot.
%
% Example:
%   omega = linspace(-pi, pi, length(H));
%   magPlot(H, plotNegative=true, omega=omega);
%
% Notes:
%   - If `plotNegative` is enabled, real values of H will be plotted instead of magnitude.
%   - If `dynamicXRange` is true, the X-axis limits are dynamically adjusted based on significant values.
%   - Uses LaTeX formatting for axis labels.
%
% See also: plotReIm

    arguments
        H (1,:) double
        options.plotNegative (1,1) logical = false
        options.subplotMode (1,1) logical = false
        options.omega (1,:) double = linspace(-pi, pi, length(H))
        options.yRange (1,2) double = [NaN NaN] % Auto-determined if NaN
        options.dynamicXRange (1,1) logical = false
    end

    % Get the variable name for labeling
    name = inputname(1);
    if isempty(name)
        name = 'H';
    end
    formattedName = strrep(name, '_', '\_');

    % Determine whether to plot absolute magnitude or raw values
    if options.plotNegative
        if isreal(H)
            yData = H;
        else
            warning(['Cannot plot "negative magnitude" for complex signal: ', name, '. Use "plotReIm()" for 3D plot.']);
            yData = real(H);
        end
    else
        yData = abs(H);
    end

    % Set default yRange dynamically based on signal min/max
    if any(isnan(options.yRange))
        dataMin = min(yData);
        dataMax = max(yData);
        tolerance = 1e-6 * abs(dataMax);
        if abs(dataMax - dataMin) < tolerance
            buffer = max(0.05 * abs(dataMin), 0.05);
            options.yRange = [dataMin - buffer, dataMax + buffer];
        else
            buffer = 0.1 * (dataMax - dataMin);
            options.yRange = [dataMin - buffer, dataMax + buffer];
        end
    end

    % Determine X-axis range dynamically
    if options.dynamicXRange
        bounds = find(abs(yData) > 0);
        xmin = max(options.omega(bounds(1)) * 1.05, -pi);
        xmax = min(options.omega(bounds(end)) * 1.05, pi);
    else
        xmin = -pi;
        xmax = pi;
    end

    % Define tick values and labels for the x-axis
    xtick_vals = [-pi, -pi*3/4, -pi/2, -pi/4, 0, pi/4, pi/2, pi*3/4, pi];
    xtick_labels = {'-\pi', '-3\pi/4', '-\pi/2', '-\pi/4', '0', '\pi/4', '\pi/2', '3\pi/4', '\pi'};

    % Create a new figure only if subplotMode is false
    if ~options.subplotMode
        figure;
    end

    % Plot the data
    plot(options.omega, yData, 'LineWidth', 1.5);
    title(['Magnitude of ', formattedName, '(e^{j\omega})']);
    xlabel('\omega');
    ylabel(['|', formattedName, '(e^{j\omega})|']);
    xticks(xtick_vals);
    xticklabels(xtick_labels);
    ylim(options.yRange);
    xlim([xmin, xmax]);
    grid on;
end
