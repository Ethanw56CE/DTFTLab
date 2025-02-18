function X_dtft = c2dSample(X_ct, omega_ct, Ts, method)
% C2DSAMPLE - Converts a Continuous-Time Fourier Transform (CTFT) to a Discrete-Time Fourier Transform (DTFT).
%
% Syntax:
%   X_dtft = c2dSample(X_ct, omega_ct, Ts)
%   X_dtft = c2dSample(X_ct, omega_ct, Ts, method)
%
% Description:
%   This function converts a Continuous-Time Fourier Transform (CTFT) spectrum into its Discrete-Time
%   Fourier Transform (DTFT) representation using the relationship:
%
%       X(e^jw) = (1/Ts) * Xc(j * (w/Ts))
%
%   The function samples the CTFT spectrum at discrete frequency intervals and scales the magnitude
%   accordingly. Various interpolation methods are supported to improve accuracy.
%
% Inputs:
%   X_ct     - Continuous-time Fourier Transform (CTFT) values (vector)
%   omega_ct - Continuous frequency vector in radians per second (vector)
%   Ts       - Sampling period in seconds (scalar, must be positive)
%   method   - Interpolation method for resampling (default: 'linear')
%              Supported methods: 'linear', 'nearest', 'spline', 'pchip'
%
% Outputs:
%   X_dtft   - DTFT representation obtained by sampling the CTFT and applying the scaling factor (vector)
%
% Example:
%   omega_ct = linspace(-10*pi, 10*pi, 1000); % Continuous frequency axis
%   X_ct = sinc(omega_ct / pi); % Example CTFT spectrum
%   Ts = 0.1; % Sampling period
%   X_dtft = c2dSample(X_ct, omega_ct, Ts);
%   plot(linspace(-pi, pi, length(X_dtft)), abs(X_dtft)); title('DTFT Magnitude Spectrum');
%
% Notes:
%   - The function assumes that the input CTFT is a continuous spectrum.
%   - Sampling in the frequency domain corresponds to periodic repetition in the DTFT domain.
%   - The magnitude of the DTFT is scaled by 1/Ts, as per the conversion formula.
%   - A smaller Ts results in a wider periodic extension in the DTFT domain.
%   - The function ensures that interpolation is performed to match the target discrete frequency range.
%
% See also: dtft, idtft, interp1

    arguments
        X_ct (1,:) double
        omega_ct (1,:) double
        Ts (1,1) double
        method char {mustBeMember(method, {'linear','nearest','next', 'previous', 'spline', 'pchip', 'cubic', 'v5cubic', 'makima'})} = 'linear'
    end

    % Define digital frequency range [-pi, pi]
    N = numel(omega_ct);  % Match resolution of input
    w = linspace(-pi, pi, N);  % Digital frequency vector in rad/sample

    % Map digital frequency to continuous frequency: Omega = w / Ts
    omega_target = w / Ts;
    
    % Interpolate X_ct at required omega_target points using the specified method
    X_dtft = interp1(omega_ct, X_ct, omega_target, method, 0);
    
    % Scale by 1/Ts as per DTFT relationship
    X_dtft = (1/Ts) * X_dtft;

end
