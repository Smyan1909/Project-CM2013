%% Generate Feature Matrix
feat_tab = create_feature_table();
train_valid_patients = [1,2,3,4,5,6,7,8,9];

%% Normalize features
sleep_stage_vec = table2array(feat_tab(:, end-1));
norm_tab = standardize_feature_table(feat_tab);

%% Feature selection using anova

[subsel_tab, feat_pvals] = feature_selection_table(norm_tab, 0.05);


%% Patient based cross validation

fprintf('Setting up patient-based cross-validation...\n');

% Set up the parameter grid
kernels = {'linear', 'rbf', 'polynomial'};
boxConstraints = [0.1, 1, 10];  % Extended range for BoxConstraint
results = struct();
index = 0;

for i = 1:length(kernels)
    kernel = kernels{i};
    for boxConstraint = boxConstraints
        index = index + 1;
        fprintf('Testing configuration %d: Kernel = %s, BoxConstraint = %.2f\n', index, kernel, boxConstraint);
        accuracies = zeros(length(train_valid_patients), 1);

        for j = 1:length(train_valid_patients)
            fprintf('Processing data for patient %d...\n', train_valid_patients(j));
            val_patients = [j];
            train_patients = setdiff(train_valid_patients, val_patients);
            test_patients = [];
            % Splitting the data for training and testing (validation split is not used here)
            [X_train_fold, Y_train_fold, X_valid_fold, Y_valid_fold, ~, ~] = split_data(subsel_tab, sleep_stage_vec, train_patients, val_patients, test_patients);
            %[X_train_fold, X_valid_fold, ~] = preprocess_data(X_train_fold, X_valid_fold, [], true);
            template = templateSVM('KernelFunction', kernel, 'KernelScale', 'auto', ...
                                   'BoxConstraint', boxConstraint, 'Standardize', true);
            svmModel = fitcecoc(X_train_fold, Y_train_fold, 'Learners', template, 'Coding', 'onevsone', ...
                                'Verbose', 1);

            accuracies(j) = validate_model_rf(svmModel, X_valid_fold, Y_valid_fold); 
        end
        
        valAcc = mean(accuracies);
        valVarAcc = var(accuracies);
        stdAcc = std(accuracies);

        results(index).ValidationAccuracy = valAcc;
        results(index).Kernel = kernel;
        results(index).BoxConstraint = boxConstraint;
        results(index).Model = svmModel;
        results(index).StandardDeviation = stdAcc;
        

        fprintf('Configuration %d: Accuracy = %.2f%%\n', index, valAcc*100);
    end
end 
%% Best Configuration based on highest accuracy
[maxAcc, maxIdx] = max([results.ValidationAccuracy]);
bestParams = results(maxIdx);

fprintf('Best configuration: Kernel = %s, BoxConstraint = %.2f, ValidationAccuracy = %.2f%%, StandardDeviation = %.2f%%\n', ...
        bestParams.Kernel, bestParams.BoxConstraint, bestParams.ValidationAccuracy*100, bestParams.StandardDeviation*100);
%% Train the model with all 8 patients 

[x_train, y_train, ~, ~, x_test, y_test] = split_data(subsel_tab, sleep_stage_vec, 1:9,[],[10]);
finalTemplate = templateSVM('KernelFunction', bestParams.Kernel, 'KernelScale','auto',...
    'BoxConstraint', bestParams.BoxConstraint, 'Standardize', true);
finalSVMModel = fitcecoc(x_train, y_train, 'Learners',finalTemplate,'Coding','onevsone', ...
    'Verbose',2);
%% Test the model on the remaining 1 patients
y_pred = predict(finalSVMModel, x_test);
y_pred = medfilt1(double(y_pred), 5);
% Calculate the confusion matrix
confMat = confusionmat(double(y_test), y_pred);

% Initialize arrays to hold precision and recall for each class
numClasses = size(confMat, 1);
precision = zeros(numClasses, 1);
recall = zeros(numClasses, 1);

% Calculate precision and recall for each class
for i = 1:numClasses
    truePositives = confMat(i, i);
    falsePositives = sum(confMat(:, i)) - truePositives;
    falseNegatives = sum(confMat(i, :)) - truePositives;
    
    precision(i) = truePositives / (truePositives + falsePositives);
    recall(i) = truePositives / (truePositives + falseNegatives);
end

% Display precision and recall for each class
classNames = {'REM', 'N3', 'N2', 'N1', 'Wake'};
for i = 1:numClasses
    fprintf('Class %s - Precision: %.2f, Recall: %.2f\n', classNames{i}, precision(i), recall(i));
end


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