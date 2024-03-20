function markedSignal = mark_artefacts_EOG(signal, fs)
%DETECT_ARTEFACTS_EOG Summary of this function goes here
%   Detailed explanation goes here
arguments
    signal (:,:) double
    fs double = 50 % Our dataset has a 50 Hz sampling rate for EOG signals.
end

epochSampleLen = fs * 30; % Work on 30 s epochs, in line with AASM manual.
markedSignal = signal;

marks = tabulate_artefacts_EOG(signal, fs, true);

for sigNum = 1:size(signal, 1)
    channelData = signal(sigNum, :);
    for epochNum = 1:length(marks)
        sigptr = 1:epochSampleLen:length(signal)
        if TODO
            markedSignal(sigNum, sigptr:(sigptr + epochSampleLen)) = NaN;
        end
    end

end

end
