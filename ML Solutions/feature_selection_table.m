function [subsel_tab, feat_pvals] = feature_selection_table(norm_tab, cutoff)
%FEATURE_SELECTION_TABLE selects top numFeatures features using ANOVA
arguments
    norm_tab table
    cutoff double = 0.05
end

feat_pvals = zeros(1, width(norm_tab) - 2);
for i=1:length(feat_pvals)
    p = anova1(norm_tab{:, i}, norm_tab.sleep_stage, 'off');  % 'off' to suppress figures
    feat_pvals(i) = p;
end

% Select features if p value is less than 0.05
feature_idxs = find(feat_pvals < cutoff);
subsel_tab = norm_tab(:, feature_idxs);

end
