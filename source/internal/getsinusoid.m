function sinusoidStimuli = getsinusoid(t, freqs, phaseRads, window)
%
% GETSINUSOID  Returns sinusoid stimuli given a time vector,
%   frequencies (Hz), phases (radians), and an optional window function.
%
%   USAGE
%       sinusoidStimuli = GETSINUSOID(t, freq, phaseRad, window) 
%
%   INPUT PARAMETERS
%       t - Time vector (s). 
%       f - List of frequencies (Hz).
%       phaseRad - List of phases (radians).
%       window - Window function. Must be same length as the time
%           vector. (Optional, default is no window.)
%
%   OUTPUT PARAMETERS
%       sinusoidStimuli - Sinusoidal stimuli in a cell array.
%

    if nargin < 4
        window = ones(size(t));  % no window
    end
    
    nSinusoids = length(freqs);
    nPhase = length(phaseRads);
    
    if nSinusoids ~= nPhase
        error('Need to input the same number of frequencies and phases.')
    end
    
    sinusoidStimuli = cell(nSinusoids, 1);
    for ii=1:nSinusoids
        freq = freqs(ii);
        phaseRad = phaseRads(ii);
    
        sinusoidStimulus = sin(2*pi*freq.*t + phaseRad)';
        sinusoidStimulus = sinusoidStimulus .* window;
    
        sinusoidStimuli{ii} = sinusoidStimulus;
    end

end



% Revision history:
%{
2024-04-05: v1.0.0 released.
%}