function accuracy = validate_model_rf(model, x_val, y_val)
    [valPredictions, ~] = predict(model, x_val);
    %valPredictions = str2double(valPredictions);  % Ensure matching data types
    accuracy = sum(valPredictions == y_val) / length(y_val);  % Calculate accuracy
end