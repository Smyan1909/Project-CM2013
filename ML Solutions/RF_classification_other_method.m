% Load Data
[feat_mat, sleep_stage_vec] = create_feature_matrix();

% Split Data
patientsSamples = [1083, 1078, 1048, 874, 1083, 1083, 918, 958, 1085, 1083]; % Number of samples per patient
% Define patient groups for training, validation, and testing
train_patients = [1,2,3,4,5,6];
val_patients = [7,8];
test_patients = [9,10];
[x_train, y_train, x_val, y_val, x_test, y_test] = split_data(feat_mat, sleep_stage_vec, train_patients, val_patients, test_patients);

% Preprocess Data
[x_train, x_val, x_test] = preprocess_data(x_train, x_val, x_test, false);

% Constants and Initial Setup
numFeatures = size(feat_mat, 2);
numTreesOptions = [100, 200, 300, 400, 500];
maxNumSplitsOptions = [20, 40, 60, 80, 100];
minLeafSizeOptions = [1, 5, 10, 20];
numPredictorsToSampleOptions = [ceil(sqrt(numFeatures)), ceil(numFeatures/2), numFeatures];  % Corresponds to 'NumPredictorsToSample' (like 'max_features' in Python)
patientsSamples = [1083, 1078, 1048, 874, 1083, 1083, 918, 958, 1085, 1083];
 

% First method: OOB Error Based Selection
fprintf('Starting OOB Error-based Random Search...\n');
%[bestModelOOB, bestParamsOOB, bestAccuracyOOB] = perform_random_search(x_train, y_train, x_val, y_val, 30, false);

% Second method: Validation Accuracy Based Selection
fprintf('Starting Validation Accuracy-based Random Search...\n');
[bestModelVal, bestParamsVal, bestAccuracyVal] = perform_random_search_rf(x_train, y_train, x_val, y_val, 10, true);
bestModel = TreeBagger(bestParamsVal.nTrees, x_train, y_train, 'Method', 'classification', ...
                       'OOBPrediction', 'On', 'OOBPredictorImportance', 'On', 'MinLeafSize', bestParamsVal.minLeafSize, ...
                       'MaxNumSplits', bestParamsVal.maxNumSplits, 'NumPredictorsToSample', bestParamsVal.numPredictorsToSample);

% For test data
[y_pred, testScores] = predict(bestModel, x_test);
y_pred = str2double(y_pred);
y_pred_cat = categorical(y_pred, [0,2,3,4,5], {'REM','N3','N2','N1','Wake'});
y_test_cat = categorical(y_test, [0,2,3,4,5], {'REM','N3','N2','N1','Wake'});
confusionchart(y_test_cat, y_pred_cat, 'RowSummary','row-normalized', ...
            'ColumnSummary','column-normalized');

% Assuming bestModel is your trained TreeBagger model
evaluate_model_rf(bestModel, x_train, y_train, 'Training Data');
evaluate_model_rf(bestModel, x_val, y_val, 'Validation Data');
evaluate_model_rf(bestModel, x_test, y_test, 'Test Data');
