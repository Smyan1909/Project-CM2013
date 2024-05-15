%% Generate Feature Matrix
[feat_mat, sleep_stage_vec] = create_feature_matrix();
train_valid_patients = [1,2,3,4,5,6,7,8,9];
sleep_stage_vec(sleep_stage_vec == 1) = 2;


%% Normalize features and calculate top 10 anova scores

[normalizedfeat_mat, numSamples] = create_normalized_matrix(feat_mat);

dims = size(normalizedfeat_mat);

p_values = zeros(1, dims(2));

for i = 1:dims(2)
        p = anova1(normalizedfeat_mat(:, i), sleep_stage_vec, 'off');  % 'off' to suppress figures
        p_values(i) = p;
end

[sortedValues, sortedIndices] = sort(p_values, 'ascend');

top10Values = abs(sortedValues(1:10));
top10Indices = sortedIndices(1:10);

bar(1./top10Values)
xlabel('Features');
ylabel('Importance Score');
title('Top 10 Important Features with ANOVA');