%% Generate Feature Matrix
[feat_mat, sleep_stage_vec] = create_feature_matrix();

%% Normalize features

[normalizedfeat_mat, numSamples] = create_normalized_matrix(feat_mat);

%% Feature selection using anova

normalizedfeat_mat = feature_selection(normalizedfeat_mat, sleep_stage_vec, 60);

%% Split the data into training data and test data by dividing for after patient 8
x_train = normalizedfeat_mat(1:(numSamples - (1085+1083)),:);
y_train = sleep_stage_vec(1:(numSamples - (1085+1083)));

x_test = normalizedfeat_mat(((numSamples - (1085+1083))+1):numSamples, :);
y_test = sleep_stage_vec(((numSamples - (1085+1083))+1):numSamples);

%% Alternative randomly keep 20% of data as test data
% Number of observations
numObservations = size(normalizedfeat_mat, 1);

% Create a random partition of data into training and test sets (80%-20%)
c = cvpartition(numObservations, 'HoldOut', 0.20);

% Indices for training and test sets
trainIdx = training(c);
testIdx = test(c);

% Create training data
x_train = normalizedfeat_mat(trainIdx, :);
y_train = sleep_stage_vec(trainIdx);

% Create test data
x_test = normalizedfeat_mat(testIdx, :);
y_test = sleep_stage_vec(testIdx);
%% Train the KNN model
% Setup cross-validation for parameter tuning
bestK = 1;
bestAcc = 0;
for k = 1:20  % Test different k values
    knnModel = fitcknn(x_train, y_train, 'NumNeighbors', k, 'CrossVal', 'on');
    cvAcc = 1 - kfoldLoss(knnModel, 'LossFun', 'ClassifError');
    if cvAcc > bestAcc
        bestAcc = cvAcc;
        bestK = k;
    end
end
fprintf('Best K by cross-validation: %d with accuracy: %.2f%%\n', bestK, bestAcc * 100);

% Re-train with the best k
knnModel = fitcknn(x_train, y_train, 'NumNeighbors', bestK);
y_pred = predict(knnModel, x_test);
accuracy = sum(y_pred == y_test) / numel(y_test);
fprintf('Optimized KNN Accuracy: %.2f%%\n', accuracy * 100);
%% Plot the Confusion Matrix
y_pred_cat = categorical(y_pred, [0,2,3,4,5], {'REM','N3','N2','N1','Wake'});
y_test_cat = categorical(y_test, [0,2,3,4,5], {'REM','N3','N2','N1','Wake'});

confusionchart(y_test_cat, y_pred_cat, 'RowSummary','row-normalized', ...
            'ColumnSummary','column-normalized')

