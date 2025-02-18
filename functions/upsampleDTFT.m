function [H_upsampled, omega_upsampled] = upsampleDTFT(H, omega, U, options)
% UPSAMPLEDTFT - Upsamples a computed Discrete-Time Fourier Transform (DTFT) by a given factor.
% Optionally applies an interpolation low-pass filter and removes outliers.
%
% Syntax:
%   [H_upsampled, omega_upsampled] = upsampleDTFT(H, omega, U)
%   [H_upsampled, omega_upsampled] = upsampleDTFT(H, omega, U, options)
%
% Description:
%   This function increases the resolution of a DTFT spectrum by upsampling it in the frequency domain.
%   Optionally, an interpolation low-pass filter can be applied to smooth the spectrum.
%   The function can also remove outliers introduced by the upsampling process.
%
% Inputs:
%   H        - Fourier Transform values (vector)
%   omega    - Frequency axis values (vector) (automatically set if not same length as H)
%   U        - Upsampling factor (integer > 1)
%   options  - Struct with optional fields:
%       • applyInterpLPF (bool)   - Apply an Interpolation LPF with cutoff pi/U and gain U (default: false)
%       • applyOutlierRemoval (bool) - Apply outlier removal after upsampling (default: false)
%       • movSize (scalar)        - Window size for outlier detection (default: length(H)/100)
%       • outlierMethod (char)    - Method for detecting outliers (default: "movmean")
%       • interpMethod (char)     - Interpolation method for replacing outliers (default: "linear")
%
% Outputs:
%   H_upsampled    - Upsampled Fourier Transform values (vector)
%   omega_upsampled - New frequency axis values (vector)
%
% Example:
%   options.applyInterpLPF = true;
%   options.applyOutlierRemoval = true;
%   [H_up, omega_up] = upsampleDTFT(H, omega, 2, options);
%   plot(omega_up, abs(H_up)); title('Upsampled FT Magnitude');
%
% Notes:
%   - If `applyInterpLPF` is enabled, a low-pass filter with cutoff at pi/U is applied to smooth the upsampled signal.
%   - The function ensures aliasing is minimized by appropriately shifting the spectrum.
%   - Persistent memory storage is used for `omega_upsampled` to optimize repeated calls.
%   - When `applyOutlierRemoval` is enabled, the function detects and removes noise spikes after upsampling.
%
% See also: downsampleDTFT, bestLowPassFilter, removeOutliers, applyFilter

    arguments
        H (1,:) double
        omega (1,:) double
        U (1,1) {mustBeInteger, mustBeGreaterThan(U,1)}
        options.applyInterpLPF (1,1) logical = false
        options.applyOutlierRemoval (1,1) logical = false
        options.movSize (1,1) double = max(length(H)/100, 10)
        options.outlierMethod char {mustBeMember(options.outlierMethod, {'median','mean','quartiles', 'grubbs', 'gesd', 'movmedian', 'movmean'})} = 'movmean'
        options.interpMethod char {mustBeMember(options.interpMethod, {'linear','nearest','next', 'previous', 'spline', 'pchip', 'cubic', 'v5cubic', 'makima'})} = 'linear'
    end

    % Ensure omega matches H in length; if not, generate default omega
    if length(omega) ~= length(H)
        warning('omega length does not match H. Resetting omega to linspace(-pi, pi, length(H)).');
        omega = linspace(-pi, pi, length(H));
    end

    % Persistent memory optimization for omega_upsampled
    persistent prev_U prev_N prev_omega_upsampled;
    if isempty(prev_omega_upsampled) || U ~= prev_U || length(omega) ~= prev_N
        prev_omega_upsampled = linspace(-pi, pi, length(H) * U);
        prev_U = U;
        prev_N = length(H);
    end
    
    % Define new upsampled omega vector
    omega_upsampled = prev_omega_upsampled;
    
    % Interpolate H(e^(jw)) onto the scaled frequency axis
    if length(H) > 500000
        F = griddedInterpolant(omega, H, 'linear');
        H_upsampled = F(mod(omega_upsampled * U + pi, 2*pi) - pi);
    else
        H_upsampled = interp1(omega, H, mod(omega_upsampled * U + pi, 2*pi) - pi, 'linear', 0);
    end
    
    % Apply Interpolation Low-Pass Filter if flag is set
    if options.applyInterpLPF
        LPF = U * bestLowPassFilter(H_upsampled, struct('cutoff', pi/U));
        H_upsampled = applyFilter(H_upsampled, LPF);
    end
    
    % Remove outliers if flag is set
    if options.applyOutlierRemoval
        H_upsampled = removeOutliers(H_upsampled, omega_upsampled, movSize=options.movSize, outlierMethod=options.outlierMethod, interpMethod=options.interpMethod);
    end
end
