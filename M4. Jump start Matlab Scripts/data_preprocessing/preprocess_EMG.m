function EMG_filtered = preprocess_EMG(EMG_data, Fs)
    % preprocess_EMG Preprocesses EMG data with bandpass and notch filters.
    %   EMG_filtered = preprocess_EMG(EMG_data, Fs) filters the input EMG_data
    %   sampled at Fs Hz, using a bandpass filter to retain frequencies between
    %   10 and 50 Hz and a notch filter to remove 60 Hz power line noise.

    % Bandpass filter parameters
    %low_cutoff = 10; % Low frequency cutoff in Hz
    %high_cutoff = 50; % High frequency cutoff in Hz

    % Design bandpass filter
    EMG_bandpass_filter = filter_emg;
    EMG_filtered = filter(EMG_bandpass_filter, EMG_data);

    % Design notch filter to remove 60 Hz noise
    electrical_noise_filter = filter_electrical_noise;
    EMG_filtered = filter(electrical_noise_filter, EMG_filtered);
end
