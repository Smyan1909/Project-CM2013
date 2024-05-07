%% Generate Feature Matrix
[feat_mat, sleep_stage_vec] = create_feature_matrix();


%% Normalize features

[normalizedfeat_mat, numSamples] = create_normalized_matrix(feat_mat);
%% Feature Selection Using ANOVA

normalizedfeat_mat = feature_selection(normalizedfeat_mat, sleep_stage_vec);
%% Split the data into training data and test data by dividing for after patient 8
x_train = normalizedfeat_mat(1:(numSamples - (1085+1083)),:); % 1085
y_train = sleep_stage_vec(1:(numSamples - (1085+1083)));

x_test = normalizedfeat_mat(((numSamples - (1085+1083))+1):numSamples, :);
y_test = sleep_stage_vec(((numSamples - (1085+1083))+1):numSamples);
%% Alternative way to split the data into training and test data by randomly holding out 20% of the data
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

%% Cross validation for hyperparameter selection for SVM model
% Set up the parameter grid
kernels = {'linear', 'rbf', 'polynomial'};
boxConstraints = [0.1, 1, 10];  % Extended range for BoxConstraint

k = 10; % Number of folds for cross-validation
cvp = cvpartition(y_train, 'KFold', k);

%% Cross-Validation Execution with BoxConstraint Search
results = struct();
index = 0;

for i = 1:length(kernels)
    kernel = kernels{i};
    for boxConstraint = boxConstraints
        index = index + 1;
        fprintf('Testing configuration %d: Kernel = %s, BoxConstraint = %.2f\n', index, kernel, boxConstraint);

        template = templateSVM('KernelFunction', kernel, 'KernelScale', 'auto', ...
                               'BoxConstraint', boxConstraint, 'Standardize', true);
        svmModel = fitcecoc(x_train, y_train, 'Learners', template, 'Coding', 'onevsone', ...
                            'CVPartition', cvp, 'Verbose', 1);

        % Assess the model
        loss = kfoldLoss(svmModel, 'LossFun', 'ClassifError');
        validationPredictions = kfoldPredict(svmModel);
        % Calculate validation accuracy
        validationAccuracy = sum(validationPredictions == y_train) / numel(y_train) * 100;
        
        results(index).Kernel = kernel;
        results(index).BoxConstraint = boxConstraint;
        results(index).Loss = loss;
        results(index).Model = svmModel;
        results(index).ValidationAccuracy = validationAccuracy;

        fprintf('Configuration %d: Loss = %.2f%%, Accuracy = %.2f%%\n', index, loss * 100, validationAccuracy);
    end
end

%% Identify the Best Configuration Based on Minimum Loss
losses = arrayfun(@(s) s.Loss, results);
[minLoss, minIdx] = min(losses);
bestParams = results(minIdx);

fprintf('Best configuration: Kernel = %s, BoxConstraint = %.2f, Loss = %.2f%%, Accuracy = %.2f%%\n', ...
        bestParams.Kernel, bestParams.BoxConstraint, minLoss * 100, bestParams.ValidationAccuracy);

%% Train the Final Model on Full Training Data Using the Best Parameters
finalTemplate = templateSVM('KernelFunction', bestParams.Kernel, 'KernelScale', 'auto', ...
                            'BoxConstraint', bestParams.BoxConstraint, 'Standardize', true);
finalSVMModel = fitcecoc(x_train, y_train, 'Learners', finalTemplate, 'Coding', 'onevsone', 'Verbose', 2);

%% Train the model (without cross validation for comparison)
template = templateSVM('KernelFunction', 'rbf', 'KernelScale', 'auto', 'BoxConstraint', 1, 'Standardize', true);
SVMModel = fitcecoc(x_train, y_train, 'Coding', 'onevsone', 'Verbose',2, 'OptimizeHyperparameters','auto');

%% Test the model
y_pred = predict(finalSVMModel, x_test);
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
%% Training the best model on and testing on all patients
%number_of_rows = (1084+1079+1049+875+1084+1084+919+959+1086+1084) - 10;
full_epochList = {1:1083, 1083:(1083+1078), (1083+1078):(1083+1078+1048), ... 
            (1083+1078+1048):(1083+1078+1048+874), (1083+1078+1048+874):(1083+1078+1048+874+1083), ...
            (1083+1078+1048+874+1083):(1083+1078+1048+874+1083+1083), ...
            (1083+1078+1048+874+1083+1083):(1083+1078+1048+874+1083+1083+918), ...
            (1083+1078+1048+874+1083+1083+918):(1083+1078+1048+874+1083+1083+918+958), ...
            (1083+1078+1048+874+1083+1083+918+958):(1083+1078+1048+874+1083+1083+918+958+1085), ...
            (1083+1078+1048+874+1083+1083+918+958+1085):(1083+1078+1048+874+1083+1083+918+958+1085+1083)};

[numSamples, numFeatures] = size(normalizedfeat_mat);
epoch_vec = 1:numSamples;

epochList = full_epochList(1:8); %Change this number to chose which patients to validate against

acc_arr = [];

for i=1:length(epochList)
    keepIndices = true(1, length(epoch_vec));
    keepIndices(epochList{i}) = false;
    x_train = normalizedfeat_mat(keepIndices,:); 
    y_train = sleep_stage_vec(keepIndices);
    
    x_test = normalizedfeat_mat(keepIndices==false, :);
    y_test = sleep_stage_vec(keepIndices==false);

    
    finalSVMModel = fitcecoc(x_train, y_train, 'Learners', finalTemplate, 'Coding', 'onevsone', 'Verbose', 2);
    
    y_pred = predict(finalSVMModel, x_test);
    y_pred = medfilt1(y_pred, 5);
    
    accuracy = sum(y_pred == y_test) / numel(y_test);
    fprintf('Accuracy: %.2f%%\n', accuracy * 100);

    acc_arr = [acc_arr, accuracy];
    
end

fprintf('Maximum Accuracy: %.2f%%\n',max(acc_arr)*100)
fprintf('Minimum Accuracy: %.2f%%\n',min(acc_arr)*100)
fprintf('Mean Accuracy: %.2f%%\n',mean(acc_arr)*100)

%% LOO validation testing with 8 patients used for validation and one patient used for testing
x_train = normalizedfeat_mat(1:(numSamples - (1085+1083)),:); % 1085
y_train = sleep_stage_vec(1:(numSamples - (1085+1083)));

x_test = normalizedfeat_mat(((numSamples - (1085+1083))+1):numSamples, :);
y_test = sleep_stage_vec(((numSamples - (1085+1083))+1):numSamples);

finalSVMModel = fitcecoc(x_train, y_train, 'Learners', finalTemplate, 'Coding', 'onevsone', 'Verbose', 2);

y_pred = predict(finalSVMModel, x_test);
y_pred = medfilt1(y_pred, 5);

accuracy = sum(y_pred == y_test) / numel(y_test);
fprintf('Accuracy: %.2f%%\n', accuracy * 100);

y_pred_cat = categorical(y_pred, [0,2,3,4,5], {'REM','N3','N2','N1','Wake'});
y_test_cat = categorical(y_test, [0,2,3,4,5], {'REM','N3','N2','N1','Wake'});

figure
confusionchart(y_test_cat, y_pred_cat, 'RowSummary','row-normalized', ...
           'ColumnSummary','column-normalized')


%% K-Fold Cross Validation for model performance assessment
SVM_crossval = fitcecoc(normalizedfeat_mat, sleep_stage_vec, 'Learners', finalTemplate, 'Coding', 'onevsone', 'Verbose', 2, ...
                        'CrossVal', 'on', 'KFold', 10);
cv_loss = kfoldLoss(SVM_crossval);
fprintf('10-fold cross-validation loss: %.2f%%\n', cv_loss * 100);
cv_predict = kfoldPredict(SVM_crossval);
cv_accuracy = sum(cv_predict == sleep_stage_vec) / numel(sleep_stage_vec);
fprintf('cross_validation accuracy: %.2f%%\n', cv_accuracy * 100);