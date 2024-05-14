function feat_table = create_feature_table(mat_filename_to_load_or_struct, fix_stage_1)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
arguments
    mat_filename_to_load_or_struct = "Feature_Extracted_Data.mat"
    fix_stage_1 logical = true; % Whether to automatically replace outdated (S3, S4 = N3) sleep stages in sleep_stage_vec.
end
[feat_mat, sleep_stage_vec, feat_names, patientIDs] = create_feature_matrix(mat_filename_to_load_or_struct, fix_stage_1);

feat_table = array2table(feat_mat, "VariableNames", feat_names);
feat_table.sleep_stage = sleep_stage_vec;
feat_table.patient_ID = patientIDs;
end
