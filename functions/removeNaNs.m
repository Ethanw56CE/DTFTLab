function cleanSignal = removeNaNs(signal, omega, method)
% REMOVENANS - Interpolates or pads NaN values in a signal.
%
% Syntax:
%   cleanSignal = removeNaNs(signal, omega)
%   cleanSignal = removeNaNs(signal, omega, method)
%
% Description:
%   This function replaces NaN values in an input signal using interpolation or nearest-neighbor padding.
%   If interpolation fails or is not sufficient, remaining NaNs are replaced with nearest available values.
%
% Inputs:
%   signal - Input signal (vector) containing NaN values.
%   omega  - Corresponding frequency values (vector).
%   method - Interpolation method for filling NaNs ('linear', 'spline', 'nearest', 'pchip').
%            Default: 'linear'.
%
% Outputs:
%   cleanSignal - Signal with NaN values replaced.
%
% Example:
%   omega = linspace(-pi, pi, 100);
%   signal = sin(omega);
%   signal(30:40) = NaN; % Introduce NaNs
%   cleanSignal = removeNaNs(signal, omega=omega, method='spline');
%   plot(omega, cleanSignal);
%   title('Signal with NaNs Replaced');
%
% Notes:
%   - If all values in the signal are NaN, an error is thrown.
%   - The function performs iterative interpolation to ensure NaNs are removed.
%   - Any remaining NaNs after interpolation are filled using nearest-neighbor padding.
%
% See also: interp1, fillmissing

    arguments
        signal (1,:) double
        omega (1,:) double = linspace(-pi, pi, length(H))
        method char {mustBeMember(method, {'linear','nearest','next', 'previous', 'spline', 'pchip', 'cubic', 'v5cubic', 'makima'})} = 'linear'
    end

    
    % Identify NaN values
    nanMask = isnan(signal);
    
    % Ensure there is at least one non-NaN value to interpolate from
    if all(nanMask)
        error('Signal contains only NaN values. Cannot interpolate.');
    end
    
    % Replace NaNs with interpolated values
    cleanSignal = signal;
    while any(nanMask)
        % Use only valid values for interpolation
        validIdx = ~nanMask;
        cleanSignal(nanMask) = interp1(omega(validIdx), cleanSignal(validIdx), omega(nanMask), method, 'extrap');
        nanMask = isnan(cleanSignal);
    end
    
    % As a final step, fill any remaining NaNs with nearest neighbor
    cleanSignal = fillmissing(cleanSignal, 'nearest');
end
