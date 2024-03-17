%%
clc;
close all;
clear all;

%% load edf and xml files
edfFilename = 'Project Data (modified dates)/R4.edf';
xmlFilename = 'Project Data/R4.xml';
[hdr, record] = edfread(edfFilename);
[events, stages, epochLength,annotation] = readXML(xmlFilename);
%%
numberOfEpochs = length(record(3,:)')/(30*hdr.samples(3));

%% plot 1 30 sec epoch of EOG channels only


whichAreEOGs = find(contains(hdr.label, 'EOG'));

% Plotting initialization
f = figure();
tlay = tiledlayout(2, 1);

for i = whichAreEOGs
    %disp(i)
    
    Fs = hdr.samples(i);
    durationSecs = (length(record(i,:))/Fs);
    epochNumber = 2; % plot nth epoch of 30 seconds
    epochStart = (epochNumber*Fs*30);
    epochEnd = epochStart + 30*Fs;
    signal = record(i,epochStart:epochEnd);
    nexttile();
    plot((1:length(signal))/Fs, signal);
    ylabel(hdr.label(i));
    xlim([1, 30]);
    set(gca(), "XMinorTick", "on", "YMinorTick", "on")
end
sgtitle(['30 seconds epoch #' num2str(epochNumber)]);
set(gcf,'color','w');


%% plot Hypnogram (sleep stages over time)
figure(2);
plot(((1:length(stages)))./60,stages); %sleep stages are for 30 seconds epochs
ylim([0 6]);
set(gca,'ytick',[0:6],'yticklabel',{'REM','','N3','N2','N1','Wake',''});
xlabel('Time (Minutes)');
ylabel('Sleep Stage');
box off;
title('Hypnogram');
set(gcf,'color','w');