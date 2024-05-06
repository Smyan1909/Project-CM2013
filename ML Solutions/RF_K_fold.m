% Load Data
%[feat_mat, sleep_stage_vec] = create_feature_matrix();

% Split Data
patientsSamples = [1083, 1078, 1048, 874, 1083, 1083, 918, 958, 1085, 1083]; % Number of samples per patient
all_patients = [1,2,3,4,5,6,7,8,9,10];
cumulativeSamples = [0, cumsum(patientsSamples)];    

%% Random Forest Model Setup
numTrees = [100, 200, 500];  % Number of trees in the forest
%numTrees = [100];
maxNumSplits = [10, 20, 50]; % Maximum number of splits in each decision tree

%% Patient-Based Cross-Validation
fprintf('Setting up patient-based cross-validation...\n');

results = struct();
index = 0;
for nTrees = numTrees
    for numSplits = maxNumSplits
        oobErrors = zeros(length(patientsSamples), 1);
        accuracies = zeros(length(patientsSamples), 1);

        fprintf('Evaluating parameters: Trees = %d, Max Splits = %d\n', nTrees, numSplits);

        for i = 1:length(patientsSamples)
            fprintf('Processing data for patient %d...\n', all_patients(i));
            
            % Set validation data to current patient
            val_patients = [i];
            train_patients =setdiff(all_patients, val_patients);
            test_patients = [];
            % Splitting the data for training and testing (validation split is not used here)
            [X_train_fold, Y_train_fold, X_valid_fold, Y_valid_fold, ~, ~] = split_data(feat_mat, sleep_stage_vec, train_patients, val_patients, test_patients);
            % Preprocess Data
            [X_train_fold, X_valid_fold, ~] = preprocess_data(X_train_fold, X_valid_fold, [], false);

            % Train the model
            RFModel = TreeBagger(nTrees, X_train_fold, Y_train_fold, 'Method', 'classification', ...
                                 'NumPredictorsToSample', 'all', 'MinLeafSize', numSplits, ...
                                 'OOBPrediction', 'on');

            % Evaluate the model
            oobErrors(i) = oobError(RFModel, 'Mode', 'ensemble');
            accuracies(i) = validate_model_rf(RFModel, X_valid_fold, Y_valid_fold);

        end

        % Average OOB error and accuracy across all patient-specific folds
        avgOOBError = mean(oobErrors);
        avgAccuracy = mean(accuracies);
        index = index + 1;
        results(index).numTrees = nTrees;
        results(index).maxNumSplits = numSplits;
        results(index).OOBError = avgOOBError;
        results(index).ValidationAccuracy = avgAccuracy;

        fprintf('Configuration %d: Avg OOB Error = %.2f%%, Avg Accuracy = %.2f%%\n', index, avgOOBError * 100, avgAccuracy);
    end
end

%% Best Configuration Based on Minimum OOB Error
[minError, minIdx] = min([results.OOBError]);
bestParams = results(minIdx);


currentDateTime = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
filename = sprintf('ModelResults_%s.mat', currentDateTime);
save(filename, 'bestParams', 'results');
