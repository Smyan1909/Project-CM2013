function temp_features = temporal_feature_extraction(signal, Fs)
    %TEMPORAL_FEATURE_EXTRACTION extracts temporal features from a given
    %signal
    
    
    mean_voltage = mean(signal);
    
    activity = var(signal);
    
    skew = skewness(signal);
    
    kurt = kurtosis(signal);
    
    y_prime = diff(signal)./diff((1:length(signal))/Fs);
    
    y_primeprime = diff(y_prime)./diff((1:length(y_prime))/Fs);
    
    mobility_y = sqrt(var(y_prime)/var(signal));
    
    mobility_y_prime = sqrt(var(y_primeprime)/var(y_prime));
    
    complexity = mobility_y_prime/mobility_y;
    
    mav = mean(abs(signal));
    
    rms = sqrt(mean(signal.^2));
    
    wl = sum(abs(diff(signal)));
    
    sum_abs = sum(abs(signal));

    signal_energy = sum(abs(signal.^2));
    
    mpv = max(abs(signal));

    %temp_features = [mean_voltage, activity, skew, kurt, mobility_y, complexity, mav, rms, wl, sum_abs, signal_energy, 
        %mpv];

    temp_features = struct('Mean_Voltage', mean_voltage, 'Activity', activity, ...
                            'Skewness', skew, 'Kurtosis', kurt, 'Mobility', ...
                            mobility_y, 'Complexity', complexity, ...
                            'Mean_Absolute_Value', mav, 'RMS', rms, ...
                            "WL", wl, "Sum_Abs", sum_abs, "Signal_Energy", ...
                            signal_energy, "Max_Peak_Val", mpv);
end

