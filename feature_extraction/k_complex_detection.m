function k_complex_exist = k_complex_detection(signal, Fs)
    %K_COMPLEX_DETECTION A function to detect K-Complexes
    
    
    %Filter the EEG signal as such to only capture the delta waves
    delta_filter = EEG_butterworth_filter;
    eeg_filtered = filter(delta_filter, signal);

    %Make a moving average filter to remove sudden changes in the signal
    windowSize = 40; %samples not seconds!!!
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    eeg_filtered = filter(b, a, eeg_filtered);
    
    %Find the negative and positive peaks in the signal
    
    % Detect positive peaks in the EEG signal
    [positive_peaks, positive_peak_locs] = findpeaks(eeg_filtered, 'MinPeakHeight', 0);
    
    % Detect negative peaks in the EEG signal
    [negative_peaks, negative_peak_locs] = findpeaks(-eeg_filtered, 'MinPeakHeight', 0);
    negative_peaks = -negative_peaks; % Invert back to original amplitude values
    
    %Sort the locations of the peaks
    all_peak_locs = sort([negative_peak_locs, positive_peak_locs]);

    exceed_threshold_locs = [];
    
    %If the first peak is negative and the second peak is positive and if
    %they are above the threshold of 65 microV then save the indexes (locations)
    for i=1:length(all_peak_locs)-1
        if (eeg_filtered(all_peak_locs(i)) > 0) && (eeg_filtered(all_peak_locs(i+1)) < 0)
            if abs(eeg_filtered(all_peak_locs(i+1)) - eeg_filtered(all_peak_locs(i))) >= 65
                exceed_threshold_locs = [exceed_threshold_locs, i];
            end
        end 
    end
    
    k_complex_indice_start = []; 
    
    %Check if the number of values that exceed the threshold is within the
    %K-complex time width and if it is register it as a K-complex
    for i=1:length(exceed_threshold_locs)
        if (exceed_threshold_locs(i) > 1 && (exceed_threshold_locs(i) + 2) <= length(all_peak_locs))
            if abs(all_peak_locs(exceed_threshold_locs(i)-1)/Fs - all_peak_locs(exceed_threshold_locs(i)+2)/Fs) >= 1.2 && abs(all_peak_locs(exceed_threshold_locs(i)-1)/Fs - all_peak_locs(exceed_threshold_locs(i)+2)/Fs) <= 1.5
                k_complex_indice_start = [k_complex_indice_start, all_peak_locs(exceed_threshold_locs(i)-1)];
            end
        end
    end
    
    %Binary check to see if K-Complex exists or not
    k_complex_exist = length(k_complex_indice_start) >= 1;

end

