function [feat_mat, sleep_stage_vec] = create_feature_matrix()
    %CREATE_FEATURE_MATRIX This function creates the feature matrix and the
    %sleep stage vector
    display("Loading Data ...")
    load("Feature_Extracted_Data.mat", "Patient_Data");
    
    numPatients = 10;
    numSignals = 6;
    
    feat_mat = [];
    sleep_stage_vec = [];

    patientVec = 1:10; % ADJUST as needed which patient numbers are available

    for i=patientVec
        patient_number = sprintf("R%d", i);
        
        %number_of_cols = 111; %This number should be changed in the event more features are added
        %number_of_rows = (1084+1079+1049+875+1084+1084+919+959+1086+1084) - 10;

        %feat_mat = zeros(number_of_rows, number_of_cols);
        
        
        numberOfEpochs = Patient_Data.(patient_number).numberOfEpochs;
        
        sleep_stage = Patient_Data.(patient_number).sleep_stages;
        sleep_stage = sleep_stage(1:30:length(sleep_stage)-1)';
        

        for k=1:numberOfEpochs-1
            feat_vec = [];
            fprintf("Generating feature matrix patient R%d Epoch %d \n", i, k);
            for j=1:numSignals
                if j == 1
                    feature_struct = Patient_Data.(patient_number).EEG_features;
                    
                    temporal_field_strID = sprintf("EEG_temporal_features_Epoch_%d", k);
                    spectral_field_strID = sprintf("EEG_spectral_features_Epoch_%d", k);
                    wave_field_strID = sprintf("EEG_wave_features_Epoch_%d", k);
                    binary_field_strID = sprintf("EEG_binary_features_Epoch_%d", k);
    
                    temp_feat_string = fieldnames(feature_struct.(temporal_field_strID));
                    for feats=1:numel(temp_feat_string)
                        new_feat = feature_struct.(temporal_field_strID).(temp_feat_string{feats});
                        feat_vec = [feat_vec, new_feat];
                    end
                    
                    spec_feat_string = fieldnames(feature_struct.(spectral_field_strID));
                    for feats=1:numel(spec_feat_string)
                        new_feat = feature_struct.(spectral_field_strID).(spec_feat_string{feats});
                        feat_vec = [feat_vec, new_feat];
                    end

                    wave_feat_string = fieldnames(feature_struct.(wave_field_strID));
                    for feats=1:numel(wave_feat_string)
                        feat_type = fieldnames(feature_struct.(wave_field_strID).(wave_feat_string{feats}));
                        new_feat1 = feature_struct.(wave_field_strID).(wave_feat_string{feats}).(feat_type{1});
                        new_feat2 = feature_struct.(wave_field_strID).(wave_feat_string{feats}).(feat_type{3});
                        feat_vec = [feat_vec, new_feat1, new_feat2];
                    end

                    binary_feat_string = fieldnames(feature_struct.(binary_field_strID));
                    for feats=1:numel(binary_feat_string)
                        new_feat = feature_struct.(binary_field_strID).(binary_feat_string{feats});
                        feat_vec = [feat_vec, new_feat];
                    end
                    %new_feat = feature_struct.(binary_field).(binary_feat_string{1});
                    %feat_vec = [feat_vec, new_feat];
                    
                elseif j == 2
                    feature_struct = Patient_Data.(patient_number).ECG_features;

                    temporal_field_strID = sprintf("ECG_temporal_features_Epoch_%d", k);
                    spectral_field_strID = sprintf("ECG_spectral_features_Epoch_%d", k);
                    hrv_field = sprintf("ECG_hrv_Epoch_%d", k);
                    
    
                    temp_feat_string = fieldnames(feature_struct.(temporal_field_strID));
                    for feats=1:numel(temp_feat_string)
                        new_feat = feature_struct.(temporal_field_strID).(temp_feat_string{feats});
                        feat_vec = [feat_vec, new_feat];
                    end
                    
                    spec_feat_string = fieldnames(feature_struct.(spectral_field_strID));
                    for feats=1:numel(spec_feat_string)
                        new_feat = feature_struct.(spectral_field_strID).(spec_feat_string{feats});
                        feat_vec = [feat_vec, new_feat];
                    end
                        
                        feat_vec = [feat_vec, feature_struct.(hrv_field)];
    
                elseif j == 3
                    feature_struct = Patient_Data.(patient_number).EEG_sec_features;

                    temporal_field_strID = sprintf("EEG_sec_temporal_features_Epoch_%d", k);
                    spectral_field_strID = sprintf("EEG_sec_spectral_features_Epoch_%d", k);
                    wave_field_strID = sprintf("EEG_sec_wave_features_Epoch_%d", k);
                    binary_field_strID = sprintf("EEG_sec_binary_features_Epoch_%d", k);
    
                    temp_feat_string = fieldnames(feature_struct.(temporal_field_strID));
                    for feats=1:numel(temp_feat_string)
                        new_feat = feature_struct.(temporal_field_strID).(temp_feat_string{feats});
                        feat_vec = [feat_vec, new_feat];
                    end
                    
                    spec_feat_string = fieldnames(feature_struct.(spectral_field_strID));
                    for feats=1:numel(spec_feat_string)
                        new_feat = feature_struct.(spectral_field_strID).(spec_feat_string{feats});
                        feat_vec = [feat_vec, new_feat];
                    end

                    wave_feat_string = fieldnames(feature_struct.(wave_field_strID));
                    for feats=1:numel(wave_feat_string)
                        feat_type = fieldnames(feature_struct.(wave_field_strID).(wave_feat_string{feats}));
                        new_feat1 = feature_struct.(wave_field_strID).(wave_feat_string{feats}).(feat_type{1});
                        new_feat2 = feature_struct.(wave_field_strID).(wave_feat_string{feats}).(feat_type{3});
                        feat_vec = [feat_vec, new_feat1, new_feat2];
                    end
                    
                    binary_feat_string = fieldnames(feature_struct.(binary_field_strID));
                    for feats=1:numel(binary_feat_string)
                        new_feat = feature_struct.(binary_field_strID).(binary_feat_string{feats});
                        feat_vec = [feat_vec, new_feat];
                    end
                    %new_feat = feature_struct.(binary_field).(binary_feat_string{1});
                    %feat_vec = [feat_vec, new_feat];
    
                elseif j == 4
                    feature_struct = Patient_Data.(patient_number).EMG_features;

                    temporal_field_strID = sprintf("EMG_temporal_features_Epoch_%d", k);
                    spectral_field_strID = sprintf("EMG_spectral_features_Epoch_%d", k);
    
                    temp_feat_string = fieldnames(feature_struct.(temporal_field_strID));
                    for feats=1:numel(temp_feat_string)
                        new_feat = feature_struct.(temporal_field_strID).(temp_feat_string{feats});
                        feat_vec = [feat_vec, new_feat];
                    end
                    
                    spec_feat_string = fieldnames(feature_struct.(spectral_field_strID));
                    for feats=1:numel(spec_feat_string)
                        new_feat = feature_struct.(spectral_field_strID).(spec_feat_string{feats});
                        feat_vec = [feat_vec, new_feat];
                    end
                    
    
                elseif j == 5
                    feature_struct = Patient_Data.(patient_number).EOGR_features;

                    temporal_field_strID = sprintf("EOGR_temporal_features_Epoch_%d", k);
                    spectral_field_strID = sprintf("EOGR_spectral_features_Epoch_%d", k);
                    visual_field_strID = sprintf("EOGR_visual_features_Epoch_%d", k);
    
                    temp_feat_string = fieldnames(feature_struct.(temporal_field_strID));
                    for feats=1:numel(temp_feat_string)
                        new_feat = feature_struct.(temporal_field_strID).(temp_feat_string{feats});
                        feat_vec = [feat_vec, new_feat];
                    end
                    
                    spec_feat_string = fieldnames(feature_struct.(spectral_field_strID));
                    for feats=1:numel(spec_feat_string)
                        new_feat = feature_struct.(spectral_field_strID).(spec_feat_string{feats});
                        feat_vec = [feat_vec, new_feat];
                    end
                    
                    visual_feat_fieldnames = fieldnames(feature_struct.(visual_field_strID));
                    for feat_i=1:numel(visual_feat_fieldnames)
                        new_feat = feature_struct.(visual_field_strID).(visual_feat_fieldnames{feat_i});
                        feat_vec = [feat_vec, new_feat];
                    end
                elseif j == 6
                    feature_struct = Patient_Data.(patient_number).EOGL_features;

                    temporal_field_strID = sprintf("EOGL_temporal_features_Epoch_%d", k);
                    spectral_field_strID = sprintf("EOGL_spectral_features_Epoch_%d", k);
                    visual_field_strID = sprintf("EOGL_visual_features_Epoch_%d", k);
    
                    temp_feat_string = fieldnames(feature_struct.(temporal_field_strID));
                    for feats=1:numel(temp_feat_string)
                        new_feat = feature_struct.(temporal_field_strID).(temp_feat_string{feats});
                        feat_vec = [feat_vec, new_feat];
                    end
                    
                    spec_feat_string = fieldnames(feature_struct.(spectral_field_strID));
                    for feats=1:numel(spec_feat_string)
                        new_feat = feature_struct.(spectral_field_strID).(spec_feat_string{feats});
                        feat_vec = [feat_vec, new_feat];
                    end
                    
                    visual_feat_fieldnames = fieldnames(feature_struct.(visual_field_strID));
                    for feat_i=1:numel(visual_feat_fieldnames)
                        new_feat = feature_struct.(visual_field_strID).(visual_feat_fieldnames{feat_i});
                        feat_vec = [feat_vec, new_feat];
                    end
                end
        
            end
            feat_mat = [feat_mat; feat_vec];
        end
        sleep_stage_vec = [sleep_stage_vec; sleep_stage];
    end

end

