function [x_train, y_train, x_val, y_val, x_test, y_test] = split_data(feat_mat, sleep_stage_vec, train_patients, val_patients, test_patients)
    % Hardcoded patient samples (not ideal I think)
    patientSamples = [1083, 1078, 1048, 874, 1083, 1083, 918, 958, 1085, 1083];
    cumulativeSamples = [0, cumsum(patientSamples)];    

    % Extract data for training, validation, and testing
    x_train = [];
    y_train = [];
    for i = train_patients
        startIdx = cumulativeSamples(i) + 1;
        endIdx = cumulativeSamples(i + 1);
        x_train = [x_train; feat_mat(startIdx:endIdx, :)];
        y_train = [y_train; sleep_stage_vec(startIdx:endIdx)];
    end

    x_val = [];
    y_val = [];
    for i = val_patients
        startIdx = cumulativeSamples(i) + 1;
        endIdx = cumulativeSamples(i + 1);
        x_val = [x_val; feat_mat(startIdx:endIdx, :)];
        y_val = [y_val; sleep_stage_vec(startIdx:endIdx)];
    end

    x_test = [];
    y_test = [];
    for i = test_patients
        startIdx = cumulativeSamples(i) + 1;
        endIdx = cumulativeSamples(i + 1);
        x_test = [x_test; feat_mat(startIdx:endIdx, :)];
        y_test = [y_test; sleep_stage_vec(startIdx:endIdx)];
    end

end
