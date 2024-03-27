function ECG_filtered = preprocess_ECG(ECG_data, Fs)
    
    %Function to preprocess ECG data with with a wavelet filter
    %This funcition uses the wmaxlev function to decide how many levels
    %the wavelet filter should remove
    
    %Name of the wavelet
    wname = "sym8";
    
    
    %Max wavelet decomposition level to be removed
    max_level_for_denoise = wmaxlev(length(ECG_data), wname);

    %Filter the ECG signal with the wavelet filter using the minimax method
    ECG_filtered = wdenoise(ECG_data, max_level_for_denoise, Wavelet=wname, DenoisingMethod="Minimax");


end

