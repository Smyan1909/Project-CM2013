function visualEOGfeats = visual_EOG_feature_extraction(eog_segment, Fs)
%VISUAL_EOG_FEATURE_EXTRACTION Summary of this function goes here
%   Detailed explanation goes here
arguments
    eog_segment (1, :) double
    Fs = 50
end

% MinPeakDistance 0.2 = 200 ms, so a decent time it would seem
% MinPeakHeight = 0.12 = 12% of maximum amplitude is taken to be 1 pp less
%   than what is prescribed in Przybyla et al. 2008, where they recommend
%   0.13 of the normalized amplitude of the detection function as the
%   threshold.
blinkPeakVals = findpeaks(eog_segment, Fs, 'MinPeakDistance', 0.2, 'MinPeakHeight', 0.12);
visualEOGfeats = struct( ...
    'blink_count', length(blinkPeakVals) ... % the number of blinks in this epoch
  );
end

