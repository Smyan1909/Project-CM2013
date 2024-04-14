function y_categorical = restructure_labels(label_list)
    % Define expected labels
    expected_labels = [0, 1, 2, 3, 4, 5];
    unique_labels = unique(label_list);
    if any(~ismember(unique_labels, expected_labels))
        error('label_list contains unexpected labels.');
    end

    % Create a mapping from numeric labels to string labels with '1' as 'None'
    label_map = containers.Map({0, 1, 2, 3, 4, 5}, {'REM', 'Intermediate', 'N3', 'N2', 'N1', 'Wake'});

    % Convert numeric labels to string labels
    y_labels = arrayfun(@(x) label_map(x), label_list, 'UniformOutput', false);
    
    % Convert to categorical, including 'None'
    y_categorical = categorical(y_labels);
end
