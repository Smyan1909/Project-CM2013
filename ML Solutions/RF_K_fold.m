% Load Data
[feat_mat, sleep_stage_vec] = create_feature_matrix();

% Split Data
patientsSamples = [1083, 1078, 1048, 874, 1083, 1083, 918, 958, 1085, 1083]; % Number of samples per patient
all_patients = [1,2,3,4,5,6,7,8,9];
cumulativeSamples = [0, cumsum(patientsSamples)];
sleep_stage_vec(sleep_stage_vec == 1) = 2;

%% Random Forest Model Setup
%numTrees = [100, 200, 500];  % Number of trees in the forest
numTrees = [500];
maxNumSplits = [10]; % Maximum number of splits in each decision tree


%% Patient-Based Cross-Validation
fprintf('Setting up patient-based cross-validation...\n');

results = struct();
index = 0;
for nTrees = numTrees
    for numSplits = maxNumSplits
        oobErrors = zeros(length(all_patients), 1);
        accuracies = zeros(length(all_patients), 1);

        fprintf('Evaluating parameters: Trees = %d, Max Splits = %d\n', nTrees, numSplits);

        for i = 1:length(all_patients)
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
        stdOOBError = std(oobErrors);
        avgAccuracy = mean(accuracies);
        valVarAcc = var(accuracies);
        stdAcc = std(accuracies);
        index = index + 1;
        results(index).numTrees = nTrees;
        results(index).maxNumSplits = numSplits;
        results(index).OOBError = avgOOBError;
        results(index).ValidationAccuracy = avgAccuracy;
        results(index).AccuracyVariance = valVarAcc;
        results(index).StandardDeviation = stdAcc;

        fprintf('Configuration %d: Avg OOB Error = %.2f%%, Avg Accuracy = %.2f%%, StandardDeviationAcc = %.2f%%, StandardDeviationOOB = %.2f%%\n', index, avgOOBError * 100, avgAccuracy * 100, stdAcc * 100, stdOOBError * 100);
    end
end

%% Best Configuration Based on Minimum OOB Error
[minError, minIdx] = min([results.OOBError]);
bestParams = results(minIdx);


%currentDateTime = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
%filename = sprintf('ModelResults_%s.mat', currentDateTime);
%save(filename, 'bestParams', 'results');
%% Retrain the model 
[x_train, y_train, ~, ~, x_test, y_test] = split_data(feat_mat, sleep_stage_vec, 1:9,[],[10]);

finalRFModel = TreeBagger(bestParams.numTrees, x_train, y_train, 'Method', 'classification', ...
                                 'NumPredictorsToSample', 'all', 'MinLeafSize', bestParams.maxNumSplits, ...
                                 'OOBPrediction', 'on', 'OOBPredictorImportance','on');

%% Plotting the Feature Importance using the RF framework
[sortedImportance, sortedIndices] = sort(featureImportance, 'descend');
top10Indices = sortedIndices(1:10);
top10Importance = sortedImportance(1:10);

bar(top10Importance);
xlabel('Features');
ylabel('Importance Score');
title('Top 10 Important Features');

set(gca, 'XTick', 1:10, 'XTickLabel', {"WL EEG\_sec", "MAV EEG", "Activity EOGR", "Activity EEG\_sec", "WL EMG", "Mobility EEG\_sec",...
    "MAV EMG", "MAV EOGL", "Activity EEG", "Delta Wave % EEG"})

%% Test the Model
y_pred = predict(finalRFModel, x_test);
y_pred = str2num(cell2mat(y_pred));
y_pred = medfilt1(y_pred, 5);

accuracy = sum(y_pred == y_test) / numel(y_test);
fprintf('Accuracy: %.2f%%\n', accuracy * 100);

y_pred_cat = categorical(y_pred, [0,2,3,4,5], {'REM','N3','N2','N1','Wake'});
y_test_cat = categorical(y_test, [0,2,3,4,5], {'REM','N3','N2','N1','Wake'});

figure
confusionchart(y_test_cat, y_pred_cat, 'RowSummary','row-normalized', ...
           'ColumnSummary','column-normalized')

figure
plot(((1:length(y_test)))./2,y_test_cat)
hold on
plot(((1:length(y_pred)))./2,y_pred_cat)
legend({"Annotated Data", "Predicted Data"})
xlabel("Time [min]")
ylabel("Sleep Stage")
