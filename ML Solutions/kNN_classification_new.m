%% Generate Feature Matrix
feat_tab = create_feature_table();
train_test_patients = [1,2,3,4,5,6,7,8,9];
final_patients = [10];

%% Normalize features

norm_tab = standardize_feature_table(feat_tab);

%% Feature selection using anova

[subsel_tab, feat_pvals] = feature_selection_table(norm_tab, 0.05);

%% Train the KNN model
% Setup cross-validation for parameter tuning

results = struct();
ks = 1:20;
dist_metrics = string({'chebychev', 'cityblock', 'correlation', 'cosine', 'euclidean', 'hamming', ...
    'jaccard', 'minkowski', 'seuclidean', 'spearman'});
confs = combinations(dist_metrics, ks);

for confNo = 1:height(confs)
    fprintf("Testing configuration %d of %d\n", confNo, height(confs));
    accuracies = zeros(length(train_test_patients), 1);

    for j = 1:length(train_test_patients) % cross-validation in training
        %fprintf('Patient %d is test, all others are train\n', train_test_patients(j));
        test_patients = [train_test_patients(j)];
        train_patients = setdiff(train_test_patients, test_patients);

        % Splitting the data for training and testing (validation split is not used here)
        

        X_train_fold = subsel_tab(subsel_tab.patient_ID ~= test_patients(1), 1:end-2);
        Y_train_fold = subsel_tab.sleep_stage(subsel_tab.patient_ID ~= test_patients(1));

        knnModel = fitcknn(X_train_fold, Y_train_fold, ...
            "NumNeighbors", confs.ks(confNo), ...
            "Distance", confs.dist_metrics(confNo) ...
        );

        X_test_fold = subsel_tab(subsel_tab.patient_ID == test_patients(1), 1:end-2);
        Y_test_fold = subsel_tab.sleep_stage(subsel_tab.patient_ID == test_patients(1));
        
        pred_labels = predict(knnModel, X_test_fold);
        accuracies(j) = mean(pred_labels == Y_test_fold);
    end

    results(confNo).k = confs.ks(confNo);
    results(confNo).Accuracy = mean(accuracies);
    results(confNo).AccuracyVariance = var(accuracies);  
    %fprintf('K= %d, Acc= %.2f%%\n', k, avgAccuracy*100);
end

result_tab = struct2table(results);
result_tab.index = transpose(1:height(result_tab));
%% choose params

result_tab_by_acc = sortrows(result_tab, "Accuracy", "descend");
confNo_optimal = result_tab_by_acc.index(1);
best_params = table2struct(confs(confNo_optimal, :));

%% Retrain the model
final_fold_train = subsel_tab(~ismember(subsel_tab.patient_ID, final_patients), :);

final_kNN_model = fitcknn( ...
    final_fold_train(:, 1:end-2), ...
    final_fold_train.sleep_stage, ...
    "NumNeighbors", best_params.ks, ...
    "Distance", best_params.dist_metrics ...
    );

%% Test on last patient
final_fold_test = subsel_tab(ismember(subsel_tab.patient_ID, final_patients), :);

final_y_pred = predict(final_kNN_model, final_fold_test(:, 1:end-2));
[final_y_pred_sus, final_y_pred] = classify_suspect_stages(y_pred);

final_y_true = final_fold_test.sleep_stage;
accuracy = mean(final_y_pred == final_y_true);
fprintf('Final accuracy: %.2f%%\n', accuracy * 100);

%%
y_pred_cat = categorical(final_y_pred, [0,2,3,4,5], {'REM','N3','N2','N1','Wake'});
y_true_cat = categorical(final_y_true, [0,2,3,4,5], {'REM','N3','N2','N1','Wake'});

figure
confusionchart(y_true_cat, y_pred_cat, 'RowSummary','row-normalized', ...
           'ColumnSummary','column-normalized')

figure
plot(((1:length(final_y_true)))./2,y_true_cat)
hold on
plot(((1:length(final_y_pred)))./2,y_pred_cat)
legend({"Annotated Data", "Predicted Data"})
xlabel("Time [min]")
ylabel("Sleep Stage")



