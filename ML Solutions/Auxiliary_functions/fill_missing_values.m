function data = fill_missing_values(data)
    %% Fill missing values in the dataset
    [numSamples, numFeatures] = size(data);

    for i = 1:numFeatures
        if any(isnan(data(:, i)))
            data(isnan(data(:, i)), i) = median(data(~isnan(data(:, i)), i), 'omitnan');
        end
    end
end