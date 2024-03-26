function features = waves_feature_extraction(edf_file_path, epoch, signal_type)
    % waves_feature_extraction Extracts frequency band features from physiological signals.
    %
    % This function analyzes signals from an EDF file, such as EEG, EOG, and EMG, to extract
    % percentage-based features within specific frequency bands for a given epoch. It supports
    % the extraction of delta, theta, alpha, and beta wave features.
    %
    % Inputs:
    %   edf_file_path - Path to the EDF file as a string.
    %   epoch - Integer specifying the epoch number to process.
    %           If not provided, defaults to the second epoch.
    %   signal_type - Type of the signal to analyze. Acceptable values include
    %                 "EEG", "EOGL", "EOGR", and "EMG".
    %
    % Outputs:
    %   features - Struct containing extracted features for the specified signal type,
    %              including percentages of delta, theta, alpha, and beta waves.
    %
    % The function reads specified epoch data from the given EDF file and calculates
    % the power percentage of each frequency band using a dedicated wave percentage
    % calculation function.

    % Default to the second epoch if not specified
    if nargin < 2
        epoch = 2;
    end
    
    % Read data from the EDF file
    [hdr, record] = edfread(edf_file_path);

    % Initialize a struct to hold the extracted features
    features = struct('alpha_features', [], 'beta_features', [], 'delta_features', [], 'theta_features', []);

    % Locate the index of the specified signal type in the EDF header
    signalIndex = find(strcmp(hdr.label, signal_type));

    % Retrieve the sampling rate for the specified signal
    Fs = hdr.samples(signalIndex);
    
    % Define frequency bands of interest
    delta_band = [0.5, 4]; % Delta band range in Hz
    theta_band = [4, 8]; % Theta band range in Hz
    alpha_band = [8, 13]; % Alpha band range in Hz
    beta_band = [13, 30]; % Beta band range in Hz

    % Calculate the start and end indices of the specified epoch
    epoch_duration_in_seconds = 30; % Define the duration of each epoch
    epochStart = (epoch - 1) * Fs * epoch_duration_in_seconds + 1;
    epochEnd = epoch * Fs * epoch_duration_in_seconds;

    % Extract the signal data for the specified epoch
    data = record(signalIndex, epochStart:epochEnd);

    % Calculate the percentage of each frequency band in the signal
    features.alpha_features = compute_wave_percentage(data, Fs, alpha_band);
    features.beta_features = compute_wave_percentage(data, Fs, beta_band);
    features.delta_features = compute_wave_percentage(data, Fs, delta_band);
    features.theta_features = compute_wave_percentage(data, Fs, theta_band);

end
