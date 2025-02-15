function [H_upsampled, omega_upsampled] = upsampleDTFT(H, omega, U, applyInterpLPF, applyOutlierRemoval, movSize, outlierMethod, interpMethod)
% UPSAMPLEDTFT - Upsamples a computed Discrete-Time Fourier Transform (DTFT) by a given factor.
% Optionally applies an interpolation low-pass filter and removes outliers.
%
% Syntax:
%   [H_upsampled, omega_upsampled] = upsampleDTFT(H, omega, U)
%   [H_upsampled, omega_upsampled] = upsampleDTFT(H, omega, U, applyInterpLPF)
%   [H_upsampled, omega_upsampled] = upsampleDTFT(H, omega, U, applyInterpLPF, applyOutlierRemoval)
%   [H_upsampled, omega_upsampled] = upsampleDTFT(H, omega, U, applyInterpLPF, applyOutlierRemoval, movSize)
%   [H_upsampled, omega_upsampled] = upsampleDTFT(H, omega, U, applyInterpLPF, applyOutlierRemoval, movSize, outlierMethod)
%   [H_upsampled, omega_upsampled] = upsampleDTFT(H, omega, U, applyInterpLPF, applyOutlierRemoval, movSize, outlierMethod, interpMethod)
%
% Description:
%   This function increases the resolution of a DTFT spectrum by upsampling it in the frequency domain.
%   Optionally, an interpolation low-pass filter can be applied to smooth the spectrum.
%   The function can also remove outliers introduced by the upsampling process.
%
% Inputs:
%   H                  - Fourier Transform values (vector)
%   omega              - Frequency axis values (vector)
%   U                  - Upsampling factor (integer > 1)
%   applyInterpLPF     - Boolean flag to apply an Interpolation LPF with cutoff pi/U and gain U (default: false)
%   applyOutlierRemoval - Boolean flag to apply outlier removal (default: false)
%   movSize            - Window size for outlier detection (default: length(H)/100)
%   outlierMethod      - Method for detecting outliers (default: "movmean")
%   interpMethod       - Interpolation method for replacing outliers (default: "linear")
%
% Outputs:
%   H_upsampled       - Upsampled Fourier Transform values (vector)
%   omega_upsampled   - New frequency axis values (vector)
%
% Example:
%   omega = linspace(-pi, pi, 1000);
%   H = sinc(omega/pi);
%   [H_up, omega_up] = upsampleDTFT(H, omega, 2, true);
%   plot(omega_up, abs(H_up)); title('Upsampled FT Magnitude');
%
% Notes:
%   - If `applyInterpLPF` is enabled, a low-pass filter with cutoff at pi/U is applied to smooth the upsampled signal.
%   - The function ensures aliasing is minimized by appropriately shifting the spectrum.
%   - Persistent memory storage is used for `omega_upsampled` to optimize repeated calls.
%   - When `applyOutlierRemoval` is enabled, the function detects and removes noise spikes after upsampling.
%
% See also: downsampleDTFT, bestLowPassFilter, removeOutliers, applyFilter

    % Validate upsampling factor
    if U <= 1 || mod(U, 1) ~= 0
        error('Upsampling factor must be an integer greater than 1.');
    end
    if nargin < 5 || isempty(applyOutlierRemoval)
        applyOutlierRemoval = false;
    end
    if nargin < 4 || isempty(applyInterpLPF)
        applyInterpLPF = false;
    end

    % Persistent memory optimization for omega_upsampled
    persistent prev_U prev_N prev_omega_upsampled;
    if isempty(prev_omega_upsampled) || U ~= prev_U || length(omega) ~= prev_N || length(omega) ~= length(H)
        prev_omega_upsampled = linspace(-pi, pi, length(H) * U);
        prev_U = U;
        prev_N = length(H);
        if isempty(omega) || length(omega) ~= length(H)
            omega = linspace(-pi, pi, length(H));
        end
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
    if applyInterpLPF
        LPF = U * bestLowPassFilter(H_upsampled, [], omega_upsampled, [], [], pi/U);
        H_upsampled = applyFilter(H_upsampled, LPF);
    end
    
    % Remove outliers if flag is set
    if applyOutlierRemoval
        if nargin < 6 || isempty(movSize)
            movSize = [];
        end
        if nargin < 7 || isempty(outlierMethod)
            outlierMethod = [];
        end
        if nargin < 8 || isempty(interpMethod)
            interpMethod = [];
        end
        H_upsampled = removeOutliers(H_upsampled, omega_upsampled, movSize, outlierMethod, interpMethod);
    end
end
