function [header_or_samples, record] = load_EOG_ROI(sampleNo)
%LOAD_EOG_BAD Convenience function to load examples of bad EOG signal.
%   Detailed explanation goes here
nargoutchk(1, 2);

exampleTab = readtable('EventAnnots\EOG_annots_2024-03-16.tsv', ...
    'FileType','text', 'Delimiter','\t','TreatAsMissing',{'NaN','NA',''} ...
    );

exampleRec = exampleTab(sampleNo, :);

[headerLoad, recordLoad] = edfread(strcat('Project Data (modified dates)/', ...
    exampleRec.FileName{1}));


fs = headerLoad.samples(exampleRec.Channel) / headerLoad.duration;



if ~isnan(exampleRec.EndSec) && isnan(exampleRec.Duration)
    signalWindow = fix([exampleRec.StartSec, exampleRec.EndSec] * fs);
elseif isnan(exampleRec.EndSec) && ~isnan(exampleRec.Duration)
    signalWindow = fix([exampleRec.StartSec, exampleRec.StartSec + exampleRec.Duration] * fs);
elseif isnan(exampleRec.EndSec) && isnan(exampleRec.Duration)
    % Interpret this as from StartSec to the end of the recording.
    signalWindow = [fix(exampleRec.StartSec * fs), length(recordLoad)];
else
error('exactly one of EndSec or Duration must be a number, and the other must be missing, NA or NaN');
end

signalWindow(1) = signalWindow(1) + 1; % due to MATLAB 1-based, closed:closed interval indexing
 
assert(diff(signalWindow) > 0,'the signal window must have a duration of > 0 - check EndSec or Duration table field');

if nargout == 1
    header_or_samples = recordLoad(exampleRec.Channel, signalWindow(1):signalWindow(2));
elseif nargout == 2
    header_or_samples = structfun(@(x) extractDirectOrNthElem(x, exampleRec.Channel), ...
        headerLoad, UniformOutput=false);
    record = recordLoad(exampleRec.Channel, signalWindow(1):signalWindow(2));
end
end


function choice = extractDirectOrNthElem(thing, nth)
if iscell(thing)
    choice = thing{nth};
elseif ~isscalar(thing) && ~ischar(thing) && ~isstring(thing)
    % We don't want to pull out small bits of strings nor character arrays,
    % only the truly numerical arrays.
    choice = thing(nth);
else
    choice = thing;
end
end
