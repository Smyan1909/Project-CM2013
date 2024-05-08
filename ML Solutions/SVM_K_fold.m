%% Generate Feature Matrix
[feat_mat, sleep_stage_vec] = create_feature_matrix();
train_valid_patients = [1,2,3,4,5,6,7,8,9];
sleep_stage_vec(sleep_stage_vec == 1) = 2;


%% Normalize features

[normalizedfeat_mat, numSamples] = create_normalized_matrix(feat_mat);
%% Feature Selection Using ANOVA

normalizedfeat_mat = feature_selection(normalizedfeat_mat, sleep_stage_vec);

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
            [X_train_fold, Y_train_fold, X_valid_fold, Y_valid_fold, ~, ~] = split_data(normalizedfeat_mat, sleep_stage_vec, train_patients, val_patients, test_patients);
            %[X_train_fold, X_valid_fold, ~] = preprocess_data(X_train_fold, X_valid_fold, [], true);
            template = templateSVM('KernelFunction', kernel, 'KernelScale', 'auto', ...
                                   'BoxConstraint', boxConstraint, 'Standardize', true);
            svmModel = fitcecoc(X_train_fold, Y_train_fold, 'Learners', template, 'Coding', 'onevsone', ...
                                'Verbose', 1);

            accuracies(j) = validate_model_rf(svmModel, X_valid_fold, Y_valid_fold); 
        end
        
        valAcc = mean(accuracies);

        results(index).ValidationAccuracy = valAcc;
        results(index).Kernel = kernel;
        results(index).BoxConstraint = boxConstraint;
        results(index).Model = svmModel;
        

        fprintf('Configuration %d: Accuracy = %.2f%%\n', index, valAcc*100);
    end
end 
%% Best Configuration based on highest accuracy
[maxAcc, maxIdx] = max([results.ValidationAccuracy]);
bestParams = results(maxIdx);

fprintf('Best configuration: Kernel = %s, BoxConstraint = %.2f, ValidationAccuracy = %.2f%%\n', ...
        bestParams.Kernel, bestParams.BoxConstraint, bestParams.ValidationAccuracy*100);
%% Train the model with all 8 patients 

[x_train, y_train, ~, ~, x_test, y_test] = split_data(normalizedfeat_mat, sleep_stage_vec, 1:9,[],[10]);
finalTemplate = templateSVM('KernelFunction', bestParams.Kernel, 'KernelScale','auto',...
    'BoxConstraint', bestParams.BoxConstraint, 'Standardize', true);
finalSVMModel = fitcecoc(x_train, y_train, 'Learners',finalTemplate,'Coding','onevsone', ...
    'Verbose',2);
%% Test the model on the remaining 1 patients
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