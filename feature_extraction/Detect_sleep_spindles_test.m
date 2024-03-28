edfFileName = 'Project Data/R4.edf';
[hdr, record] = edfread(edfFileName);

numberOfEpochs = length(record(3,:)')/(30*hdr.samples(3))

epoch_Number = 195; %K-complex exists at epoch_Number 195 and at 126 and at 613 and at 83 and at 747

signal_number = 8;

Fs = hdr.samples(signal_number);

epoch_eeg_start = (epoch_Number*Fs*30);
epoch_eeg_end = epoch_eeg_start + 30*Fs;
eeg_signal= record(signal_number, epoch_eeg_start:epoch_eeg_end);
figure
plot((1:length(eeg_signal))/Fs, eeg_signal);
xlim([1 30]);
%% Filter the EEG signal
Hd2 = filter_eeg;
eeg_preprocess = filter(Hd2, eeg_signal);

%% Spindle detection using RMS method
Hd = spindle_filter;
Hd_alpha = alpha_band_filter;
eeg_filtered = filter(Hd, eeg_preprocess);
eeg_alpha = filter(Hd_alpha, eeg_preprocess);
figure 
plot((1:length(eeg_filtered))/Fs, eeg_filtered);
xlim([1 30]);

window_length = 1;
samplesInWindow = round(Fs * window_length);
rmsSignal = sqrt(movmean(eeg_filtered.^2, samplesInWindow));
rmsAlpha = sqrt(movmean(eeg_alpha.^2, samplesInWindow));
figure
plot((1:length(rmsSignal))/Fs, rmsSignal);
xlim([1 30])

lambda_d = prctile(rmsSignal, 95);

alpha_artifact = rmsAlpha./rmsSignal < 1.2;

potential_spindle = (rmsSignal > lambda_d).*alpha_artifact;

counter = 0;
spindle_exists = 0;
spindles = [];
start_idx = 0;
for i=1:length(potential_spindle)
    if potential_spindle(i)==1
        if start_idx == 0
            start_idx = i;
        end
        counter = counter + 1;
        if counter/Fs >= 0.5 && counter/Fs <= 2
            spindle_exists = 1;
            end_idx = i-1;
            spindles = [spindles; [start_idx, end_idx]];
        end
    else
        counter = 0;
        start_idx = 0;
        
    end
end

spindle_exists

figure
plot((1:length(eeg_preprocess))/Fs, eeg_preprocess);
hold on; % Hold on to the current plot

% Loop through detected spindles and overlay them
for i = 1:size(spindles, 1)
    % Extract the start and end indices of the spindle
    start_idx = spindles(i, 1);
    end_idx = spindles(i, 2);
    
    % Overlay spindle on the plot
    plot((start_idx:end_idx)/Fs, eeg_preprocess(start_idx:end_idx), 'r', 'LineWidth', 2);
end

hold off; % Release the plot hold
xlim([1 30]); % Adjust the x-axis limits to your preference
xlabel('Time (seconds)');
ylabel('EEG signal amplitude');
title('EEG Signal with Detected Sleep Spindles');
legend('EEG Signal', 'Detected Spindles');