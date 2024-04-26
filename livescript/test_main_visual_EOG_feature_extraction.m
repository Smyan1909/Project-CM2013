[~ , eogr] = load_EOG(4, 'R');


preprocd = preprocess_EOG_blink(eogr, 50);.

idxs = 1:100000;
ts = (0:length(preprocd(1, idxs)) - 1) / 50;
plot(ts, eogr(1, idxs), ts, preprocd(1, idxs));

visual_EOG_feature_extraction(eogr, 50);
%
