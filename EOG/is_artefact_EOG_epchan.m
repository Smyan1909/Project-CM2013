function isartefact = is_artefact_EOG_epchan(epochChan, threshLow, threshHigh)
arguments
    epochChan (1,:) double
    threshLow = 2
    threshHigh = 80
end
% So far this is a trivial threshold algorithm, but the function may be
% substituted with something more sophisticated as necessary.
measure = rms(epochChan);
isartefact = (threshLow <= measure) && (threshHigh > measure);
end
