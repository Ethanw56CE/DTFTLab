function newOmega = freq_shift_periodic(omega, d)
% FREQ_SHIFT_PERIODIC - Shifts a frequency vector while maintaining periodicity.
%
% Syntax:
%   newOmega = freq_shift_periodic(omega, d)
%
% Description:
%   This function shifts the given frequency vector `omega` by an offset `d`
%   while ensuring periodicity within the range [-pi, pi]. This is useful
%   when modifying frequency-domain functions that require phase shifts.
%
% Inputs:
%   omega - Input frequency vector (radians)
%   d     - Frequency shift amount (radians)
%
% Outputs:
%   newOmega - Shifted frequency vector, wrapped to the range [-pi, pi]
%
% Example:
%   omega = linspace(-pi, pi, 100);
%   d = pi/4;
%   newOmega = freq_shift_periodic(omega, d);
%   plot(omega, newOmega);
%   title('Shifted Frequency Vector');
%   xlabel('Original Omega');
%   ylabel('Shifted Omega');
%
% Notes:
%   - The function applies the modulo operation to maintain periodicity.
%   - Useful for processing functions of the form H(e^(j(w-d))).
%
% See also: mod, fftshift

    arguments
        omega (1,:) double
        d (1, 1) double
    end

% Apply frequency shift and maintain periodicity in [-pi, pi]
newOmega = mod(omega - d, 2*pi) - pi;

end
