function cleaned_feature_matrix = feature_selection(normalizedfeat_mat, sleep_stage_vec)
%FEATURE_SELECTION selects top numFeatures features using ANOVA
    dims = size(normalizedfeat_mat);
    p_values = zeros(1, dims(2));
    for i = 1:dims(2)
        p = anova1(normalizedfeat_mat(:, i), sleep_stage_vec, 'off');  % 'off' to suppress figures
        p_values(i) = p;
    end
    
    % Select Features if p value is less than 0.05
    feature_idx = find(p_values < 0.05);
    cleaned_feature_matrix = normalizedfeat_mat(:, feature_idx);
        

end

