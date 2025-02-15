function H_filter = bestLowPassFilter(signal, thresholdGain, omega, transition, method, cutoff)
% BESTLOWPASSFILTER - Creates an optimal low-pass filter for DTFT signals.
%
% Syntax:
%   H_filter = bestLowPassFilter(signal, thresholdGain)
%   H_filter = bestLowPassFilter(signal, thresholdGain, omega)
%   H_filter = bestLowPassFilter(signal, thresholdGain, omega, transition)
%   H_filter = bestLowPassFilter(signal, thresholdGain, omega, transition, method)
%   H_filter = bestLowPassFilter(signal, thresholdGain, omega, transition, method, cutoff)
%
% Inputs:
%   signal        - DTFT signal magnitude (vector)
%   thresholdGain - Threshold gain as a fraction of max magnitude for cutoff (default: 0.1)
%   omega         - Frequency axis values (vector, default: linspace(-pi, pi, length(signal)))
%   transition    - Transition width (default: pi/10, smaller = sharper cutoff)
%   method        - Filter design method: 'ideal', 'tukey', 'gaussian', 'raised-cosine' (default: 'ideal')
%   cutoff        - User-defined cutoff frequency (optional, overrides threshold-based calculation)
%
% Outputs:
%   H_filter      - Optimized low-pass filter in the frequency domain (vector)
%
% Example:
%   signal = abs(some_DTFT_signal);
%   H_filter = bestLowPassFilter(signal, 0.1);
%   plot(linspace(-pi, pi, length(signal)), abs(H_filter)); title('Low-Pass Filter Response');

    % Default parameters
    if nargin < 2 || isempty(thresholdGain)
        thresholdGain = 0.1; % Default threshold gain as 10% of max magnitude
    end
    if nargin < 3 || isempty(omega)
        omega = linspace(-pi, pi, length(signal)); % Default frequency axis
    end
    if nargin < 4 || isempty(transition)
        transition = pi/10; % Default transition width
    end
    if nargin < 5 || isempty(method)
        method = 'ideal'; % Default method
    end
    
    % Determine cutoff frequency
    if nargin < 6 || isempty(cutoff)
        % Dynamically calculate cutoff frequency based on signal magnitude
        threshold = thresholdGain * max(signal); % User-defined or default threshold
        cutoff_idx = find(abs(signal) >= threshold, 1, 'last');
        cutoff = abs(omega(cutoff_idx));
    end

    % Initialize filter response
    H_filter = zeros(size(omega));

    % Create filter based on selected method
    switch lower(method)
        case 'ideal'
            % Ideal low-pass filter (rectangular window)
            H_filter(abs(omega) <= cutoff) = 1;

        case 'tukey'
            % Tukey (tapered cosine) window for smooth transition
            H_filter = 0.5 * (1 + cos(pi * (abs(omega) - cutoff) / transition));
            H_filter(abs(omega) <= cutoff) = 1;
            H_filter(abs(omega) > (cutoff + transition)) = 0;

        case 'gaussian'
            % Gaussian low-pass filter (smoothest roll-off)
            H_filter = exp(-((abs(omega) - cutoff).^2) / (2 * (transition^2)));
            H_filter(abs(omega) <= cutoff) = 1;

        case 'raised-cosine'
            % Raised cosine filter with smooth transition
            H_filter = 0.5 * (1 + cos(pi * (abs(omega) - cutoff) / transition));
            H_filter(abs(omega) <= cutoff) = 1;
            H_filter(abs(omega) > (cutoff + transition)) = 0;

        otherwise
            error('Invalid filter method. Choose from: ideal, tukey, gaussian, raised-cosine');
    end
end
