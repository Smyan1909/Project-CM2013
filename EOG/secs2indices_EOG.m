function indices = secs2indices_EOG(secStart, secEnd, Fs)
%SECS2INDICES_EOG Helper function to convert second intervals (physical time) to an array of sample indices for EOG signals. 
%   Detailed explanation goes here
arguments
    secStart double {mustBeNonnegative}
    secEnd double = NaN 
    Fs double = 50
end

if nargin == 1
    % secStart is assumed to be a linear space of time points in seconds.
    timeArray = secStart;
    secStart = timeArray(1);
    secEnd = timeArray(end);
    %assert(all(diff(timeArray) == 0.02));
else
    mustBePositive(secEnd)
end

indexStart = floor(secStart * Fs) + 1;
indexEnd = floor(secEnd * Fs) + 1;

indices = indexStart:indexEnd;

end

