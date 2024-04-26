function Hd = parzenFIR_EOG_blink(Fs)
%BANDPASS_15_8_PARZEN Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 23.2 and Signal Processing Toolbox 23.2.
% Generated on: 31-Mar-2024 01:35:04

% FIR Window Bandpass filter designed using the FIR1 function.

% All frequency values are in Hz.
arguments
    Fs = 50;  % Sampling Frequency
end

N    = 100;      % Order
Fc1  = 1.5;      % First Cutoff Frequency
Fc2  = 8;        % Second Cutoff Frequency
flag = 'scale';  % Sampling Flag
% Create the window vector for the design algorithm.
win = parzenwin(N+1);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, [Fc1, Fc2]/(Fs/2), 'bandpass', win, flag);
Hd = dfilt.dffir(b);

% [EOF]
end
