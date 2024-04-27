[~ , eogr] = load_EOG(4, 'R');

lyout = tiledlayout(5, 1, TileSpacing="none");

preprocd = preprocess_EOG_blink(eogr, 50);

idxs = 1:100000;
tsEOG = (0:length(preprocd(1, idxs)) - 1) / 50;

ax1 = nexttile([4, 1]);
plot(tsEOG, eogr(1, idxs), tsEOG, preprocd(1, idxs));

ax2 = nexttile([1, 1]);

plot(epochIdxs*30, epochInfo.stages(epochIdxs));
yticks(0:6);
yticklabels({'REM','','N3','N2','N1','Wake',''});

linkaxes([ax1, ax2], 'x');
%visual_EOG_feature_extraction(eogr, 50);

