clc;
close all;
clear all;

edfFileName = 'Project Data/R3.edf';
[hdr, record] = edfread(edfFileName);

numberOfEpochs = length(record(3,:)')/(30*hdr.samples(3))

epoch_Number = 1;

signal_number = 4;

Fs = hdr.samples(signal_number);

ecg_signal = -record(signal_number, :);
plot((1:length(ecg_signal))/Fs, ecg_signal);

%%
window = hamming(floor(length(ecg_signal)/8));
noverlap = floor(length(window)/2);
nfft = [];
%[pxx,f] = pwelch(ecg_signal,window,noverlap,nfft,Fs);
[pxx,f] = pwelch(ecg_signal,[],[],[],Fs);

figure;
plot(f, (pxx))
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (Mag/Hz)')
title('Power Spectral Density using Welch''s Method')
grid on

%%

epoch_ecg_start = (epoch_Number*Fs*30);
epoch_ecg_end = epoch_ecg_start + 30*Fs;
ecg_signal= -record(4, epoch_ecg_start:epoch_ecg_end);
plot((1:length(ecg_signal))/Fs, ecg_signal);
xlim([1 30]);