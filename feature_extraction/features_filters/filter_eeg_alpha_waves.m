function Hd = filter_eeg_alpha_waves
%FILTER_EEG_ALPHA_WAVES Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 23.2 and Signal Processing Toolbox 23.2.
% Generated on: 26-Mar-2024 17:11:22

% Butterworth Bandpass filter designed using FDESIGN.BANDPASS.

% All frequency values are in Hz.
Fs = 125;  % Sampling Frequency

N   = 2;    % Order
Fc1 = 0.5;  % First Cutoff Frequency
Fc2 = 30;   % Second Cutoff Frequency

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandpass('N,F3dB1,F3dB2', N, Fc1, Fc2, Fs);
Hd = design(h, 'butter');

% [EOF]