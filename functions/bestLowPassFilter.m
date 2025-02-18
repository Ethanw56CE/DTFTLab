function H_filter = bestLowPassFilter(signal, options)
% BESTLOWPASSFILTER - Creates an optimal low-pass filter for DTFT signals.
%
% Syntax:
%   H_filter = bestLowPassFilter(signal)
%   H_filter = bestLowPassFilter(signal, options)
%
% Description:
%   This function creates a frequency-domain low-pass filter for DTFT signals.
%   The cutoff frequency can be automatically determined using a threshold gain or manually specified.
%   Various smoothing methods are supported, including Tukey, Gaussian, and Raised-Cosine filters.
%
% Inputs:
%   signal   - DTFT signal magnitude (vector)
%   options  - Struct with optional fields:
%       • thresholdGain (scalar) - Threshold gain as a fraction of max magnitude (default: 0.1)
%       • omega (vector)         - Frequency axis values (default: linspace(-pi, pi, length(signal)))
%       • transition (scalar)     - Transition width (default: pi/10, smaller = sharper cutoff)
%       • method (char)           - Filter design method: 'ideal', 'tukey', 'gaussian', 'raised-cosine' (default: 'ideal')
%       • cutoff (scalar)         - User-defined cutoff frequency (optional, overrides threshold-based calculation)
%
% Outputs:
%   H_filter - Optimized low-pass filter in the frequency domain (vector)
%
% Example:
%   H_filter = bestLowPassFilter(some_DTFT_signal, thresholdGain=0.1, method='tukey');
%   magPlot(H_filter); title('Low-Pass Filter Response');
%
% Notes:
%   - If `cutoff` is not specified, it is calculated using `thresholdGain`.
%   - If `method` is not specified, the filter defaults to an ideal low-pass.
%
% See also: applyFilter, removeOutliers

    arguments
        signal (1,:) double
        options.thresholdGain (1,1) double = 0.1
        options.omega (1,:) double = linspace(-pi, pi, length(signal))
        options.transition (1,1) double = pi/10
        options.method char {mustBeMember(options.method, {'ideal', 'tukey', 'gaussian', 'raised-cosine'})} = 'ideal'
        options.cutoff (1,1) double = NaN
    end

    % Determine cutoff frequency
    if isnan(options.cutoff)
        % Dynamically calculate cutoff frequency based on signal magnitude
        threshold = options.thresholdGain * max(signal);
        cutoff_idx = find(abs(signal) >= threshold, 1, 'last');
        options.cutoff = abs(options.omega(cutoff_idx));
    end

    % Initialize filter response
    H_filter = zeros(size(options.omega));

    % Create filter based on selected method
    switch lower(options.method)
        case 'ideal'
            % Ideal low-pass filter (rectangular window)
            H_filter(abs(options.omega) <= options.cutoff) = 1;

        case 'tukey'
            % Tukey (tapered cosine) window for smooth transition
            H_filter = 0.5 * (1 + cos(pi * (abs(options.omega) - options.cutoff) / options.transition));
            H_filter(abs(options.omega) <= options.cutoff) = 1;
            H_filter(abs(options.omega) > (options.cutoff + options.transition)) = 0;

        case 'gaussian'
            % Gaussian low-pass filter (smoothest roll-off)
            H_filter = exp(-((abs(options.omega) - options.cutoff).^2) / (2 * (options.transition^2)));
            H_filter(abs(options.omega) <= options.cutoff) = 1;

        case 'raised-cosine'
            % Raised cosine filter with smooth transition
            H_filter = 0.5 * (1 + cos(pi * (abs(options.omega) - options.cutoff) / options.transition));
            H_filter(abs(options.omega) <= options.cutoff) = 1;
            H_filter(abs(options.omega) > (options.cutoff + options.transition)) = 0;

        otherwise
            error('Invalid filter method. Choose from: ideal, tukey, gaussian, raised-cosine');
    end
end
