function spindle_exists = sleep_spindle_detection(signal, Fs)
    %SLEEP_SPINDLE_DETECTION Summary of this function goes here
    
    %Apply butterworth filter to isolate the sleep spindle frequency band
    %[11 16]Hz
    s_band_filter = spindle_filter;

    %Apply butterworth filter to isolate the alpha frequency band
    %[8 12]Hz 
    a_band_filter = alpha_band_filter;

    signal_spindle = filter(s_band_filter, signal);
    signal_alpha = filter(a_band_filter, signal);
    
    %Calculate moving RMS on the signals 
    window_length = 1; %This is in seconds and NOT in samples
    samplesInWindow = round(Fs * window_length);
    rmsSignal = sqrt(movmean(signal_spindle.^2, samplesInWindow));
    rmsAlpha = sqrt(movmean(signal_alpha.^2, samplesInWindow));
    
    %The threshold for detection is set as the 95th percentile of the
    %detector function rmsSignal
    lambda_d = prctile(rmsSignal, 95);
    
    %Remove potential false detections from the alpha waves present
    alpha_artifact = rmsAlpha./rmsSignal < 1.2;
    
    %Detect locations for potential spindle
    potential_spindle = (rmsSignal > lambda_d).*alpha_artifact;
    
    %If time window of spindle is correct then register a detected sleep
    %spindle
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

end

