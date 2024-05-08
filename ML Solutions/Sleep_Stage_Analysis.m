[feat_mat, sleep_stage_vec] = create_feature_matrix();
train_valid_patients = [1,2,3,4,5,6,7,8,9];

%% Split the data into training data and test data

[x_train, y_train, ~, ~, x_test, y_test] = split_data(feat_mat, sleep_stage_vec, 1:9,[],[10]);

%% Plot the distributions of the sleep stages
y_train = categorical(y_train, [0,1,2,3,4,5], {'REM','"N4"', 'N3','N2','N1','Wake'});
y_test = categorical(y_test, [0,1,2,3,4,5], {'REM','"N4"', 'N3','N2','N1','Wake'});

%% Plot histogram


figure
histogram(y_train);

figure
histogram(y_test,'FaceColor', "r");
