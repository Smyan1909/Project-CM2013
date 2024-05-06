function procChan = preprocess_EOG_blink(eog_channel, Fs)
arguments
    eog_channel (1,:) double
    Fs double = 50
end

unspiked = medfilt1(eog_channel, 3);

filtHd = parzenFIR_EOG_blink(Fs);
filted = filter(filtHd, unspiked);

sqrd = filted .^ 2;
avged = movmean(sqrd, 17);

procChan = avged / max(avged); % normalization to [0 ; 1]

end