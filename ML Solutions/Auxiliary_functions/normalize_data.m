function [train_data, val_data, test_data] = normalize_data(train_data, val_data, test_data)
    % Function to normalize training, validation, and test data sets based on training data statistics
    
    % Get feature count from training data
    [trainSamples, numFeatures] = size(train_data);
    
    % Preallocate logical index arrays for feature types
    isBinary = false(1, numFeatures);
    isContinuous = true(1, numFeatures);  % Assume all features are continuous by default
    percentageColumns = [16, 18, 20, 22, 57, 59, 61, 63]; % Columns that are percentage values
    
    % Update continuous feature identifier to exclude percentage columns
    isContinuous(percentageColumns) = false; % These are not treated as standard continuous features
    
    % Detect types for binary and adjust continuous accordingly in training data
    for i = 1:numFeatures
        uniqueVals = unique(train_data(:, i));
        if length(uniqueVals) == 2 && all(uniqueVals == [0; 1])
            isBinary(i) = true;
            isContinuous(i) = false;  % Not continuous if it's binary
        end
    end
    
    % Normalize each dataset
    train_data = normalize_features(train_data, train_data, isContinuous, isBinary, percentageColumns);
    val_data = normalize_features(val_data, train_data, isContinuous, isBinary, percentageColumns);
    test_data = normalize_features(test_data, train_data, isContinuous, isBinary, percentageColumns);
end
