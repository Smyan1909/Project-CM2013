%% Generate Feature Matrix
[feat_mat, sleep_stage_vec] = create_feature_matrix();

%% Save feat_mat and sleep_stage_vec (Optional)
save("ML Solutions/Feature_Matrix.mat")


%% Normalize features

% Detect types
% Example feature matrix dimensions
[numSamples, numFeatures] = size(feat_mat);

% Detect and handle NaN values robustly
for i = 1:numFeatures
    if any(isnan(feat_mat(:, i)))
        feat_mat(isnan(feat_mat(:, i)), i) = median(feat_mat(~isnan(feat_mat(:, i)), i), 'omitnan');
    end
end

% Preallocate logical index arrays for feature types
isBinary = false(1, numFeatures);
isContinuous = true(1, numFeatures);  % Assume all features are continuous by default
percentageColumns = [16, 18, 20, 22, 57, 59, 61, 63]; % Columns that are percentage values

% Update continuous feature identifier to exclude percentage columns
isContinuous(percentageColumns) = false; % These are not treated as standard continuous features

% Detect types for binary and adjust continuous accordingly
for i = 1:numFeatures
    uniqueVals = unique(feat_mat(:, i));
    if length(uniqueVals) == 2 && all(uniqueVals == [0; 1])
        isBinary(i) = true;
        isContinuous(i) = false;  % Not continuous if it's binary
    end
end

% Initialize the normalized matrix
normalizedfeat_mat = zeros(size(feat_mat));

% Normalize percentage columns by dividing by 100
normalizedfeat_mat(:, percentageColumns) = feat_mat(:, percentageColumns) / 100;

% Z-score standardization for other continuous features
for i = find(isContinuous)
    meanVal = mean(feat_mat(:, i));
    stdDev = std(feat_mat(:, i));
    normalizedfeat_mat(:, i) = (feat_mat(:, i) - meanVal) / stdDev;
end

% Copy binary features directly
normalizedfeat_mat(:, isBinary) = feat_mat(:, isBinary);

%% Split the data into training data and test data by dividing for after patient 8
x_train = normalizedfeat_mat(1:(numSamples - (1085+1083)),:);
y_train = sleep_stage_vec(1:(numSamples - (1085+1083)));

x_test = normalizedfeat_mat(((numSamples - (1085+1083))+1):numSamples, :);
y_test = sleep_stage_vec(((numSamples - (1085+1083))+1):numSamples);
%% Train the model
template = templateSVM('KernelFunction', 'rbf', 'KernelScale', 'auto', 'BoxConstraint', 1, 'Standardize', true);
SVMModel = fitcecoc(x_train, y_train, 'Learners', template, 'Coding', 'onevsall', 'Verbose',2);
%% Test the model
y_pred = predict(SVMModel, x_test);
accuracy = sum(y_pred == y_test) / numel(y_test);
fprintf('Accuracy: %.2f%%\n', accuracy * 100);

y_pred = categorical(y_pred, [0,2,3,4,5], {'REM','N3','N2','N1','Wake'});
y_test = categorical(y_test, [0,2,3,4,5], {'REM','N3','N2','N1','Wake'});

confusionchart(y_test, y_pred, 'RowSummary','row-normalized', ...
            'ColumnSummary','column-normalized')