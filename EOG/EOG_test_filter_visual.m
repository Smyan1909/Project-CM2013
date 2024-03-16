% EOG_test_filter_visual

%%
close all;
clear all;

%% load edf and xml files
EDF_FILENAME_FMTSTR = 'Project Data (modified dates)/R%d.edf'
XML_FILENAME_FMTSTR = 'Project Data/R%d.xml';
N_FILES = 10;

%% Load all EDF records from all 10 files
% WARNING: this will take up about 4 GB of RAM. If you do not have that
% much memory in your computer, consider changing this code to load
% fewer records.
%EDFs = cell(1,N_FILES)
% for i=1:N_FILES
%     [HDR, RECORD] = edfread(sprintf(EDF_FILENAME_FMTSTR, i));
%     EDFs{i} = {HDR, RECORD};
% 
% 
% end

%% Load EDF file one by one and plot their power spectrum for EOG
clf;
hold on;
legendLabels = [];
for i=1:3
    [HDR, RECORD] = edfread(sprintf(EDF_FILENAME_FMTSTR, i));
    N_EPOCHS = length(RECORD(3,:))/(30*HDR.samples(3));
    fprintf('Number of epochs: %d\n', N_EPOCHS);

    whichAreEOGs = find(contains(HDR.label, 'EOG'));
    for j=whichAreEOGs
        pspectrum(RECORD(j, :), HDR.samples(j) / HDR.duration, ...
            'power')
        legendLabels = [legendLabels; sprintf('R%d ch%d', i, j)];
    end
end
legend(legendLabels);

%%
% Plotting initialization
f = figure();
tlay = tiledlayout(2, 1);

whichChan = 6;
i = whichChan;
%disp(i)

assert(HDR.duration == 1, ['Expected EDF record duration to be 1 s, ' ...
    'got %f'], HDR.duration)
Fs = HDR.samples(i);
durationSecs = (length(RECORD(i,:))/Fs);
epochNumber = 2; % plot nth epoch of 30 seconds
epochStart = (epochNumber*Fs*30);
epochEnd = epochStart + 30*Fs;
signal = RECORD(i,epochStart:epochEnd);
nexttile();
plot((1:length(signal))/Fs, signal);
ylabel(HDR.label(i));
xlim([1, 30]);
set(gca(), "XMinorTick", "on", "YMinorTick", "on")