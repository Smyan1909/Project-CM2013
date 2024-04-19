%% Load in and register all data patient wise

clear all;
clc;
numPatients = 10;
Patient_Data = struct();
for i=5:numPatients
    edfFileName = sprintf("Project Data/R%d.edf", i);
    xmlFileName = sprintf("Project Data/R%d.xml", i);

    [hdr, record] = edfread(edfFileName);
    [events, stages, epochLength,annotation] = readXML(xmlFileName);

    % Initialization of each patient's data
    Patient_Data = struct();
    
    numberOfEpochs = length(record(3,:)')/(30*hdr.samples(3));

    EEG_sec = struct('signal', record(3, :), 'Fs', hdr.samples(3));
    EEG = struct('signal', record(8, :), 'Fs', hdr.samples(8));
    ECG = struct('signal', record(4, :), 'Fs', hdr.samples(4));
    EMG = struct('signal', record(5, :), 'Fs', hdr.samples(5));
    EOGL = struct('signal', record(6, :), 'Fs', hdr.samples(6));
    EOGR = struct('signal', record(7, :), 'Fs', hdr.samples(7));
    
    patient_Number = sprintf("R%d", i);

    Patient_Data.(patient_Number) = struct('numberOfEpochs', numberOfEpochs, 'sleep_stages', stages, ...
                        'EEG', EEG, 'EEG_sec', EEG_sec, 'ECG', ECG , ...
                        'EMG', EMG, 'EOGL', EOGL, 'EOGR', EOGR);
    
    % Save each patient's data in a separate file
    save(sprintf('Patient_Data_%s.mat', patient_Number), 'Patient_Data');
end

%% Load Patient Data, apply preprocessing and extract some features (Currently only for ECG, EEG and EMG)

for i=5:numPatients
    patient_Number = sprintf("R%d", i);
    load(sprintf('Patient_Data_%s.mat', patient_Number));

    numberOfEpochs = Patient_Data.(patient_Number).numberOfEpochs;
    
    EEG_signal = Patient_Data.(patient_Number).EEG.signal;
    EEG_Fs = Patient_Data.(patient_Number).EEG.Fs;

    ECG_signal = Patient_Data.(patient_Number).ECG.signal;
    ECG_Fs = Patient_Data.(patient_Number).ECG.Fs;

    EEG_sec_signal = Patient_Data.(patient_Number).EEG_sec.signal;
    EEG_sec_Fs = Patient_Data.(patient_Number).EEG_sec.Fs;

    EMG_signal = Patient_Data.(patient_Number).EMG.signal;
    EMG_Fs = Patient_Data.(patient_Number).EMG.Fs;

    EOGR_signal = Patient_Data.(patient_Number).EOGR.signal;
    EOGR_Fs = Patient_Data.(patient_Number).EOGR.Fs;

    EOGL_signal = Patient_Data.(patient_Number).EOGL.signal;
    EOGL_Fs = Patient_Data.(patient_Number).EOGL.Fs;
    
    EEG_preprocessed = [];
    ECG_preprocessed = [];
    EEG_sec_preprocessed = [];
    EMG_preprocessed = [];
    EOGR_preprocessed = [];
    EOGL_preprocessed = [];
    
    
    for epochNumber=1:numberOfEpochs-1
        eeg_epoch_start = (epochNumber*EEG_Fs*30);
        eeg_epoch_end = min(eeg_epoch_start + 30*EEG_Fs, length(EEG_signal));

        fprintf("Extracting Features Epoch %d of %d Patient %s\n", epochNumber, numberOfEpochs, patient_Number);
        
        eeg_preprocess = preprocess_EEG(EEG_signal(eeg_epoch_start:eeg_epoch_end), EEG_Fs);
        EEG_temp_features = sprintf("EEG_temporal_features_Epoch_%d", epochNumber);
        EEG_spec_features = sprintf("EEG_spectral_features_Epoch_%d", epochNumber);
        EEG_wave_features = sprintf("EEG_wave_features_Epoch_%d", epochNumber);
        EEG_binary_features = sprintf("EEG_binary_features_Epoch_%d", epochNumber);

        Patient_Data.(patient_Number).EEG_features.(EEG_temp_features) = temporal_feature_extraction(eeg_preprocess, EEG_Fs);
        Patient_Data.(patient_Number).EEG_features.(EEG_spec_features) = spectral_feature_extraction(eeg_preprocess, EEG_Fs);
        Patient_Data.(patient_Number).EEG_features.(EEG_wave_features) = waves_feature_extraction(eeg_preprocess, EEG_Fs);
        Patient_Data.(patient_Number).EEG_features.(EEG_binary_features) = binary_feature_extraction(eeg_preprocess, EEG_Fs);

        EEG_preprocessed = [EEG_preprocessed, eeg_preprocess];

        ecg_epoch_start = (epochNumber*ECG_Fs*30);
        ecg_epoch_end = min(ecg_epoch_start + 30*ECG_Fs, length(ECG_signal));
        
        ecg_preprocess = preprocess_ECG(ECG_signal(ecg_epoch_start:ecg_epoch_end), ECG_Fs);
        ECG_temp_features = sprintf("ECG_temporal_features_Epoch_%d", epochNumber);
        ECG_spec_features = sprintf("ECG_spectral_features_Epoch_%d", epochNumber);
        ECG_hrv = sprintf("ECG_hrv_Epoch_%d", epochNumber);

        Patient_Data.(patient_Number).ECG_features.(ECG_temp_features) = temporal_feature_extraction(ecg_preprocess, ECG_Fs);
        Patient_Data.(patient_Number).ECG_features.(ECG_spec_features) = spectral_feature_extraction(ecg_preprocess, ECG_Fs);
        Patient_Data.(patient_Number).ECG_features.(ECG_hrv) = hrv_calculation(ecg_preprocess, ECG_Fs);

        ECG_preprocessed = [ECG_preprocessed, ecg_preprocess];

        eeg_sec_epoch_start = (epochNumber*EEG_sec_Fs*30);
        eeg_sec_epoch_end = min(eeg_sec_epoch_start + 30*EEG_sec_Fs, length(EEG_sec_signal));
        
        eeg_sec_preprocess = preprocess_EEG(EEG_sec_signal(eeg_sec_epoch_start:eeg_sec_epoch_end), EEG_sec_Fs);
        EEG_sec_temp_features = sprintf("EEG_sec_temporal_features_Epoch_%d", epochNumber);
        EEG_sec_spec_features = sprintf("EEG_sec_spectral_features_Epoch_%d", epochNumber);
        EEG_sec_wave_features = sprintf("EEG_sec_wave_features_Epoch_%d", epochNumber);
        EEG_sec_binary_features = sprintf("EEG_sec_binary_features_Epoch_%d", epochNumber);

        Patient_Data.(patient_Number).EEG_sec_features.(EEG_sec_temp_features) = temporal_feature_extraction(eeg_sec_preprocess, EEG_sec_Fs);
        Patient_Data.(patient_Number).EEG_sec_features.(EEG_sec_spec_features) = spectral_feature_extraction(eeg_sec_preprocess, EEG_sec_Fs);
        Patient_Data.(patient_Number).EEG_sec_features.(EEG_sec_wave_features) = waves_feature_extraction(eeg_sec_preprocess, EEG_sec_Fs);
        Patient_Data.(patient_Number).EEG_sec_features.(EEG_sec_binary_features) = binary_feature_extraction(eeg_sec_preprocess, EEG_sec_Fs);

        EEG_sec_preprocessed = [EEG_sec_preprocessed, eeg_sec_preprocess];

        emg_epoch_start = (epochNumber*EMG_Fs*30);
        emg_epoch_end = min(emg_epoch_start + 30*EMG_Fs, length(EMG_signal));
        
        emg_preprocess = preprocess_EMG(EMG_signal(emg_epoch_start:emg_epoch_end), EMG_Fs);
        EMG_temp_features = sprintf("EMG_temporal_features_Epoch_%d", epochNumber);
        EMG_spec_features = sprintf("EMG_spectral_features_Epoch_%d", epochNumber);

        Patient_Data.(patient_Number).EMG_features.(EMG_temp_features) = temporal_feature_extraction(emg_preprocess, EMG_Fs);
        Patient_Data.(patient_Number).EMG_features.(EMG_spec_features) = spectral_feature_extraction(emg_preprocess, EMG_Fs);

        EMG_preprocessed = [EMG_preprocessed, emg_preprocess];

        eogr_epoch_start = (epochNumber*EOGR_Fs*30);
        eogr_epoch_end = min(eogr_epoch_start + 30*EOGR_Fs, length(EOGR_signal));
        
        EOGR_temp_features = sprintf("EOGR_temporal_features_Epoch_%d", epochNumber);
        EOGR_spec_features = sprintf("EOGR_spectral_features_Epoch_%d", epochNumber);

        Patient_Data.(patient_Number).EOGR_features.(EOGR_temp_features) = temporal_feature_extraction(EOGR_signal(eogr_epoch_start:eogr_epoch_end), EOGR_Fs);
        Patient_Data.(patient_Number).EOGR_features.(EOGR_spec_features) = spectral_feature_extraction(EOGR_signal(eogr_epoch_start:eogr_epoch_end), EOGR_Fs);
        

        eogl_epoch_start = (epochNumber*EOGL_Fs*30);
        eogl_epoch_end = min(eogl_epoch_start + 30*EOGL_Fs, length(EOGL_signal));
        
        EOGL_temp_features = sprintf("EOGL_temporal_features_Epoch_%d", epochNumber);
        EOGL_spec_features = sprintf("EOGL_spectral_features_Epoch_%d", epochNumber);

        Patient_Data.(patient_Number).EOGL_features.(EOGL_temp_features) = temporal_feature_extraction(EOGL_signal(eogl_epoch_start:eogl_epoch_end), EOGL_Fs);
        Patient_Data.(patient_Number).EOGL_features.(EOGL_spec_features) = spectral_feature_extraction(EOGL_signal(eogl_epoch_start:eogl_epoch_end), EOGL_Fs);
            
    end
    Patient_Data.(patient_Number).EEG_preprocessed = EEG_preprocessed;
    Patient_Data.(patient_Number).ECG_preprocessed = ECG_preprocessed;
    Patient_Data.(patient_Number).EEG_sec_preprocessed = EEG_sec_preprocessed;
    Patient_Data.(patient_Number).EMG_preprocessed = EMG_preprocessed;
    % Save updated patient data with features in the same patient file
    save(sprintf('Patient_Data_%s.mat', patient_Number), 'Patient_Data');
end


%% Get back all patient data into one file (run separately)
Consolidated_Data = struct();
for i = 1:numPatients
    filename = sprintf('Patient_Data_R%d.mat', i);
    if isfile(filename)
        load(filename);
        patient_Number = sprintf("R%d", i);
        Consolidated_Data.(patient_Number) = Patient_Data.(patient_Number);
    else
        warning('File %s does not exist.', filename);
    end
end

% Save the consolidated data into one file  # -v7.3 is necessary if version
% of matlab is old to save data > 2gb
Patient_Data = Consolidated_Data;
save("Feature_Extracted_Data_final.mat", "Patient_Data", '-v7.3')

