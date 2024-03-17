function [header, record] = load_EOG(fileNo, whichSide)
%load_EOG Convenience function to load EOG signals only.
%  
arguments
    fileNo int32
    whichSide char = ''
end
EDF_FILENAME_FMTSTR = 'Project Data (modified dates)/R%d.edf';
XML_FILENAME_FMTSTR = 'Project Data/R%d.xml';

edf_filename = sprintf(EDF_FILENAME_FMTSTR, fileNo);
xml_filename = sprintf(XML_FILENAME_FMTSTR, fileNo);

header = edfread(edf_filename);

disp(whichSide);

if strcmpi(whichSide, 'R')
    whichToLoad = find(contains(header.label, 'EOGR'));
    assert(numel(whichToLoad) == 1, 'found more than one EOGR channel!');
elseif strcmpi(whichSide, 'L')
    whichToLoad = find(contains(header.label, 'EOGL'));
    assert(numel(whichToLoad) == 1, 'found more than one EOGL channel!');
else
    whichToLoad = find(contains(header.label, 'EOG'));
    assert(numel(whichToLoad) == 2, 'found other than two EOG channels (%d)!', ...
        numel(whichToLoad));
end

[header, record] = edfread(edf_filename, 'targetSignals', whichToLoad);
end