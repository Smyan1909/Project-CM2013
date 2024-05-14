function norm_tab = standardize_feature_table(feat_tab)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

isPercent = contains(feat_tab.Properties.VariableNames(1:end-2), "percent");
isBinary = false(1, length(isPercent));

for i=1:width(feat_tab)-2
    isBinary(i) = all(feat_tab{:, i} == true | feat_tab{:, i} == false);
end

whichToNormalize = ~isPercent & ~isBinary;
toNormalizeCols = find(whichToNormalize);

norm_tab = table();
for i=1:width(feat_tab)
    norm_tab.(feat_tab.Properties.VariableNames{i}) = feat_tab{:, i};
end

for i=toNormalizeCols
    norm_tab(:, i) = (norm_tab(:, i) - mean(norm_tab(:, i))) ./ std(norm_tab(:, i));
end

for i=find(isPercent)
    norm_tab(:, i) = norm_tab(:, i) ./ 100;
end

end
