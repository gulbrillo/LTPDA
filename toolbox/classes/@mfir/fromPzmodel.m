% Construct an mfir from a pzmodel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromPzmodel
%
% DESCRIPTION: Construct an mfir from a pzmodel
%
% CALL:        f = fromPzmodel(f, pli)
%
% PARAMETER:   type:     String with filter type description
%              pli:       Parameter list object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f = fromPzmodel(f, pli)
  
  ii = mfir.getInfo('mfir', 'From Pzmodel');
  
  % Add default values
  pl = applyDefaults(ii.plists, pli);
  
  % Get parameters
  pzm = find_core(pl, 'pzmodel');
  fs  = find_core(pl, 'fs');
  
  if isempty(fs)
    % get max freq in pzmodel
    fs = 8*getupperFreq(pzm);
    warning([sprintf('!!! no sample rate specified. Designing for fs=%2.2f Hz.', fs)...
      sprintf('\nThe filter will be redesigned later when used.')]);
  end
  % make MIIR filter
  f = tomfir(pzm, plist('fs', fs));
  
  % override default input plist values
  if isempty(pl.find_core('name'))
    pl.pset('name', sprintf('fir(%s)', pzm.name));
  end
  if isempty(pl.find_core('description'))
    pl.pset('description', pzm.description);
  end
  if isempty(pl.find_core('iunits'))
    pl.pset('iunits', pzm.iunits);
  end
  if isempty(pl.find_core('ounits'))
    pl.pset('ounits', pzm.ounits);
  end
  
  % Add history
  f.addHistory(ii, pl, [], pzm.hist);
  
  % Set remaining properties
  f.setObjectProperties(pl);
  
end % End fromPzmodel
