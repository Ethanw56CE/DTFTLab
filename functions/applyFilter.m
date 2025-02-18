function filtered = applyFilter(input, filter, options)
% APPLYFILTER - Applies a filter to an input signal and optionally removes outliers.
%
% Syntax:
%   filtered = applyFilter(input, filter)
%   filtered = applyFilter(input, filter, options)
%
% Description:
%   This function applies a frequency-domain filter to an input signal and, if enabled, performs
%   outlier removal to improve signal quality. The function supports multiple interpolation
%   and filtering methods to adapt to different signal characteristics.
%
% Inputs:
%   input    - The input signal (vector)
%   filter   - The filter to be applied to the input signal (vector)
%   options  - Struct with optional fields:
%       • omega (vector)           - Frequency axis values (default: linspace(-pi, pi, length(input)))
%       • applyOutlierRemoval (bool) - Enable outlier removal (default: false)
%       • movSize (scalar)          - Window size for outlier detection (default: length(input)/100)
%       • outlierMethod (char)      - Method for detecting outliers (default: 'movmean')
%       • interpMethod (char)       - Interpolation method for replacing outliers (default: 'linear')
%       • resizeInterpMethod (char) - Interpolation method for resizing the filter (default: 'nearest')
%
% Outputs:
%   filtered - The filtered signal with optional outlier removal applied (vector)
%
% Example:
%   filteredSignal = applyFilter(signal, filter, applyOutlierRemoval = true);
%   magPlot(filteredSignal); title('Filtered Signal');
%
% Notes:
%   - If the filter length differs from the input signal, it will be resized using the specified resize method.
%   - If outlier removal is enabled, the function detects and replaces outliers using the chosen method.
%   - The function ensures that filtering is applied element-wise and preserves signal integrity.
%
% See also: bestLowPassFilter, removeOutliers, interp1

    arguments
        input (1,:) double
        filter (1,:) double
        options.omega (1,:) double = linspace(-pi, pi, length(input))
        options.applyOutlierRemoval (1,1) logical = false
        options.movSize (1,1) double = max(length(input)/100, 10)
        options.outlierMethod char {mustBeMember(options.outlierMethod, {'median','mean','quartiles', 'grubbs', 'gesd', 'movmedian', 'movmean'})} = 'movmean'
        options.interpMethod char {mustBeMember(options.interpMethod, {'linear','nearest','next', 'previous', 'spline', 'pchip', 'cubic', 'v5cubic', 'makima'})} = 'linear'
        options.resizeInterpMethod char {mustBeMember(options.resizeInterpMethod, {'linear','nearest','next', 'previous', 'spline', 'pchip', 'cubic', 'v5cubic', 'makima'})} = 'nearest'
    end

    % Ensure input and filter are of the same length
    if length(input) ~= length(filter)
        filter_resized = interp1(linspace(-pi, pi, length(filter)), filter, ...
                                 linspace(-pi, pi, length(input)), options.resizeInterpMethod);
    else
        filter_resized = filter;
    end

    % Apply the filter
    filtered = input .* filter_resized;

    % Remove outliers if enabled
    if options.applyOutlierRemoval
        filtered = removeOutliers(filtered, options.omega, movSize=options.movSize, outlierMethod=options.outlierMethod, interpMethod=options.interpMethod);
    end

end
