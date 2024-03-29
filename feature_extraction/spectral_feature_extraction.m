function spec_features = spectral_feature_extraction(signal, Fs)
    %SPECTRAL FEATURE EXTRACTION Summary of this function goes here
    [spectrum,f] = pwelch(signal,[],[],[],Fs);
    
    centroid = sum(spectrum.*f)/sum(spectrum);

    SFM = geomean(abs(spectrum))/mean(spectrum);
    
    spect_sum = sum(spectrum);

    i=1; part_sum=0;

    while(part_sum < spect_sum*0.85)
        
        part_sum = part_sum + spectrum(i);
        
        i = i + 1;
        
    end
    
    SR = f(i-1);
    
    %spec_features = [centroid, SFM, SR];
    spec_features = struct('Centroid', centroid, 'SFM', SFM, 'SR', SR);

end

