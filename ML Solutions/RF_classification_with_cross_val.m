%% For this method, I use k-fold validation to select the parameters.

% Load Data
%[feat_mat, sleep_stage_vec] = create_feature_matrix();

% Split Data
patientsSamples = [1083, 1078, 1048, 874, 1083, 1083, 918, 958, 1085, 1083]; % Number of samples per patient
% Define patient groups for training, validation, and testing
train_patients = [1,2,3,4,5,6, 7, 8];
val_patients = [];
test_patients = [9,10];
[x_train, y_train, x_val, y_val, x_test, y_test] = split_data(feat_mat, sleep_stage_vec, train_patients, val_patients, test_patients);

% Preprocess Data
[x_train, x_val, x_test] = preprocess_data(x_train, x_val, x_test, false);

%% Random Forest Model Setup
% Hyperparameters to test (Primary list, yet to explore other ones)
numTrees = [100, 200, 500];  % Number of trees in the forest
maxNumSplits = [10, 20, 50]; % Maximum number of splits in each decision tree

% Set up cross-validation partition
k = 5; % Number of folds for cross-validation
cvp = cvpartition(y_train, 'KFold', k);


%% Cross-Validation Execution with Parameter Search
results = struct();
index = 0;
cvp = cvpartition(y_train, 'KFold', k); % k-fold cross-validation setup

for nTrees = numTrees
    for numSplits = maxNumSplits
        oobErrors = zeros(cvp.NumTestSets, 1);
        accuracies = zeros(cvp.NumTestSets, 1);

        for i = 1:cvp.NumTestSets
            % Indices for training and validation within the fold
            trainIdx = cvp.training(i);
            validIdx = cvp.test(i);
            % Training data for the fold
            X_train_fold = x_train(trainIdx, :);
            Y_train_fold = y_train(trainIdx);
            % Validation data for the fold
            X_valid_fold = x_train(validIdx, :);
            Y_valid_fold = y_train(validIdx);

            % Train the model on the fold's training data
            RFModel = TreeBagger(nTrees, X_train_fold, Y_train_fold, 'Method', 'classification', ...
                                 'NumPredictorsToSample', 'all', 'MinLeafSize', numSplits, ...
                                 'OOBPrediction', 'on');

            oobErrors(i) = oobError(RFModel, 'Mode', 'ensemble');

            validPredictions = predict(RFModel, X_valid_fold);
            validPredictions = str2double(validPredictions); 
            accuracies(i) = sum(validPredictions == Y_valid_fold) / numel(Y_valid_fold) * 100;
        end

        % Average OOB error and accuracy across all folds
        avgOOBError = mean(oobErrors);
        avgAccuracy = mean(accuracies);

        % Store results
        index = index + 1;
        results(index).numTrees = nTrees;
        results(index).maxNumSplits = numSplits;
        results(index).OOBError = avgOOBError;
        results(index).ValidationAccuracy = avgAccuracy;
        
        fprintf('Testing configuration %d: numTrees = %d, maxNumSplits = %d, Avg OOB Error = %.2f%%, Avg Accuracy = %.2f%%\n', ...
                index, nTrees, numSplits, avgOOBError * 100, avgAccuracy);
    end
end


%% Best Configuration Based on Minimum OOB Error
oobErrors = arrayfun(@(s) s.OOBError, results);
[minError, minIdx] = min(oobErrors);
bestParams = results(minIdx);

fprintf('Best configuration: numTrees = %d, maxNumSplits = %d, OOB Error = %.2f%%, Accuracy = %.2f%%\n', ...
        bestParams.numTrees, bestParams.maxNumSplits, minError * 100, bestParams.ValidationAccuracy);

%% Train the Final Model on Full Training Data Using the Best Parameters
finalRFModel = TreeBagger(bestParams.numTrees, x_train, y_train, 'Method', 'classification', ...
                          'NumPredictorsToSample', 'all', 'MinLeafSize', bestParams.maxNumSplits);

%% Test the model
y_pred = predict(finalRFModel, x_test);
y_pred = str2double(y_pred);
accuracy = sum(y_pred == y_test) / numel(y_test) * 100;
fprintf('Accuracy: %.2f%%\n', accuracy * 100);

y_pred_cat = categorical(y_pred, [0,2,3,4,5], {'REM','N3','N2','N1','Wake'});
y_test_cat = categorical(y_test, [0,2,3,4,5], {'REM','N3','N2','N1','Wake'});

confusionchart(y_test_cat, y_pred_cat, 'RowSummary','row-normalized', ...
            'ColumnSummary','column-normalized');

%% Save test results for later analysis.
save(strcat("RF_classification_cross_val_test_", string(datetime(), 'yyyy-MM-dd''T''HHmm'),".mat"), 'y_pred', 'x_test');