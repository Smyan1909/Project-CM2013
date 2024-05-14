% Consolidate patient data from multiple Feature_Extracted_Data.mat files
% containing Patient_Data with different R-numbers.
% Works greedily, i.e. data from the first MAT file containing a
% 'Patient_Data' struct with the given R-number will be included and all
% other data will be discarded.

filenames = {'Feature_Extracted_Data_1.mat', 'Feature_Extracted_Data_2.mat'};
filecontents = {};

for i=1:numel(filenames)
    filecontents{i} = load(filenames{i});
end

consol_data = struct();
for i=1:10
    rcode = sprintf('R%d', i);
    fprintf("consolidate_Patient_Data : focusing on %s", rcode); % info messages
    for j=1:numel(filecontents)
        struct_to_search = filecontents{j}.Patient_Data;
        if isfield(struct_to_search, rcode)
            consol_data.(rcode) = struct_to_search.(rcode);
            break; % Greediness (stop searching after matching)
        end
    end
    if ~isfield(consol_data, rcode) % verification
        warning("failed to match %s among provided structures to consolidate, recording features not copied", rcode);
    end
end

Patient_Data = consol_data; % renaming necessary due to how MATLAB's save() works
save("Feature_Extracted_Data.mat", "Patient_Data", "-v7.3");