function binaryFeatures = binary_feature_extraction(signal, Fs)
%BINARY_FEATURE_EXTRACTION function used to extract binary features such as
%K-complex and sleep spindle from EEG (and potentially EOG) signals

    k_complex_exist = k_complex_detection(signal, Fs);

    sleep_spindle_exists = sleep_spindle_detection(signal, Fs);

    binaryFeatures = struct('K_Complex', k_complex_exist, 'Sleep_Spindle', sleep_spindle_exists);
    
end

