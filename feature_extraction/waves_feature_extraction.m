function features = waves_feature_extraction(signal, Fs)
    % WAVE_FEATURE_EXTRACTION Extracts frequency-based features from a signal.
    %
    % This function computes the percentage contribution of four major brainwave
    % frequency bands (delta, theta, alpha, and beta) from a given EEG signal.
    %
    % Syntax:
    % features = waves_feature_extraction(signal, Fs)
    %
    % Inputs:
    % signal - A vector representing the EEG signal from which features are to
    %          be extracted. It should be a single-channel signal sampled at
    %          a frequency specified by Fs.
    % Fs     - The sampling frequency of the signal in Hertz. This parameter is
    %          critical for accurate frequency analysis.
    %
    % Outputs:
    % features - A struct containing the extracted features, structured as
    %            follows:
    %            - alpha_features: The percentage of the alpha band (8-13 Hz)
    %                              contribution to the signal.
    %            - beta_features: The percentage of the beta band (13-30 Hz)
    %                             contribution to the signal.
    %            - delta_features: The percentage of the delta band (0.5-4 Hz)
    %                              contribution to the signal.
    %            - theta_features: The percentage of the theta band (4-8 Hz)
    %                              contribution to the signal.
    
    % Initialize a struct to hold the extracted features
    features = struct('alpha_features', [], 'beta_features', [], 'delta_features', [], 'theta_features', []);

    % Define frequency bands of interest
    delta_band = [0.5, 4]; % Delta band range in Hz
    theta_band = [4, 8]; % Theta band range in Hz
    alpha_band = [8, 13]; % Alpha band range in Hz
    beta_band = [13, 30]; % Beta band range in Hz

    % Calculate the percentage of each frequency band in the signal
    features.alpha_features = compute_wave_percentage(signal, Fs, alpha_band);
    features.beta_features = compute_wave_percentage(signal, Fs, beta_band);
    features.delta_features = compute_wave_percentage(signal, Fs, delta_band);
    features.theta_features = compute_wave_percentage(signal, Fs, theta_band);

end
