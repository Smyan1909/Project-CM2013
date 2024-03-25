
clear;
clf;

THRESH_MIN = 2;
THRESH_MAX = 84;
COLORMAPS = {'autumn', 'winter'};

for i = 4:7
    [header, signals] = load_EOG(i);
    
    epochLen = header.samples(1) / header.duration * 30; % Number of samples in a 30 s epoch
    
    t_secs = (1:length(signals)) / 50;
    xaxis_tickvalues = 0:1200:max(t_secs);
    xaxis_minorticks = 0:300:max(t_secs);
       
    measures = epochwise_apply(signals, 50, @rms);
    
    for j = 1:size(signals, 1)
        hold on;
        colormap(COLORMAPS{j});
        plot(t_secs, signals(j, :));

        isartefactArray = (measures(j,:) >= THRESH_MIN) & ...
            (measures(j,:) <= THRESH_MAX);

        scatterColors = zeros(length(isartefactArray), 1);
        %scatterColors(isartefactArray, 1) = 1.0;
        scatterColors(~isartefactArray) = 1.0;
        
        SCATTER_SIZE = 5;
        scatter(t_secs(1:epochLen:end), measures(j,:), ...
            SCATTER_SIZE*ones(length(measures), 1), scatterColors');
        yregion(THRESH_MIN, THRESH_MAX);
        title(sprintf('R%d.edf, channel %s', i, header.label{j} ));
        xlabel("Time (s)");
        ylabel("Amplitude or RMS power (μV)");
        
        ax = gca();
        ax.XAxis.Exponent = 0;
        ax.XAxis.TickValues = xaxis_tickvalues;
        ax.XAxis.MinorTick = 'on';
        ax.XAxis.MinorTickValues = xaxis_minorticks;

        figure;
    end

    

end
