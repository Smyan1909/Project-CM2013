classdef CwtEogFeaturator
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties (SetAccess=protected)
        cwtFiltBank
    end

    methods
        function obj = CwtEogFeaturator(fs, epochLenOverride)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                fs (1, 1) {mustBePositive} = 50;
                epochLenOverride (1, 1) = 0;
            end
            
            if epochLenOverride > 0
                epochLen = epochLenOverride;
            else
                epochLen = 30 * fs;
            end

            obj.cwtFiltBank = cwtfilterbank( ...
                SignalLength=epochLen, ...
                SamplingFrequency=fs, ...
                Wavelet='amor', ...
                VoicesPerOctave=8 ...
            );
        end

        function feats = featsForEpoch(obj, segment)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            assert(length(segment) == obj.cwtFiltBank.SignalLength, ...
                'signal segment');
            
            [coefs, sc2f] = wt(obj.cwtFiltBank, segment);
        end
    end
end