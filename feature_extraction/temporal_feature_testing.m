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
%% Preprocess the signal
Hd2 = filter_eeg;
eeg_preprocess = filter(Hd2, eeg_signal);
%% Extract the temporal features from the signal

mean_voltage = mean(eeg_preprocess)

hjorth_activity = var(eeg_preprocess)

skew = skewness(eeg_preprocess)

kurt = kurtosis(eeg_preprocess)

y_prime = diff(eeg_preprocess)./diff((1:length(eeg_preprocess))/Fs);

y_primeprime = diff(y_prime)./diff((1:length(y_prime))/Fs);

mobility_y = sqrt(var(y_prime)/var(eeg_preprocess))

mobility_y_prime = sqrt(var(y_primeprime)/var(y_prime));

complexity = mobility_y_prime/mobility_y

mav = mean(abs(eeg_preprocess))

rms = sqrt(mean(eeg_preprocess.^2))

wl = sum(abs(diff(eeg_preprocess)))

sum_abs = sum(abs(eeg_preprocess))