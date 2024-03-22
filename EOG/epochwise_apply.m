function table = epochwise_apply(signal, fs, func, outputTable, epochLenOverride)
%epochwise_apply Apply a function that calculates a single value
% to each epoch-channel combination and return the results as an array or
% timetable.
%
%   array = epochwise_apply(signal, fs, func)
%
%   table = epochwise_apply(signal, fs, func, true)
%
%   array_or_table = epochwise_apply(___, epochLenOverride)
%
%   In the first form, generate an array of 
%
%
arguments
    signal (:,:) double
    fs (1, 1) double % Our dataset has a 50 Hz sampling rate for EOG signals.
    func function_handle
    outputTable logical = false
    epochLenOverride int32 = 0
end

if epochLenOverride > 0
    epochSampleLen = epochLenOverride;
else
    epochSampleLen = fs * 30; % Work on 30 s epochs, in line with AASM manual.
end

epochMeasures = NaN([ ...
    size(signal, 1), ...
    floor(length(signal) / epochSampleLen) ...
   ]);

for sigNum = 1:size(signal, 1)
    channelData = signal(sigNum, :);
    for epochNum = 0:(size(epochMeasures, 2) - 1)
        sigRange = (1 + epochNum * epochSampleLen) : ((epochNum + 1) * epochSampleLen - 1);
        epochMeasures(sigNum, epochNum + 1) = func(channelData(sigRange));
    end
end

if outputTable
    table = timetable(epochMeasures', TimeStep=seconds(30));
else
    table = epochMeasures;
end

end