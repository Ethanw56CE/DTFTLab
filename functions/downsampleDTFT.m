function [H_downsampled, omega_downsampled] = downsampleDTFT(H, omega, D, applyDecimLPF, applyOutlierRemoval, movSize, outlierMethod, interpMethod)
% DOWNSAMPLEDTFT - Downsamples a computed Fourier Transform by a given factor.
% Optionally applies a decimation low-pass filter and removes outliers.
%
% Syntax:
%   [H_downsampled, omega_downsampled] = downsampleDTFT(H, omega, D)
%   [H_downsampled, omega_downsampled] = downsampleDTFT(H, omega, D, applyDecimLPF)
%   [H_downsampled, omega_downsampled] = downsampleDTFT(H, omega, D, applyDecimLPF, applyOutlierRemoval)
%   [H_downsampled, omega_downsampled] = downsampleDTFT(H, omega, D, applyDecimLPF, applyOutlierRemoval, movSize)
%   [H_downsampled, omega_downsampled] = downsampleDTFT(H, omega, D, applyDecimLPF, applyOutlierRemoval, movSize, outlierMethod)
%   [H_downsampled, omega_downsampled] = downsampleDTFT(H, omega, D, applyDecimLPF, applyOutlierRemoval, movSize, outlierMethod, interpMethod)
%
% Description:
%   This function performs frequency-domain downsampling by a factor of D. It first applies an optional
%   decimation low-pass filter to prevent aliasing, then compresses the frequency spectrum and sums
%   aliased components appropriately. Additionally, an optional outlier removal step is available to
%   improve signal stability.
%
% Inputs:
%   H                  - Fourier Transform values (vector)
%   omega              - Frequency axis values (vector)
%   D                  - Downsampling factor (integer > 1)
%   applyDecimLPF      - Boolean flag to apply a Decimation LPF with cutoff pi/D before downsampling (default: false)
%   applyOutlierRemoval - Boolean flag to apply outlier removal (default: false)
%   movSize            - Window size for outlier detection (default: length(H)/100)
%   outlierMethod      - Method for detecting outliers (default: 'movmean')
%   interpMethod       - Interpolation method for frequency shifting and outlier replacement (default: 'linear')
%
% Outputs:
%   H_downsampled      - Downsampled Fourier Transform values (vector)
%   omega_downsampled  - New frequency axis values (vector)
%
% Example:
%   omega = linspace(-pi, pi, 1000);
%   H = exp(-1j * omega); % Example FT signal
%   [H_ds, omega_ds] = downsampleDTFT(H, omega, 2, true);
%   plot(omega_ds, abs(H_ds)); title('Downsampled FT Magnitude');
%
% Notes:
%   - If `applyDecimLPF` is enabled, a low-pass filter with cutoff at pi/D is applied before downsampling.
%   - Downsampling in the frequency domain results in aliasing effects that must be summed correctly.
%   - The function detects discontinuities and selects appropriate interpolation methods to minimize distortion.
%   - Persistent memory storage is used for `omega_downsampled` to optimize repeated calls.
%   - When `applyOutlierRemoval` is enabled, the function detects and removes noise spikes before returning the output.
%
% See also: upsampleDTFT, bestLowPassFilter, removeOutliers, freq_shift_periodic

    % Validate downsampling factor
    if D <= 1 || mod(D, 1) ~= 0
        error('Downsampling factor must be an integer greater than 1.');
    end
    if nargin < 4 || isempty(applyDecimLPF)
        applyDecimLPF = false;
    end
    if nargin < 5 || isempty(applyOutlierRemoval)
        applyOutlierRemoval = false;
    end

    % Persistent memory optimization for omega_downsampled
    persistent prev_D prev_N prev_omega_downsampled;
    if isempty(prev_omega_downsampled) || D ~= prev_D || length(omega) ~= prev_N || length(omega) ~= length(H)
        prev_omega_downsampled = linspace(-pi, pi, floor(length(H) / D));
        prev_D = D;
        prev_N = length(H);
        if isempty(omega) || length(omega) ~= length(H)
            omega = linspace(-pi, pi, length(H));
        end
    end

    % Apply Decimation Low-Pass Filter if flag is set
    if applyDecimLPF
        LPF = bestLowPassFilter(H, [], omega, [], [], pi/D);
        H = applyFilter(H, LPF);
    end

    % Define new downsampled omega vector
    omega_downsampled = prev_omega_downsampled;

    % Detect if function is **piecewise linear** (i.e., has discontinuities)
    isPiecewiseLinear = max(abs(diff(H))) > 0.1*(max(H)-min(H)); % Detect sharp changes
    
    % Choose interpolation method:
    if isPiecewiseLinear
        interpMethod = 'pchip'; % Preserve shape better
    else 
        if nargin < 8 || isempty(interpMethod)
            interpMethod = 'linear'; % Default
        end
    end
    
    % Initialize downsampled Fourier Transform with reduced size
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
    if applyOutlierRemoval
        if nargin < 6 || isempty(movSize)
            movSize = [];
        end
        if nargin < 7 || isempty(outlierMethod)
            outlierMethod = [];
        end
        H_downsampled = removeOutliers(H_downsampled, omega_downsampled, movSize, outlierMethod, interpMethod);
    end

end
