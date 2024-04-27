function secondArray = ind2sec(indexArray, Fs)
%IND2SEC Converts an array of signal sample indices to an array of times in
%seconds.
%    Convenience function to ease conversions between sample indice arrays
%    and second arrays (for e.g. plotting).
%    Notably, changes the MATLAB convention of 1-based indexing to time
%    in seconds starting at 0, so the first sample is at 0 s, not (1/Fs) s.
secondArray = (indexArray - 1) / Fs;
end

