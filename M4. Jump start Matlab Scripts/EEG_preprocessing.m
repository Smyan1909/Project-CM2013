
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
Hd = EEG_butterworth_filter;
eeg_filtered = filter(Hd, eeg_signal);
figure
plot((1:length(eeg_signal))/Fs, eeg_filtered);
xlim([1 30]);

%For moving average filter

windowSize = 40;
b = (1/windowSize)*ones(1,windowSize);
a = 1;
eeg_filtered = filter(b, a, eeg_filtered);
figure
plot((1:length(eeg_signal))/Fs, eeg_filtered);
xlim([1 30]);

%% Find the peaks
% Detect positive peaks in the EEG signal
[positive_peaks, positive_peak_locs] = findpeaks(eeg_filtered, 'MinPeakHeight', 0);

% Detect negative peaks in the EEG signal
[negative_peaks, negative_peak_locs] = findpeaks(-eeg_filtered, 'MinPeakHeight', 0);
negative_peaks = -negative_peaks; % Invert back to original amplitude values

% Plot the signal with detected peaks
figure;
plot((1:length(eeg_filtered))/Fs, eeg_filtered);
hold on;
plot(positive_peak_locs/Fs, positive_peaks, 'ro', 'MarkerSize', 10); % Plot positive peaks
plot(negative_peak_locs/Fs, negative_peaks, 'bx', 'MarkerSize', 10); % Plot negative peaks
title('Filtered EEG Signal with Detected Peaks');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([1 30]);
legend('EEG Signal', 'Positive Peaks', 'Negative Peaks');

all_peak_locs = sort([negative_peak_locs, positive_peak_locs]);

exceed_threshold_locs = [];

for i=1:length(all_peak_locs)-1
    if eeg_filtered(all_peak_locs(i)) > 0 && eeg_filtered(all_peak_locs(i+1)) < 0
        if abs(eeg_filtered(all_peak_locs(i+1)) - eeg_filtered(all_peak_locs(i))) >= 65
            exceed_threshold_locs = [exceed_threshold_locs, i]
        end
    end 
end

k_complex_indice_start = []; 

for i=1:length(exceed_threshold_locs)
    
    if abs(all_peak_locs(exceed_threshold_locs(i)-1)/Fs - all_peak_locs(exceed_threshold_locs(i)+2)/Fs) >= 1.2 && abs(all_peak_locs(exceed_threshold_locs(i)-1)/Fs - all_peak_locs(exceed_threshold_locs(i)+2)/Fs) <= 1.5
        k_complex_indice_start = [k_complex_indice_start, all_peak_locs(exceed_threshold_locs(i)-1)]
    end

end
