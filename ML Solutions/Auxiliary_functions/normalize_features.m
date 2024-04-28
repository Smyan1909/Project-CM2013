function data = normalize_features(data, train_data, isContinuous, isBinary, percentageColumns)
    % Function to apply normalization to a dataset based on training data statistics
    
    % Initialize the normalized matrix
    normalized_data = zeros(size(data));
    
    % Normalize percentage columns by dividing by 100
    normalized_data(:, percentageColumns) = data(:, percentageColumns) / 100;
    
    % Z-score standardization for other continuous features using training data parameters
    for i = find(isContinuous)
        meanVal = mean(train_data(:, i));
        stdDev = std(train_data(:, i));
        normalized_data(:, i) = (data(:, i) - meanVal) / stdDev;
    end
    
    % Copy binary features directly
    normalized_data(:, isBinary) = data(:, isBinary);
    
    % Return the normalized dataset
    data = normalized_data;
end