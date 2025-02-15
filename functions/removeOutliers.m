function cleanSignal = removeOutliers(signal, omega, movSize, outlierMethod, interpMethod)
% REMOVEOUTLIERS - Removes outliers from a signal and replaces them using interpolation.
%
% Syntax:
%   cleanSignal = removeOutliers(signal, omega)
%   cleanSignal = removeOutliers(signal, omega, movSize)
%   cleanSignal = removeOutliers(signal, omega, movSize, outlierMethod)
%   cleanSignal = removeOutliers(signal, omega, movSize, [], interpMethod)
%   cleanSignal = removeOutliers(signal, omega, movSize, outlierMethod, interpMethod)
%
% Description:
%   This function detects and removes outliers in a signal based on a specified method.
%   It then replaces the removed values using interpolation to maintain signal continuity.
%   The function dynamically adjusts the moving window size to improve outlier detection.
%
% Inputs:
%   signal        - Input signal (vector) with potential outliers.
%   omega         - Corresponding x-values for interpolation.
%   movSize       - (Optional) Window size for outlier detection. Default is adaptive based on signal length.
%   outlierMethod - (Optional) Method for detecting outliers (default: "movmean").
%   interpMethod  - (Optional) Interpolation method for replacing outliers (default: "linear").
%
% Outputs:
%   cleanSignal   - Signal with outliers removed and replaced via interpolation.
%
% Example:
%   omega = linspace(-pi, pi, 1000);
%   signal = sin(omega) + 0.2*randn(size(omega));
%   signal(400:420) = 3; % Introduce artificial outliers
%   cleanSignal = removeOutliers(signal, omega);
%   plot(omega, cleanSignal);
%   title('Outliers Removed from Signal');
%
% Notes:
%   **Only use outlier removal on user defined DTFTs (like in Example 1) 
%   Using outlier removal on transformed time signals will remove
%   fundamental frequencies**
%   - Uses an iterative approach to refine outlier detection and correction.
%   - Reduces movSize adaptively to improve precision in detecting smaller-scale outliers.
%   - Interpolates missing values using either gridded interpolation (for large datasets) or standard interpolation.
%   - Prevents infinite loops by limiting the number of iterations for outlier correction.
%   - Calls removeNaNs to ensure no NaN values remain in the final cleaned signal.
%
% See also: isoutlier, interp1, griddedInterpolant, removeNaNs

    % Set default values for optional arguments
    if nargin < 3 || isempty(movSize)
        if length(signal) >= 100
            movSize = max(length(signal)/100, 100); % Default movSize for large signals
        elseif length(signal) >= 10
            movSize = length(signal)/10; % Adjust movSize for medium-sized signals
        else
            movSize = length(signal); % Use full length for small signals
        end
    end
    if nargin < 4 || isempty(outlierMethod)
        outlierMethod = "movmean"; % Default outlier detection method
    end
    if nargin < 5 || isempty(interpMethod)
        interpMethod = "linear"; % Default interpolation method
    end

    while movSize >= 10
        % Identify outliers using the specified method
        outliers = isoutlier(signal, outlierMethod, movSize);
        maxIterations = 10; % Prevent infinite loops
        iter = 0;
        
        while any(outliers) && iter < maxIterations
            % Use efficient interpolation method for large datasets
            if length(signal) > 500000
                F = griddedInterpolant(omega(~outliers), signal(~outliers), interpMethod);
                signal(outliers) = F(omega(outliers));
            else
                % Use standard interpolation for smaller datasets
                signal(outliers) = interp1(omega(~outliers), signal(~outliers), omega(outliers), interpMethod, 'extrap');
            end
            % Recompute outliers after interpolation
            outliers = isoutlier(signal, outlierMethod, movSize);
            iter = iter + 1;
        end
        
        % Reduce movSize gradually to refine outlier detection
        movSize = movSize / sqrt(10);
    end
    
    % Ensure no NaN values remain in the final cleaned signal
    cleanSignal = removeNaNs(signal, omega, interpMethod);
end