function indexArray = sec2ind(secondArray)
%SEC2IND Converts an array of times in seconds to an array of sample
%indices.
%   Convenience function to ease conversions between sample indice arrays
%   and second arrays (for e.g. plotting).
%   Notably, changes the 0-based timing to 1-based indexing in accordance
%   with MATLAB convention s, so that the first sample at time 0
%   has the index 1.
arguments
    secondArray double
end

% Infer sampling rate from array.
Fs = round(1 / (secondArray(2) - secondArray(1)));

indexArray = round(secondArray * Fs);
%mustBeInteger(indexArray);
end

