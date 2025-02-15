function filtered = applyFilter(input, filter, applyOutlierRemoval, omega, movSize, outlierMethod, interpMethod, resizeInterpMethod)
% APPLYFILTER - Applies a filter to an input signal and optionally removes outliers.
%
% Syntax:
%   filtered = applyFilter(input, filter)
%   filtered = applyFilter(input, filter, applyOutlierRemoval)
%   filtered = applyFilter(input, filter, applyOutlierRemoval, omega)
%   filtered = applyFilter(input, filter, applyOutlierRemoval, omega, movSize)
%   filtered = applyFilter(input, filter, applyOutlierRemoval, omega, movSize, outlierMethod)
%   filtered = applyFilter(input, filter, applyOutlierRemoval, omega, movSize, outlierMethod, interpMethod)
%   filtered = applyFilter(input, filter, applyOutlierRemoval, omega, movSize, outlierMethod, interpMethod, resizeInterpMethod)
%
% Description:
%   This function applies a frequency-domain filter to an input signal and, if enabled, performs
%   outlier removal to improve signal quality. The function supports multiple interpolation
%   and filtering methods to adapt to different signal characteristics.
%
% Inputs:
%   input               - The input signal (vector)
%   filter              - The filter to be applied to the input signal (vector)
%   applyOutlierRemoval - Boolean flag to apply outlier removal (default: false)
%   omega               - Frequency axis values (vector, default: linspace(-pi, pi, length(input)))
%   movSize             - Window size for moving average-based outlier detection (default: length(input)/100)
%   outlierMethod       - Method for detecting outliers (default: 'movmean')
%   interpMethod        - Interpolation method for replacing outliers (default: 'linear')
%   resizeInterpMethod  - Interpolation method for resizing the filter if needed (default: 'nearest')
%
% Outputs:
%   filtered            - The filtered signal with optional outlier removal applied (vector)
%
% Example:
%   omega = linspace(-pi, pi, 1000);
%   signal = sin(omega) + 0.2*randn(size(omega));
%   filter = bestLowPassFilter(signal, 0.1);
%   filteredSignal = applyFilter(signal, filter, true);
%   plot(omega, abs(filteredSignal)); title('Filtered Signal');
%
% Notes:
%   - If the filter length differs from the input signal, it will be resized using the specified resize method.
%   - If outlier removal is enabled, the function detects and replaces outliers using the chosen method.
%   - The function ensures that filtering is applied element-wise and preserves signal integrity.
%
% See also: bestLowPassFilter, removeOutliers, interp1

    % Set default parameters if not provided
    if nargin < 3 || isempty(applyOutlierRemoval)
        applyOutlierRemoval = false;
    end
    if nargin < 4 || isempty(omega)
        omega = linspace(-pi, pi, length(input));
    end
    if nargin < 5 || isempty(movSize)
        movSize = max(length(input)/100, 10);
    end
    if nargin < 6 || isempty(outlierMethod)
        outlierMethod = 'movmean';
    end
    if nargin < 7 || isempty(interpMethod)
        interpMethod = 'linear';
    end
    if nargin < 8 || isempty(resizeInterpMethod)
        resizeInterpMethod = 'nearest';
    end

    % Ensure input and filter are of the same length
    if length(input) ~= length(filter)
        filter_resized = interp1(linspace(-pi, pi, length(filter)), filter, linspace(-pi, pi, length(input)), resizeInterpMethod);
    else
        filter_resized = filter;
    end

    % Apply the filter
    filtered = input .* filter_resized;

    % Remove outliers if enabled
    if applyOutlierRemoval
        filtered = removeOutliers(filtered, omega, movSize, outlierMethod, interpMethod);
    end

end
