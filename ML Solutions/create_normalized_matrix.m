function [normalizedfeat_mat, numSamples] = create_normalized_matrix(feat_mat)
    % This function creates a normalized feature matrix
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
end

