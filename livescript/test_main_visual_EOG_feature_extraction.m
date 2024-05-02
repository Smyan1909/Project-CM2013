[header, eogr, epochInfo] = load_EOG(4, 'R');

lyout = tiledlayout(5, 1, TileSpacing="none");

preprocd = preprocess_EOG_blink(eogr, 50);

startT = 0;
endT = 480;
Fs = 50;
idxs = 1 + startT * Fs : endT*Fs;
%tsEOG = (startT:length(preprocd(1, idxs)) - 1) / Fs;
tsEOG = (idxs(1) : idxs(end))/Fs;

ax1 = nexttile([4, 1]);
hold on;
%plot(tsEOG, eogr(1, idxs));
plot(tsEOG, preprocd(1, idxs));
% MinPeakDistance 0.2 = 200 ms, so a decent time it would seem
% MinPeakHeight = 0.12 = 12% of maximum amplitude is taken to be 1 pp less
%   than what is prescribed in Przybyla et al. 2008, where they recommend
%   0.13 of the normalized amplitude of the detection function as the
%   threshold.
findpeaks(preprocd(1, idxs), tsEOG, 'MinPeakDistance', 0.2, 'MinPeakHeight', 0.12, 'Annotate','extents');

ax2 = nexttile([1, 1]);

EPOCH_DUR = 30;
epoch_idxs = (1 + fix(startT/EPOCH_DUR)):endT/EPOCH_DUR;
epoch_ts = tsEOG(1:Fs*EPOCH_DUR:end);
bar(epoch_ts, epochInfo.stages(epoch_idxs));
yticks(0:6);
yticklabels({'REM','','N3','N2','N1','Wake',''});

linkaxes([ax1, ax2], 'x');
%visual_EOG_feature_extraction(eogr, 50);

