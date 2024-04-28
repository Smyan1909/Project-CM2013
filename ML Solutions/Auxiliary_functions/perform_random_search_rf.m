function [bestModel, bestParams, bestAccuracy] = perform_random_search_rf(x_train, y_train, x_val, y_val, numTrials, validationBased)

    % Constants and Initial Setup
    numFeatures = size(x_train, 2);
    numTreesOptions = [100, 200, 300, 400, 500];
    maxNumSplitsOptions = [20, 40, 60, 80, 100];
    minLeafSizeOptions = [1, 5, 10, 20];
    numPredictorsToSampleOptions = [ceil(sqrt(numFeatures)), ceil(numFeatures/2), numFeatures];  % Corresponds to 'NumPredictorsToSample' (like 'max_features' in Python)

    fprintf('Starting random search for Random Forest parameters over %d trials...\n', numTrials);

    bestAccuracy = 0;
    bestModel = [];
    bestParams = [];

    for i = 1:numTrials
        fprintf('\nTrial %d/%d:\n', i, numTrials);

        % Randomly select parameter values
        nTrees = randsample(numTreesOptions, 1);
        maxNumSplits = randsample(maxNumSplitsOptions, 1);
        minLeafSize = randsample(minLeafSizeOptions, 1);
        numPredictorsToSample = randsample(numPredictorsToSampleOptions, 1);

        fprintf('Selected parameters - Trees: %d, MaxSplits: %d, LeafSize: %d, Predictors: %d\n', nTrees, maxNumSplits, minLeafSize, numPredictorsToSample);

        % Train the Random Forest model
        fprintf('Training the model...\n');
        model = TreeBagger(nTrees, x_train, y_train, 'Method', 'classification', ...
                           'OOBPrediction', 'On', 'MinLeafSize', minLeafSize, ...
                           'MaxNumSplits', maxNumSplits, 'NumPredictorsToSample', numPredictorsToSample);
        
        % Evaluate the model
        if validationBased
            accuracy = validate_model_rf(model, x_val, y_val);
            fprintf('Validation-based accuracy for this trial: %.4f\n', accuracy);
        else
            accuracy = 1 - oobError(model, 'last');
            fprintf('OOB-based accuracy for this trial: %.4f\n', accuracy);
        end

        % Update the best model if the current model is better
        if accuracy > bestAccuracy
            bestAccuracy = accuracy;
            bestModel = model;
            bestParams = struct('nTrees', nTrees, 'maxNumSplits', maxNumSplits, ...
                                'minLeafSize', minLeafSize, 'numPredictorsToSample', numPredictorsToSample);
            fprintf('New best model found with accuracy: %.4f\n', bestAccuracy);
        end
    end

    fprintf('\nBest model parameters found:\n');
    fprintf('Trees: %d, MaxSplits: %d, LeafSize: %d, Predictors: %d\n', bestParams.nTrees, bestParams.maxNumSplits, bestParams.minLeafSize, bestParams.numPredictorsToSample);
    fprintf('Best accuracy achieved: %.4f\n', bestAccuracy);
end
