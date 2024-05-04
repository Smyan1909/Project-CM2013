function sus = classify_suspect_stages(stages)
  % Reference:
  %  0  REM
  %  1  <NA>
  %  2  N3
  %  3  N2
  %  4  N1
  %  5  Wake

  medfilted = medfilt1(stages);
  medfilted_isModified = logical(stages - medfilted);
  
end
