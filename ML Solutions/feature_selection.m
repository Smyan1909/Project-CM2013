function cleaned_feature_matrix = feature_selection(normalizedfeat_mat, sleep_stage_vec, numFeatures)
%FEATURE_SELECTION selects top numFeatures features using ANOVA
    dims = size(normalizedfeat_mat);
    p_values = zeros(1, dims(2));
    for i = 1:dims(2)
        p = anova1(normalizedfeat_mat(:, i), sleep_stage_vec, 'off');  % 'off' to suppress figures
        p_values(i) = p;
    end
    
    % Select top 60 features based on the smallest p-values
    [~, feature_idx] = mink(p_values, numFeatures);
    cleaned_feature_matrix = normalizedfeat_mat(:, feature_idx);
        

end

