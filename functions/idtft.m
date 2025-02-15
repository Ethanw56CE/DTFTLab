function timeSignal = idtft(X_dtft)
% IDTFT - Computes the Inverse Discrete-Time Fourier Transform (IDTFT).
%
% Syntax:
%   timeSignal = idtft(X_dtft, omega)
%
% Description:
%   This function computes the Inverse Discrete-Time Fourier Transform (IDTFT) of a discrete-time
%   frequency-domain signal. The IDTFT reconstructs the original time-domain signal from its DTFT representation.
%
% Inputs:
%   X_dtft - DTFT of the signal (complex-valued vector), obtained using the dtft function.
%
% Outputs:
%   timeSignal - Reconstructed time-domain signal (vector).
%
% Example:
%   t = 0:100;
%   x = sin(2*pi*0.1*t); % Generate a sine wave signal
%   [X_dtft, omega] = dtft(x);
%   x_reconstructed = idtft(X_dtft);
%
% Notes:
%   - The function assumes the input frequency-domain signal is evenly spaced in omega.
%   - The reconstruction is performed using an inverse FFT approach.
%   - The accuracy of reconstruction depends on the resolution of omega.
%
% See also: dtft, fft, ifft, fftshift

% Compute the inverse DTFT using IFFT
N = length(X_dtft); % Number of samples

% Compute the inverse transform
timeSignal = ifft(ifftshift(X_dtft)) * N;
end
