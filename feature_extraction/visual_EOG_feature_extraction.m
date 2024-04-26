function visualEOGfeats = visual_EOG_feature_extraction(eog_segment, Fs)
%VISUAL_EOG_FEATURE_EXTRACTION.M Summary of this function goes here
%   Detailed explanation goes here
arguments
    eog_segment (1, :) double
    Fs = 50
end

blinkPeakVals = findpeaks(eog_segment, Fs, 'MinPeakDistance', 0.2, 'MinPeakHeight', 50, 'Annotate','extents');

visualEOGfeats = struct('blink_count', length(blinkPeakVals));
end

