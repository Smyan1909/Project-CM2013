clear all;

[header, signals, epochinfo] = load_EOG(5);

sleep_code2string = dictionary(0:6, {'REM','','N3','N2','N1','Wake',''});


t_samps = (0:119) * 50 + 1;

[wtL, scale2freqsL] = cwt(signals(1, t_samps), 'amor', 50);

t_secs = t_samps / 50;

hp1 = pcolor(t_samps,log2(scale2freqsL),abs(wtL));
hp1.EdgeAlpha = 0;

figure;

[wtL2, scale2freqsL2] = cwt(signals(1, t_samps), 'morse', 50);

hp2 = pcolor(t_samps,log2(scale2freqsL2),abs(wtL2));
hp2.EdgeAlpha = 0;
