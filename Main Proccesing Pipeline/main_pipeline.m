%% Load in and register all data patient wise

clear all;
clc;
numPatients = 10;
Patient_Data = struct();
for i=1:numPatients
    edfFileName = sprintf("Project Data/R%d.edf", i);
    xmlFileName = sprintf("Project Data/R%d.xml", i);

    [hdr, record] = edfread(edfFileName);
    [events, stages, epochLength,annotation] = readXML(xmlFileName);
    
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
    
    

end
save('Main Proccesing Pipeline/Patient_Data.mat', "Patient_Data", "numPatients")
%% Load Patient Data, apply preprocessing and extract some features (Currently only for ECG, EEG and EMG)
load('Patient_Data.mat')

for i=1:numPatients
    patient_Number = sprintf("R%d", i);

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

        Patient_Data.(patient_Number).EEG_features.(EEG_temp_features) = temporal_feature_extraction(eeg_preprocess, EEG_Fs);
        Patient_Data.(patient_Number).EEG_features.(EEG_spec_features) = spectral_feature_extraction(eeg_preprocess, EEG_Fs);
        Patient_Data.(patient_Number).EEG_features.(EEG_wave_features) = waves_feature_extraction(eeg_preprocess, EEG_Fs);

        EEG_preprocessed = [EEG_preprocessed, eeg_preprocess];

        ecg_epoch_start = (epochNumber*ECG_Fs*30);
        ecg_epoch_end = min(ecg_epoch_start + 30*ECG_Fs, length(ECG_signal));
        
        ecg_preprocess = preprocess_ECG(ECG_signal(ecg_epoch_start:ecg_epoch_end), ECG_Fs);
        ECG_temp_features = sprintf("ECG_temporal_features_Epoch_%d", epochNumber);
        ECG_spec_features = sprintf("ECG_spectral_features_Epoch_%d", epochNumber);

        Patient_Data.(patient_Number).ECG_features.(ECG_temp_features) = temporal_feature_extraction(ecg_preprocess, ECG_Fs);
        Patient_Data.(patient_Number).ECG_features.(ECG_spec_features) = spectral_feature_extraction(ecg_preprocess, ECG_Fs);

        ECG_preprocessed = [ECG_preprocessed, ecg_preprocess];

        eeg_sec_epoch_start = (epochNumber*EEG_sec_Fs*30);
        eeg_sec_epoch_end = min(eeg_sec_epoch_start + 30*EEG_sec_Fs, length(EEG_sec_signal));
        
        eeg_sec_preprocess = preprocess_EEG(EEG_sec_signal(eeg_sec_epoch_start:eeg_sec_epoch_end), EEG_sec_Fs);
        EEG_sec_temp_features = sprintf("EEG_sec_temporal_features_Epoch_%d", epochNumber);
        EEG_sec_spec_features = sprintf("EEG_sec_spectral_features_Epoch_%d", epochNumber);
        EEG_sec_wave_features = sprintf("EEG_sec_wave_features_Epoch_%d", epochNumber);

        Patient_Data.(patient_Number).EEG_sec_features.(EEG_sec_temp_features) = temporal_feature_extraction(eeg_sec_preprocess, EEG_sec_Fs);
        Patient_Data.(patient_Number).EEG_sec_features.(EEG_sec_spec_features) = spectral_feature_extraction(eeg_sec_preprocess, EEG_sec_Fs);
        Patient_Data.(patient_Number).EEG_sec_features.(EEG_sec_wave_features) = waves_feature_extraction(eeg_sec_preprocess, EEG_sec_Fs);

        EEG_sec_preprocessed = [EEG_sec_preprocessed, eeg_sec_preprocess];

        emg_epoch_start = (epochNumber*EMG_Fs*30);
        emg_epoch_end = min(emg_epoch_start + 30*EMG_Fs, length(EMG_signal));
        
        emg_preprocess = preprocess_EMG(EMG_signal(emg_epoch_start:emg_epoch_end), EMG_Fs);
        EMG_temp_features = sprintf("EMG_temporal_features_Epoch_%d", epochNumber);
        EMG_spec_features = sprintf("EMG_spectral_features_Epoch_%d", epochNumber);

        Patient_Data.(patient_Number).EMG_features.(EMG_temp_features) = temporal_feature_extraction(emg_preprocess, EMG_Fs);
        Patient_Data.(patient_Number).EMG_features.(EMG_spec_features) = spectral_feature_extraction(emg_preprocess, EMG_Fs);

        EMG_preprocessed = [EMG_preprocessed, emg_preprocess];

            
    end
    Patient_Data.(patient_Number).EEG_preprocessed = EEG_preprocessed;
    Patient_Data.(patient_Number).ECG_preprocessed = ECG_preprocessed;
    Patient_Data.(patient_Number).EEG_sec_preprocessed = EEG_sec_preprocessed;
    Patient_Data.(patient_Number).EMG_preprocessed = EMG_preprocessed;
    
end
save("Main Proccesing Pipeline/Feature_Extracted_Data.mat", "Patient_Data")
%% Add visual features to pipeline. 


%% Load the feature extracted data (This may take some time)
load("Feature_Extracted_Data.mat")
%% Analyze features to perform feature selection (choose appropriate feature for appropriate signal and analyze)

feature = [];
patient_Name = "R10"; %Choose patient name R1, R2 ...
signal_Name = "EEG"; %Choose signal EEG, EEG_sec, EMG ...
feature_name = "beta_features"; %Choose feature Mean_Absolute_Value, Skewness ...
feature_type = "wave"; %Choose feature type temporal or spectral

%Run to aquire anova test with box plots
numberOfEpochs = Patient_Data.(patient_Name).numberOfEpochs;

signal_string = sprintf("%s_features", signal_Name);

for epochNumber=1:numberOfEpochs-1
    feature_string = sprintf("%s_%s_features_Epoch_%d", signal_Name, feature_type, epochNumber);
    %feature_string = sprintf("ECG_%s_features_Epoch_%d", feature_type, epochNumber);

    feature = [feature, Patient_Data.(patient_Name).(signal_string).(feature_string).(feature_name)];
    %feature = [feature, Patient_Data.(patient_Name).(signal_string).(feature_string).(feature_name).wave_power_percentage];
    
end

sleep_stage = Patient_Data.(patient_Name).sleep_stages;
sleep_stage = sleep_stage(1:30:length(sleep_stage)-1);
sleepStagesCategorical = categorical(sleep_stage, [0,2,3,4,5], {'REM','N3','N2','N1','Wake'});

%boxplot(feature, sleepStagesCategorical);
%ylabel("Feature Value")
%xlabel("Sleep Stage")
%title("Distribution of Feature")

[p, tbl, stats] = anova1(feature, sleepStagesCategorical);

%% Create feature matrix and choose ML model