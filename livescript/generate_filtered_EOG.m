
FILE_NUM = 4;
[header, signals] = load_EOG(FILE_NUM);

signals = medfilt1(signals, 5, [], 2);

ts = 0:0.02:480;
idxs = secs2indices_EOG(ts);

chebFiltHd = chebyshev_t2_EOG_blink();
chebFilted = filter(chebFiltHd, signals');

parzenFiltHd = parzenFIR_EOG_blink();
parzenFilted = filter(parzenFiltHd, signals');

hold on;

plot(ts, signals(1, idxs), 'c', DisplayName='Original');
plot(ts, chebFilted(idxs, 1), 'r', DisplayName='Chebyshev t. II filtered');
plot(ts, parzenFilted(idxs,1), 'm', DisplayName='Parzen FIR filtered');
legend();

zoom xon;

zz = zoom();
zz.Enabled = 'on';
zz.Motion = 'horizontal';


parzenFiltedSmooth = movmean(parzenFilted.^2, 18, 1);

plot(ts, parzenFiltedSmooth(idxs, 1), 'g', DisplayName='Detection function');
legend();
