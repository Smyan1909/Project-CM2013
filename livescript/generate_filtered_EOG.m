
FILE_NUM = 4;
[header, signals] = load_EOG(FILE_NUM);

signals = medfilt1(signals, 5, [], 2);

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
hold on;

plot(ts, signals(1, idxs), 'c', DisplayName='Original');
plot(ts, chebFilted(idxs, 1), 'r', DisplayName='Chebyshev t. II filtered');
plot(ts, parzenFilted(idxs,1), 'm', DisplayName='Parzen FIR filtered');
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
plot(ts, parzenFiltedSmoother(idxs, 1) * normAmp, 'y', DisplayName='Detection function 36 mean = 720 ms');
plot(ts, parzenFiltedRougher(idxs, 1) * normAmp, 'b', DisplayName='Detection function 9 mean = 180 ms');
legend();
