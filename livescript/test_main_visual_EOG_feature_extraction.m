[header, eogr, epochInfo] = load_EOG(4, 'R');

lyout = tiledlayout(5, 1, TileSpacing="none");

preprocd = preprocess_EOG_blink(eogr, 50);

startT = 500;
endT = 1000;
Fs = 50;
idxs = 1 + startT * Fs : endT*Fs;
tsEOG = (0:length(preprocd(1, idxs)) - 1) / Fs;

ax1 = nexttile([4, 1]);
plot(tsEOG, eogr(1, idxs), tsEOG, preprocd(1, idxs));

ax2 = nexttile([1, 1]);

EPOCH_DUR = 30;
epoch_idxs = 1:endT/EPOCH_DUR;
epoch_ts = tsEOG(1:Fs*EPOCH_DUR:end);
bar(epoch_ts, epochInfo.stages(epoch_idxs));
yticks(0:6);
yticklabels({'REM','','N3','N2','N1','Wake',''});

linkaxes([ax1, ax2], 'x');
%visual_EOG_feature_extraction(eogr, 50);

