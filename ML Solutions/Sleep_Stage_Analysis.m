[feat_mat, sleep_stage_vec] = create_feature_matrix();
sleep_stage_vec(sleep_stage_vec == 1) = 2;

%% Split the data into training data and test data

[x_train, y_train, ~, ~, x_test, y_test] = split_data(feat_mat, sleep_stage_vec, 1:9,[],[10]);

%% Plot the distributions of the sleep stages
y_train = categorical(y_train, [0,2,3,4,5], {'REM', 'N3','N2','N1','Wake'});
y_test = categorical(y_test, [0,2,3,4,5], {'REM', 'N3','N2','N1','Wake'});

%% Plot histogram


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

