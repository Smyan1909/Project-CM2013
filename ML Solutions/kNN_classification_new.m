%% Generate Feature Matrix
feat_tab = create_feature_table();
train_valid_patients = [1,2,3,4,5,6,7,8,9];

%% Normalize features

[normalizedfeat_mat, numSamples] = standardize_feature_table(feat_tab);

%% Feature selection using anova

normalizedfeat_mat = feature_selection(normalizedfeat_mat, sleep_stage_vec);

%% Train the KNN model
% Setup cross-validation for parameter tuning
results = struct();
index = 0;
for k=1:20
        index = index + 1;
        accuracies = zeros(length(train_valid_patients), 1);

        for j = 1:length(train_valid_patients)
            fprintf('Processing data for patient %d...\n', train_valid_patients(j));
            val_patients = [j];
            train_patients = setdiff(train_valid_patients, val_patients);
            test_patients = [];
            % Splitting the data for training and testing (validation split is not used here)
            [X_train_fold, Y_train_fold, X_valid_fold, Y_valid_fold, ~, ~] = split_data(normalizedfeat_mat, sleep_stage_vec, train_patients, val_patients, test_patients);
            %[X_train_fold, X_valid_fold, ~] = preprocess_data(X_train_fold, X_valid_fold, [], true);
            knnModel = fitcknn(X_train_fold, Y_train_fold, "NumNeighbors",k);

            accuracies(j) = validate_model_rf(knnModel, X_valid_fold, Y_valid_fold); 
            
        end

        avgAccuracy = mean(accuracies);
        valVarAcc = var(accuracies);
        results(index).k = k;
        results(index).AccuracyVariance = valVarAcc;
        
        results(index).ValidationAccuracy = avgAccuracy;
        fprintf('K= %d, Acc= %.2f%%', k, avgAccuracy*100);
end
%% choose params
[maxAccuracy, maxIdx] = max([results.ValidationAccuracy]);
bestParams = results(maxIdx);
fprintf("%d\n", bestParams.k)
%% Retrain the model
[x_train, y_train, ~, ~, x_test, y_test] = split_data(feat_mat, sleep_stage_vec, 1:9,[],[10]);

finalKNNModel = fitcknn(x_train, y_train, "NumNeighbors", k);

%% Test on last patient
y_pred = predict(finalKNNModel, x_test);
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



