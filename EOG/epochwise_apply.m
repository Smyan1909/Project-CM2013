function table = epochwise_apply(signal, fs, func, outputArray, epochLenOverride)
%tabulate_artefacts_EOG Generate a table (or an array) listing epochs where
%artefacts have been found. Intended for use with EOG signal channels.
%
%   table = tabulate_artefacts_EOG(signal)
%
%   table = tabulate_artefacts_EOG(signal, fs)
%
%   table = tabulate_artefacts_EOG(signal, fs, outputArray)
arguments
    signal (:,:) double
    fs double % Our dataset has a 50 Hz sampling rate for EOG signals.
    func function_handle
    outputArray logical = false
    epochLenOverride int32 = 0
end

if epochLenOverride > 0
    epochSampleLen = epochLenOverride;
else
    epochSampleLen = fs * 30; % Work on 30 s epochs, in line with AASM manual.
end

artefactMarks = false([ ...
    size(signal, 1), ...
    floor(length(signal) / epochSampleLen) ...
   ]);

for sigNum = 1:size(signal, 1)
    channelData = signal(sigNum, :);
    for epochNum = 0:(size(artefactMarks, 2) - 1)
        sigRange = (1 + epochNum * epochSampleLen) : ((epochNum + 1) * epochSampleLen - 1);
        artefactMarks(sigNum, epochNum + 1) = is_artefact_EOG_epchan(channelData(sigRange));
    end
end

if outputArray
    table = artefactMarks;
else
    table = timetable(artefactMarks', TimeStep=seconds(30));
end

end