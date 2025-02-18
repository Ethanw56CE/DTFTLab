function [H_downsampled, omega_downsampled] = downsampleDTFT(H, omega, D, options)
% DOWNSAMPLEDTFT - Downsamples a DTFT by a given factor.
% Optionally applies a decimation low-pass filter and removes outliers.
%
% Syntax:
%   [H_downsampled, omega_downsampled] = downsampleDTFT(H, omega, D)
%   [H_downsampled, omega_downsampled] = downsampleDTFT(H, omega, D, options)
%
% Description:
%   This function downsamples a DTFT signal by a factor of D in the frequency domain.
%   It optionally applies a decimation low-pass filter before downsampling and
%   removes outliers to improve signal stability.
%
% Inputs:
%   H        - DTFT values (vector)
%   omega    - Frequency axis values (vector)
%   D        - Downsampling factor (integer > 1)
%   options  - Struct with optional fields:
%       • applyDecimLPF (bool) - Apply decimation LPF (pi/D) with gain 1 before downsampling (default: false)
%       • applyOutlierRemoval (bool) - Apply outlier removal (default: false)
%       • movSize (scalar) - Window size for outlier detection (default: length(H)/100)
%       • outlierMethod (char) - Method for detecting outliers (default: 'movmean')
%       • interpMethod (char) - Interpolation method for frequency shifting and outlier replacement (default: 'linear')
%
% Outputs:
%   H_downsampled - Downsampled DTFT values
%   omega_downsampled - New frequency axis values
%
% Example:
%   [H_ds, omega_ds] = downsampleDTFT(H, omega, 2, applyOutlierRemoval=true);
%   plot(omega_ds, abs(H_ds)); title('Downsampled DTFT Magnitude');
%
% Notes:
%   - If `applyDecimLPF` is enabled, a low-pass filter with cutoff at pi/D is applied before downsampling.
%   - Downsampling in the frequency domain results in aliasing effects that must be summed correctly.
%   - The function detects discontinuities and selects appropriate interpolation methods to minimize distortion.
%   - Persistent memory storage is used for `omega_downsampled` to optimize repeated calls.
%   - When `applyOutlierRemoval` is enabled, the function detects and removes noise spikes before returning the output.
%
% See also: upsampleDTFT, bestLowPassFilter, removeOutliers, freq_shift_periodic

    arguments
        H (1,:) double
        omega (1,:) double
        D (1,1) {mustBeInteger, mustBeGreaterThan(D,1)}
        options.applyDecimLPF (1,1) logical = false
        options.applyOutlierRemoval (1,1) logical = false
        options.movSize (1,1) double = max(length(H)/100, 10)
        options.outlierMethod char {mustBeMember(options.outlierMethod, {'median','mean','quartiles', 'grubbs', 'gesd', 'movmedian', 'movmean'})} = 'movmean'
        options.interpMethod char {mustBeMember(options.interpMethod, {'linear','nearest','next', 'previous', 'spline', 'pchip', 'cubic', 'v5cubic', 'makima'})} = 'linear'
    end

    % Persistent memory optimization for omega_downsampled
    persistent prev_D prev_N prev_omega_downsampled;
    if isempty(prev_omega_downsampled) || D ~= prev_D || length(omega) ~= prev_N || length(omega) ~= length(H)
        prev_omega_downsampled = linspace(-pi, pi, floor(length(H) / D));
        prev_D = D;
        prev_N = length(H);
    end
    omega_downsampled = prev_omega_downsampled;

    % Apply Decimation Low-Pass Filter if flag is set
    if options.applyDecimLPF
        LPF = bestLowPassFilter(H, struct('cutoff', pi/D));
        H = applyFilter(H, LPF);
    end

    % Detect if function is **piecewise linear** (i.e., has discontinuities)
    isPiecewiseLinear = max(abs(diff(H))) > 0.1 * (max(H) - min(H));

    % Choose interpolation method:
    if isPiecewiseLinear && strcmp(options.interpMethod, 'linear')
        interpMethod = 'pchip'; % Preserve shape better
    else
        interpMethod = options.interpMethod;
    end

    % Initialize downsampled DTFT with reduced size
    H_downsampled = zeros(size(omega_downsampled));

    % Perform aliasing sum for frequency compression
    for k = 0:D-1
        shifted_omega = freq_shift_periodic(omega_downsampled / D, 2 * pi * k / D);

        % Interpolate at new frequency points
        if length(H) > 500000
            F = griddedInterpolant(omega, H, interpMethod);
            component = F(shifted_omega);
        else
            component = interp1(omega, H, shifted_omega, interpMethod, 'extrap');
        end

        % Sum aliasing components into the downsampled spectrum
        H_downsampled = H_downsampled + component;
    end

    % Normalize downsampled result
    H_downsampled = H_downsampled / D;

    % Remove outliers if flag is set
    if options.applyOutlierRemoval
        H_downsampled = removeOutliers(H_downsampled, omega_downsampled, movSize=options.movSize, outlierMethod=options.outlierMethod, interpMethod=options.interpMethod);
    end

end
