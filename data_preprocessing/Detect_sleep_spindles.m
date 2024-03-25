edfFileName = 'Project Data/R4.edf';
[hdr, record] = edfread(edfFileName);

numberOfEpochs = length(record(3,:)')/(30*hdr.samples(3))

epoch_Number = 124; %K-complex exists at epoch_Number 195 and at 126 and at 613 and at 83 and at 747

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
figure 

%% Spindle detection using RMS method
Hd = spindle_filter;
eeg_filtered = filter(Hd, eeg_preprocess);
plot((1:length(eeg_filtered))/Fs, eeg_filtered);
xlim([1 30]);

window_length = 0.5;
samplesInWindow = round(Fs * window_length);
rmsSignal = sqrt(movmean(eeg_filtered.^2, samplesInWindow));
figure
plot((1:length(rmsSignal))/Fs, rmsSignal);
xlim([1 30])

lambda_d = prctile(rmsSignal, 95);

potential_spindle = rmsSignal > lambda_d;

counter = 0;
spindle_exists = 0;
for i=1:length(potential_spindle)
    if potential_spindle(i)==1
        counter = counter + 1;
        if counter/Fs >= 0.5 && counter/Fs <= 2
            spindle_exists = 1;
        end
    else
        counter = 0;
        
    end
end

spindle_exists