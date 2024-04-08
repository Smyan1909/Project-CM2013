function wave_stats = compute_wave_percentage(signal, Fs, freq_range)
    % compute_wave_percentage Analyzes the presence and proportion of specific frequency waves in a signal.
    % 
    % Usage:
    %   wave_stats = compute_wave_percentage(signal, Fs, freq_range)
    %
    % Inputs:
    %   signal - Array of signal values to analyze.
    %   Fs - Sampling frequency of the signal, in Hz.
    %   freq_range - Two-element array defining the frequency range of interest, in Hz (e.g., [8, 13] for alpha waves).
    %
    % Outputs:
    %   wave_stats - A struct containing:
    %       wave_power_percentage - The percentage of total power within the specified frequency range.
    %       wave_power_percentage_bis - Alternative calculation of wave power percentage, ignoring amplitude threshold.
    %       wave_proportion - The percentage of time segments where the specified wave is dominant.
    %
    % This function calculates the proportion of a specified wave type (e.g., alpha, beta) in a given signal.
    % It first filters the signal to isolate the frequency range of interest, then uses a sliding window
    % approach combined with AR model power spectrum estimation to analyze the signal in segments.

    % Initialize output structure
    wave_stats = struct('wave_power_percentage', [], ...
                        'wave_power_percentage_bis', [], ...
                        'wave_proportion', []);
    
    % Filter the signal to isolate the frequency range of interest
    EEG_bandpass_filter = filter_eeg_alpha_waves; 
    filtered_signal = filter(EEG_bandpass_filter, signal);
    
    % Set up the sliding window analysis parameters
    window_size = Fs; % Defines a 1-second window for analysis
    overlap = floor(window_size / 2); % 50% overlap between consecutive windows
    nfft = 2^nextpow2(window_size); % FFT length, optimized for speed
    
    % Define amplitude threshold for significant signal consideration
    amplitude_threshold = 75e-06; % Threshold in volts
    
    % Initialize variables for computing wave statistics
    total_power = 0; % Total power across all windows
    wave_power = 0; % Power within the specified wave's frequency range
    wave_power_bis = 0; % Alternative wave power calculation
    
    % Count of windows where the specified wave is dominant
    wave_count = 0;
    total_segments = floor((length(signal) - window_size) / overlap) + 1;

    % Analyze the signal using a sliding window approach
    for start_idx = 1:overlap:length(signal)-window_size
        windowed_signal = filtered_signal(start_idx:start_idx+window_size-1);
        
        % Estimate power spectrum using the AR model
        [pxx, f] = pyulear(windowed_signal, 15, nfft, Fs);
    
        % Identify indices within the frequency range of interest
        wave_band_idxs = f >= freq_range(1) & f <= freq_range(2);
        wave_power_bis = wave_power_bis + sum(pxx(wave_band_idxs));
    
        % Apply amplitude threshold to consider significant signal segments
        if max(abs(windowed_signal)) > amplitude_threshold 
            total_power = total_power + sum(pxx); 
            [~, max_power_idx] = max(pxx); % Find the frequency with maximum power
            max_power_freq = f(max_power_idx); 
            
            % Check if the max power frequency falls within the specified range
            if max_power_freq >= freq_range(1) && max_power_freq <= freq_range(2)
                wave_count = wave_count + 1; % Increment wave-specific count
                wave_power = wave_power + sum(pxx(wave_band_idxs)); % Update wave-specific power
            end
        end
    end
    
    % Finalize wave statistics calculation
    if total_power > 0
        wave_stats.wave_power_percentage = (wave_power / total_power) * 100;
        wave_stats.wave_power_percentage_bis = (wave_power_bis / total_power) * 100;
        wave_stats.wave_proportion = (wave_count / total_segments) * 100;
    else
        % Handle case with negligible or no significant power
        wave_stats.wave_power_percentage = 0;
        wave_stats.wave_power_percentage_bis = 0;
        wave_stats.wave_proportion = 0;
    end
end
