function plotReIm(H, subplotMode, omega)
% PLOTREIM - Plots the real and imaginary parts of a Fourier Transform in 3D.
%
% Syntax:
%   plotReIm(H)                      % Default: 3D plot of real vs. imaginary components
%   plotReIm(H, true)                % Plot in subplot mode (no new figure)
%   plotReIm(H, true, omega)         % Specify frequency axis omega
%
% Description:
%   This function visualizes the complex-valued Fourier Transform by plotting
%   its real and imaginary components as a 3D plot over the frequency range.
%
% Inputs:
%   H           - Fourier Transform values (complex vector)
%   subplotMode - Boolean flag (true = do NOT create a new figure, false = create new figure) (default: false)
%   omega       - Frequency axis values (default: linspace(-pi, pi, length(H)))
%
% Outputs:
%   A 3D plot displaying the real and imaginary parts of H(e^{j\omega}).
%
% Example:
%   omega = linspace(-pi, pi, 1000);
%   H = exp(-1j * omega);
%   plotReIm(H);
%   plotReIm(H, true, omega);
%
% Notes:
%   - The function automatically adjusts the plot based on the input signal.
%   - If subplotMode is enabled, the plot is added to an existing figure instead of creating a new one.
%   - Uses LaTeX formatting for axis labels and titles.
%
% See also: magPlot

    if nargin < 2 || isempty(subplotMode)
        subplotMode = false;
    end
    
    if nargin < 3 || isempty(omega)
        omega = linspace(-pi, pi, length(H));
    end
    
    if ~subplotMode
        figure;
    end
    
    % Get the variable name for labeling
    name = inputname(1);
    if isempty(name)
        name = 'H';
    end
    formattedName = strrep(name, '_', '\_'); % Replace "_" with "\_"
    
    % Plot real and imaginary components in 3D
    plot3(omega, real(H), imag(H), 'LineWidth', 1.5);
    xlabel('\omega'); 
    ylabel(['Real(', formattedName, '(\omega))']); 
    zlabel(['Imag(', formattedName, '(\omega))']);
    title(['Complex-Valued Frequency Response of ', formattedName, '(e^{j\omega})']);
    grid on;
end