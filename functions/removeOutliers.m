function cleanSignal = removeOutliers(signal, omega, options)
% REMOVEOUTLIERS - Removes outliers from a signal and replaces them using interpolation.
%
% Syntax:
%   cleanSignal = removeOutliers(signal, omega)
%   cleanSignal = removeOutliers(signal, omega, options)
%
% Description:
%   This function detects and removes outliers from a given signal based on a 
%   specified method. Outliers are replaced using interpolation. 
%
% Inputs:
%   signal  - Input signal (vector) with potential outliers
%   omega   - Corresponding x-values for interpolation
%   options - Struct with optional fields:
%       • movSize (scalar)       - Window size for outlier detection (default: length(signal)/100)
%       • outlierMethod (char)   - Method for detecting outliers (default: 'movmean')
%       • interpMethod (char)    - Interpolation method for replacing outliers (default: 'linear')
%
% Outputs:
%   cleanSignal - Output signal with outliers replaced via interpolation
%
% Example:
%   options.movSize = 20;
%   options.outlierMethod = 'movmedian';
%   cleanSignal = removeOutliers(signal, omega, options);
%
% Notes:
%   - If `movSize` is not specified, it defaults to length(signal)/100.
%   - If `outlierMethod` is not specified, it defaults to 'movmean'.
%   - If `interpMethod` is not specified, it defaults to 'linear'.
%   - Uses `isoutlier` for detecting outliers and `interp1` for interpolation.
%
% See also: removeNaNs, interp1, isoutlier

    arguments
        signal (1,:) double
        omega (1,:) double
        options.movSize (1,1) double = max(length(signal)/100, 10)
        options.outlierMethod char {mustBeMember(options.outlierMethod, {'median','mean','quartiles', 'grubbs', 'gesd', 'movmedian', 'movmean'})} = 'movmean'
        options.interpMethod char {mustBeMember(options.interpMethod, {'linear','nearest','next', 'previous', 'spline', 'pchip', 'cubic', 'v5cubic', 'makima'})} = 'linear'
    end

    while options.movSize >= 10
        % Identify outliers using the specified method
        outliers = isoutlier(signal, options.outlierMethod, options.movSize);
        maxIterations = 10; % Prevent infinite loops
        iter = 0;
        
        while any(outliers) && iter < maxIterations
            % Use efficient interpolation method for large datasets
            if length(signal) > 500000
                F = griddedInterpolant(omega(~outliers), signal(~outliers), options.interpMethod);
                signal(outliers) = F(omega(outliers));
            else
                % Use standard interpolation for smaller datasets
                signal(outliers) = interp1(omega(~outliers), signal(~outliers), omega(outliers), options.interpMethod, 'extrap');
            end
            % Recompute outliers after interpolation
            outliers = isoutlier(signal, options.outlierMethod, options.movSize);
            iter = iter + 1;
        end
        
        % Reduce movSize gradually to refine outlier detection
        options.movSize = options.movSize / sqrt(10);
    end
    
    % Ensure no NaN values remain in the final cleaned signal
    cleanSignal = removeNaNs(signal, omega, options.interpMethod);
end
