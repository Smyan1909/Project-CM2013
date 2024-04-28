function [train_data, val_data, test_data] = preprocess_data(train_data, val_data, test_data, varargin)
    %% This function preprocesses data by filling in the missing values and optionally normalizing
    
    % Fill missing values for training, validation, and testing data
    train_data = fill_missing_values(train_data);
    val_data = fill_missing_values(val_data);
    test_data = fill_missing_values(test_data);

    % Check for normalization flag
    if nargin < 4  % If the number of input arguments is less than 4, default to true
        normalize = true;
    else
        normalize = varargin{1};
    end

    % Normalize data if normalize is true
    if normalize
        [train_data, val_data, test_data] = normalize_data(train_data, val_data, test_data);
    end
end
