function blink = blink_detect(signals, fs)
arguments
    signals double
    fs double
    smooth_secs = 0.5
end

filted = medfilt1(signals, 3, [], 2);

% Bandpass filtering here...

squared = filted^2;

smoothed = movmean(squared, smooth_secs * fs, 2);

diffed = diff(signals, 1, 2);

smoothdiffed = movmean(diffed, smooth_secs * fs, 2);



end