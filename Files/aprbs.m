function [y] = aprbs(aMax,f0,f1,t)
% Given a frequency band, amplitude and 
% time, this function generates 
% Amplitude modulated Pseudo 
% Random Binary Sequence (APRBS)
% Input parameters: 
%       aMax: Max. amplitude of APRBS signal
%       f0: Lower band of frequency
%       f1: Upper band of frequency
%       t: time

% Sampling frequency
fs = round(1/(t(2)-t(1)));
% Nyquist frequency
n_frq = 0.5*fs;
% Generate PRBS signal
u = idinput(length(t),'rbs',[f0 f1]/n_frq);
% Find points of shift 
d = diff(u); idx = find(d);
% Number of amplitude levels
N_level = round(0.5*length(idx));
% uniformly distributed amplitudes
level = 1 + (0-1)*rand(2*N_level,1);
% Initialize y
y = zeros(size(u));
% Introduce different amplitudes in 
% the positive and negative regions 
% of the PRBS signal
if (u(1) > 0)
    y(1:idx(1)) = level(1)*u(1:idx(1));
else
    y(1:idx(1)) = -level(1)*u(1:idx(1));
end
for i = 2:length(idx)
    if (d(i-1) < 0)
        y((idx(i-1)+1):idx(i)) = -level(i) * u((idx(i-1)+1):idx(i));
    else
        y((idx(i-1)+1):idx(i)) = level(i) * u((idx(i-1)+1):idx(i));
    end
end
y = aMax*y;