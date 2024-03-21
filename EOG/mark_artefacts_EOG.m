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
    for epochNum = 0:(size(marks, 2) - 1)
        % Beware trickery with 0 and 1-based indexing, which must be
        % constantly interchanged here.
        epochRange = (1 + epochNum * epochSampleLen) : ((epochNum + 1) * epochSampleLen - 1);
        if marks(sigNum, epochNum + 1)
            markedSignal(sigNum, epochRange) = NaN;
        end
    end

end

end
