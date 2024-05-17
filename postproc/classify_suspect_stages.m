function [sus, corrected] = classify_suspect_stages(stages)
% Reference:
%  0  REM
%  1  <NA>
%  2  N3
%  3  N2
%  4  N1
%  5  Wake

if class(stages) ~= 'double'
   stages = double(stages); % needs to be done as otherwise medfilt1 complains
end

medfilted = medfilt1(stages, 5);
medfilted_isModified = logical(stages - medfilted);

sus = medfilted_isModified;
corrected = medfilted;
end
