function [f, P1] = singlesidedfftmagnitudespectrums(y, N, fs)
% SINGLESIDEDFFTMAGNITUDESPECTRUMS  computes the one-sided FFT magnitude
%   spectrums of given time-domain signals.
%
%   USAGE
%       [f, P1] = SINGLESIDEDFFTMAGNITUDESPECTRUMS(y, N, fs)
%
%   INPUT PARAMETERS
%       y - Time-domain signals. Size of input should be (nTimesteps,
%           nSignals).
%       N - Length of signals in y (nTimesteps).
%       fs - Sampling rate (Hz).
%
%   OUTPUT PARAMETERS
%       f - Frequencies (Hz).
%       P1 - One sided FFT magnitude spectrums for each signal in y. Size
%           of output will be (ceil(nTimesteps)/2, nSignals).
%

    P2 = fft(y, N, 1)/N;
    f = (0:N-1)*fs/N;

    if mod(N, 2) == 0
        P1 = P2(1:(N/2)+1, :);
        f = f(1:(N/2)+1);
        P1(2:end-1, :) = 2*P1(2:end-1, :);
    else
        P1 = P2(1:ceil(N/2), :);
        f = f(1:ceil(N/2));
        P1(2:end, :) = 2*P1(2:end, :);
    end

    P1 = abs(P1);

end



% Revision history:
%{
2024-04-05: v1.0.0 released.
%}