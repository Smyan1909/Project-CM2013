function [featureCount, featureNames] = count_and_name_features(Patient_Data)
%COUNT_AND_NAME_FEATURES Count and name features.
%   Relevant to feature matrix construction.

featureCount = 0;

featureNames = {};

% Take the first patient, first epoch, no need to do this multiple times.
patients_in_data = fieldnames(Patient_Data);
epoch_struct = Patient_Data.(patients_in_data{1});
k = 1;

for j=1:6
    if j == 1 % EEG (primary)
        feature_struct = epoch_struct.EEG_features;
        temporal_field_strID = sprintf("EEG_temporal_features_Epoch_%d", k);
        spectral_field_strID = sprintf("EEG_spectral_features_Epoch_%d", k);
        wave_field_strID = sprintf("EEG_wave_features_Epoch_%d", k);
        binary_field_strID = sprintf("EEG_binary_features_Epoch_%d", k);
        
        temp_feat_string = fieldnames(feature_struct.(temporal_field_strID));
        featureNames = [featureNames ; temp_feat_string]; % concat vertically in square brackets
        % for feats=1:numel(temp_feat_string)
        %     new_feat = feature_struct.(temporal_field_strID).(temp_feat_string{feats});
        %     feat_vec = [feat_vec, new_feat];
        % end
    
        spec_feat_string = fieldnames(feature_struct.(spectral_field_strID));
        featureNames = [featureNames ; spec_feat_string];
        % for feats=1:numel(spec_feat_string)
        %     new_feat = feature_struct.(spectral_field_strID).(spec_feat_string{feats});
        %     feat_vec = [feat_vec, new_feat];
        % end
    
        wave_feat_string = fieldnames(feature_struct.(wave_field_strID));
        featureNames = [featureNames ; ]
        % for feats=1:numel(wave_feat_string)
        %     feat_type = fieldnames(feature_struct.(wave_field_strID).(wave_feat_string{feats}));
        %     new_feat1 = feature_struct.(wave_field_strID).(wave_feat_string{feats}).(feat_type{1});
        %     new_feat2 = feature_struct.(wave_field_strID).(wave_feat_string{feats}).(feat_type{3});
        %     feat_vec = [feat_vec, new_feat1, new_feat2];
        % end
    
        binary_feat_string = fieldnames(feature_struct.(binary_field_strID));
        featureCount = featureCount + numel(binary_feat_string);
        % for feats=1:numel(binary_feat_string)
        %     new_feat = feature_struct.(binary_field_strID).(binary_feat_string{feats});
        %     feat_vec = [feat_vec, new_feat];
        % end
        %new_feat = feature_struct.(binary_field).(binary_feat_string{1});
        %feat_vec = [feat_vec, new_feat];
                        
    elseif j == 2 % ECG
        feature_struct = epoch_struct.ECG_features;
    
        temporal_field_strID = sprintf("ECG_temporal_features_Epoch_%d", k);
        spectral_field_strID = sprintf("ECG_spectral_features_Epoch_%d", k);
        hrv_field = sprintf("ECG_hrv_Epoch_%d", k);
        
    
        temp_feat_string = fieldnames(feature_struct.(temporal_field_strID));
        featureCount = featureCount + numel(temp_feat_string);
        % for feats=1:numel(temp_feat_string)
        %     new_feat = feature_struct.(temporal_field_strID).(temp_feat_string{feats});
        %     feat_vec = [feat_vec, new_feat];
        % end
        
        spec_feat_string = fieldnames(feature_struct.(spectral_field_strID));
        for feats=1:numel(spec_feat_string)
            new_feat = feature_struct.(spectral_field_strID).(spec_feat_string{feats});
            feat_vec = [feat_vec, new_feat];
        end
            
            feat_vec = [feat_vec, feature_struct.(hrv_field)];
    
    elseif j == 3 % EEG_sec
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
    
    elseif j == 4 % EMG
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
        
    
    elseif j == 5 % EOGR
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
    elseif j == 6 % EOGL
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
    sleep_stage_vec = [sleep_stage_vec; sleep_stage]
    
end

