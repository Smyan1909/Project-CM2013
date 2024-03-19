function data_preprocessing(edf_file_path, epoch)

%DATA_PREPROCESSING Preprocesses EEG and EMG data from an EDF file.
    %
    %   data_preprocessing(edf_file_path, epoch) reads an EDF file located at
    %   edf_file_path, extracts EEG and EMG data for a specified epoch, applies
    %   preprocessing, and generates plots before and after preprocessing.
    %
    %   The preprocessing includes bandpass filtering to retain frequencies within
    %   a specified range and applying a notch filter to remove 60 Hz power line
    %   noise.
    %
    %   The function generates four plots: raw and preprocessed EEG data,
    %   and raw and preprocessed EMG data.
    %
    %   Inputs:
    %       edf_file_path - String, path to the EDF file.
    %       epoch - Optional, the epoch of the data to preprocess. If not
    %               provided, the function defaults to the second epoch.
    %
    %   Example usage:
    %       data_preprocessing('path_to_file.edf', 2); % Preprocesses the 2nd epoch
    %
    %   See also EDFREAD, PREPROCESS_EEG, PREPROCESS_EMG

    
    % Check if epoch is provided, otherwise default to the second epoch
    if nargin < 2
        epoch = 2;
    end
    
    % Read EDF file
    [hdr, record] = edfread(edf_file_path);

    % Get the EMG data
    emgIndex = find(strcmp(hdr.label, 'EMG'));
    Fs_EMG = hdr.samples(emgIndex); % Sampling rate for EMG
    epochStart = (epoch*Fs_EMG*30);
    epochEnd = epochStart + 30*Fs_EMG;
    emg_data = record(emgIndex,epochStart:epochEnd);

    
    % Get the EEG data
    eegIndex = find(strcmp(hdr.label, 'EEG'));
    Fs_EEG = hdr.samples(eegIndex); % Sampling rate for EEG
    epochStart = (epoch*Fs_EEG*30);
    epochEnd = epochStart + 30*Fs_EEG;
    eeg_data = record(eegIndex,epochStart:epochEnd);

    
    % Preprocess the signals
    EEG_filtered = preprocess_EEG(eeg_data, Fs_EEG);
    EMG_filtered = preprocess_EMG(emg_data, Fs_EMG);
    
    % Generate plots
    % Plot EEG before preprocessing
    figure;
    subplot(2, 2, 1);
    plot(eeg_data);
    title('EEG Before Preprocessing');
    xlabel('Samples');
    ylabel('Amplitude');
    
    % Plot EEG after preprocessing
    subplot(2, 2, 2);
    plot(EEG_filtered);
    title('EEG After Preprocessing');
    xlabel('Samples');
    ylabel('Amplitude');
    
    % Plot EMG before preprocessing
    subplot(2, 2, 3);
    plot(emg_data);
    title('EMG Before Preprocessing');
    xlabel('Samples');
    ylabel('Amplitude');
    
    % Plot EMG after preprocessing
    subplot(2, 2, 4);
    plot(EMG_filtered);
    title('EMG After Preprocessing');
    xlabel('Samples');
    ylabel('Amplitude');
end

