function EEG_filtered = preprocess_EEG(EEG_data, Fs)
    % preprocess_EEG Preprocesses EEG data with bandpass and notch filters.
    %   EEG_filtered = preprocess_EEG(EEG_data, Fs) filters the input EEG_data
    %   sampled at Fs Hz, using a bandpass filter to retain frequencies between
    %   0.3 and 35 Hz and a notch filter to remove 60 Hz power line noise.

    % Bandpass filter parameters
    %low_cutoff = 0.3; % Low frequency cutoff in Hz
    %high_cutoff = 35; % High frequency cutoff in Hz

    % Design bandpass filter  
    EEG_bandpass_filter = filter_eeg;
    EEG_filtered = filter(EEG_bandpass_filter, EEG_data);

    % Design notch filter to remove 60 Hz noise
    electrical_noise_filter = filter_electrical_noise;
    EEG_filtered = filter(electrical_noise_filter, EEG_filtered);
end
