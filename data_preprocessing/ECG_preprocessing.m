%This is a test file and NOT the file used for preprocessing the ECG signal

clc;
close all;
clear all;

edfFileName = 'Project Data/R3.edf';
[hdr, record] = edfread(edfFileName);

numberOfEpochs = length(record(3,:)')/(30*hdr.samples(3))

epoch_Number = 6;

signal_number = 4;

Fs = hdr.samples(signal_number);

ecg_signal = -record(signal_number, :);
plot((1:length(ecg_signal))/Fs, ecg_signal);



%%

epoch_ecg_start = (epoch_Number*Fs*30);
epoch_ecg_end = epoch_ecg_start + 30*Fs;
ecg_signal= -record(signal_number, epoch_ecg_start:epoch_ecg_end);
plot((1:length(ecg_signal))/Fs, ecg_signal);
xlim([1 30]);

%% Frequency analysis

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

%% Wavelet Filtering
levels = 6; 
wname = "sym8";

[c, l] = wavedec(ecg_signal, levels, wname);

approx = appcoef(c,l,wname);
[cd1,cd2,cd3, cd4, cd5, cd6] = detcoef(c,l,[1 2 3 4 5 6]);

figure
tiledlayout(7,1)
nexttile
plot(approx)
title("Approximation Coefficients")
nexttile
plot(cd6)
title("Level 6 Detail Coefficients")
nexttile
plot(cd5)
title("Level 5 Detail Coefficients")
nexttile
plot(cd4)
title("Level 4 Detail Coefficients")
nexttile
plot(cd3)
title("Level 3 Detail Coefficients")
nexttile
plot(cd2)
title("Level 2 Detail Coefficients")
nexttile
plot(cd1)
title("Level 1 Detail Coefficients")


max_level_for_denoise = wmaxlev(length(ecg_signal), wname);
ecg_denoised = wdenoise(ecg_signal, max_level_for_denoise, Wavelet=wname, DenoisingMethod="Minimax");

figure
tiledlayout(2,1)
nexttile
plot((1:length(ecg_signal))/Fs, ecg_signal)
title("Unfiltered ECG signal")
xlim([1 30]);
nexttile
plot((1:length(ecg_signal))/Fs, ecg_denoised)
title("Filtered ECG signal")
xlim([1 30]);

figure
tiledlayout(2,1)
nexttile
plot(f, pxx)
title("Unfiltered power spectrum")
xlim([0 Fs/2]);
nexttile
[pxx2,f2] = pwelch(ecg_signal,[],[],[],Fs);
plot(f2, pxx2)
title("Filtered power spectrum")
xlim([0 Fs/2])
%% Calculate HRV
[peaks, peak_locs] = findpeaks(ecg_denoised, 'MinPeakHeight', 0.6*max(ecg_denoised));
figure
plot((1:length(ecg_signal))/Fs, ecg_denoised);
xlim([1 30]);
hold on
plot(peak_locs/Fs, peaks, 'ro', 'MarkerSize',10);
xlabel('Time (s)');
ylabel('Amplitude');
legend('ECG Signal', 'Peaks');

% Compute time differences between successive R-peaks
rr_intervals = diff(peak_locs) / Fs;  % Convert peak locations to time (in seconds)

% Compute squared differences of successive RR intervals
squared_diff = diff(rr_intervals).^2;

% Compute RMSSD
rmssd = sqrt(mean(squared_diff));

% Display RMSSD
disp(['RMSSD: ', num2str(rmssd), ' seconds']);