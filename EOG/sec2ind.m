function indexArray = sec2ind(secondArray, Fs)
%SEC2IND Converts an array of times in seconds to an array of sample
%indices.
%   Convenience function to ease conversions between sample indice arrays
%   and second arrays (for e.g. plotting).
%   Notably, changes the 0-based timing to 1-based indexing in accordance
%   with MATLAB convention s, so that the first sample at time 0
%   has the index 1.
indexArray = secondArray * Fs;
mustBeInteger(indexArray);
end

