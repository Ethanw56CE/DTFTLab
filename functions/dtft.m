function [X_dtft, omega] = dtft(timeSignal)
% DTFT - Computes the Discrete-Time Fourier Transform (DTFT) of a given signal.
%
% Syntax:
%   [X_dtft, omega] = dtft(timeSignal)
%
% Description:
%   This function computes the Discrete-Time Fourier Transform (DTFT) of a discrete-time signal.
%   The DTFT provides a frequency-domain representation of the signal and is computed using the FFT.
%
% Inputs:
%   timeSignal - Input discrete-time signal (vector), assumed to be uniformly sampled.
%
% Outputs:
%   X_dtft - DTFT of the input signal (complex-valued vector).
%   omega  - Frequency vector corresponding to the DTFT, ranging from -pi to pi (radians).
%
% Example:
%   t = 0:100;
%   x = sin(2*pi*0.1*t); % Generate a sine wave signal
%   [X_dtft, omega] = dtft(x);
%   figure;
%   magPlot(X_dtft, false, true, omega); % Visualize the magnitude spectrum
%
% Notes:
%   - The function assumes the input signal is finite in length and applies FFT-based computation.
%   - The output DTFT is centered at zero frequency using fftshift.
%   - The resolution of the frequency vector is determined by the length of the input signal.
%
% See also: idtft, fft, fftshift, ifft

% Compute the DTFT using FFT and normalize
X_dtft = fftshift(fft(timeSignal)) / length(timeSignal);

% Generate the corresponding frequency vector
omega = linspace(-pi, pi, length(timeSignal));

end
