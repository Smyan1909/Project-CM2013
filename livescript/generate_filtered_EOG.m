
FILE_NUM = 2;
[header, signals, epochInfo] = load_EOG(FILE_NUM);

signals = medfilt1(signals, 3, [], 2);

ts = 0:0.02:480;
idxs = secs2indices_EOG(ts);

chebFiltHd = chebyshev_t2_EOG_blink();
chebFilted = filter(chebFiltHd, signals');

parzenFiltHd = parzenFIR_EOG_blink();
parzenFilted = filter(parzenFiltHd, signals');
% 
% structToWrite = struct()
% edfwrite('_preproc_out', struct())
%% plotting
tlay = tiledlayout(4,1,TileSpacing='none');
ax1 = nexttile([3, 1]);

hold on;

plot(ts, signals(1, idxs), 'c', DisplayName='Original');
%plot(ts, chebFilted(idxs, 1), 'r', DisplayName='Chebyshev t. II filtered');
%plot(ts, parzenFilted(idxs,1), 'm', DisplayName='Parzen FIR filtered');
legend();

zoom xon;

zz = zoom();
zz.Enable = 'on';
zz.Motion = 'horizontal';

%%
parzenFiltedSmooth = movmean(parzenFilted.^2, 18, 1);
parzenFiltedSmoother = movmean(parzenFilted.^2, 36, 1);
parzenFiltedRougher = movmean(parzenFilted.^2, 9, 1);

normAmp = 1 / rms(parzenFilted(idxs, 1));

hold on;
zoom xon;

zz = zoom();
zz.Enable = 'on';
zz.Motion = 'horizontal';
plot(ts, parzenFiltedSmooth(idxs, 1) * normAmp, 'g', DisplayName='Detection function 18 mean = 360 ms');
plot(ts, parzenFiltedSmoother(idxs, 1) * normAmp, 'm', DisplayName='Detection function 36 mean = 720 ms');
plot(ts, parzenFiltedRougher(idxs, 1) * normAmp, 'b', DisplayName='Detection function 9 mean = 180 ms');
legend();


ax2 = nexttile([1,1]);
epochIdxs = secs2indices_EOG(ts, 1/30);
plot(epochIdxs*30, epochInfo.stages(epochIdxs));
yticks(0:5);

linkaxes([ax1, ax2], 'x');
