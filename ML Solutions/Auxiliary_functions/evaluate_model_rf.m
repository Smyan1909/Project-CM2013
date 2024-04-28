function evaluate_model_rf(model, x_data, y_data, dataSetName)
    % Predict on the provided data set
    [y_pred, ~] = predict(model, x_data);
    y_pred = str2double(y_pred);
    accuracy = sum(y_pred == y_data) / length(y_data) * 100;
    fprintf('%s Accuracy: %.2f%%\n', dataSetName, accuracy);

    % Check if OOB prediction was enabled and calculate feature importance
    if model.ComputeOOBPrediction
        % Get feature importance scores
        featureImportance = model.OOBPermutedPredictorDeltaError;

        % Display feature importance
        fprintf('\nFeature Importance Scores for %s:\n', dataSetName);
        disp(featureImportance);
        
        % Sort feature importance scores in descending order
        [sortedImportance, sortIndex] = sort(featureImportance, 'descend');

        % Limit the number of features to show
        %numFeaturesToShow = length(sortedImportance); % Change if you want to show less features
        numFeaturesToShow = 10;
        sortedImportance = sortedImportance(1:numFeaturesToShow);
        sortedLabels = model.PredictorNames(sortIndex(1:numFeaturesToShow));

        % Plotting sorted feature importance
        figure;
        bar(sortedImportance);
        title(sprintf('Top %d Feature Importance Scores: %s', numFeaturesToShow, dataSetName));
        xlabel('Features');
        ylabel('Importance Score');
        grid on;
        set(gca, 'XTick', 1:numFeaturesToShow);
        set(gca, 'XTickLabel', sortedLabels);
        xtickangle(45);
    else
        error('OOB prediction was not enabled. Feature importance cannot be calculated.');
    end

    % Confusion matrix
    y_pred_cat = categorical(y_pred, [0,2,3,4,5], {'REM','N3','N2','N1','Wake'});
    y_data_cat = categorical(y_data, [0,2,3,4,5], {'REM','N3','N2','N1','Wake'});
    figure;
    confusionchart(y_data_cat, y_pred_cat, 'RowSummary','row-normalized', ...
                'ColumnSummary','column-normalized');
end
