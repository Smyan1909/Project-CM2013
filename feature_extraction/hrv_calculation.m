function rmssd = hrv_calculation(ECG_signal, Fs)
    %HRV_CALCULATION Algorithm for hrv using RMSSD method
    
    %Find the positive R-peaks
    [peaks, peak_locs] = findpeaks(ECG_signal, 'MinPeakHeight', 0.6*max(ECG_signal));
    
    % Compute time differences between successive R-peaks
    rr_intervals = diff(peak_locs) / Fs;  % Convert peak locations to time (in seconds)
    
    % Compute squared differences of successive RR intervals
    squared_diff = diff(rr_intervals).^2;
    
    % Compute RMSSD
    rmssd = sqrt(mean(squared_diff));

end

