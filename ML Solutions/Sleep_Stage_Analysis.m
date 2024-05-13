[feat_mat, sleep_stage_vec] = create_feature_matrix();
sleep_stage_vec(sleep_stage_vec == 1) = 2;

%% Split the data into training data and test data

[x_train, y_train, ~, ~, x_test, y_test] = split_data(feat_mat, sleep_stage_vec, 1:9,[],[10]);

%% Plot the distributions of the sleep stages
y_train = categorical(y_train, [0,2,3,4,5], {'REM', 'N3','N2','N1','Wake'});
y_test = categorical(y_test, [0,2,3,4,5], {'REM', 'N3','N2','N1','Wake'});

%% Plot histogram
fprintf("REM_train = %d\n", length(y_train(y_train == 'REM')))
fprintf("N3_train = %d\n", length(y_train(y_train == 'N3')))
fprintf("N2_train = %d\n", length(y_train(y_train == 'N2')))
fprintf("N1_train = %d\n", length(y_train(y_train == 'N1')))
fprintf("Wake_train = %d\n", length(y_train(y_train == 'Wake')))

fprintf("\n\n\n")

fprintf("REM_test = %d\n", length(y_test(y_test == 'REM')))
fprintf("N3_test = %d\n", length(y_test(y_test == 'N3')))
fprintf("N2_test = %d\n", length(y_test(y_test == 'N2')))
fprintf("N1_test = %d\n", length(y_test(y_test == 'N1')))
fprintf("Wake_test = %d\n", length(y_test(y_test == 'Wake')))

figure
subplot(2,1,1)
histogram(y_train);
title("Distribution of sleep stages")
ylabel("Count")
xlabel("Stages")
legend({'Training Data'})
subplot(2,1,2)
histogram(y_test,'FaceColor', "r");
ylabel("Count")
xlabel("Stages")
legend({'Test Data'})

