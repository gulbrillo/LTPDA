% Construct an miir from a pzmodel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromPzmodel
%
% DESCRIPTION: Construct an miir from a pzmodel
%
% CALL:        f = fromPzmodel(f, pli)
%
% PARAMETER:   type:     String with filter type description
%              pli:       Parameter list object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = fromPzmodel(f, ipzm, pli)
  
  ii = miir.getInfo('miir', 'From Pzmodel');
  
  % Add default values
  pl = applyDefaults(ii.plists, pli);
  
  % Get parameters
  if isempty(ipzm)
    pzm = find_core(pl, 'pzmodel');
  else
    pzm = ipzm;
    pl.remove('pzmodel');
  end
  
  if ~isa(pzm, 'pzmodel')
    error('### The ''From Pzmodel'' constructor requires an input pzmodel');
  end
  
  fs  = find_core(pl, 'fs');
  
  if isempty(fs)
    % get max freq in pzmodel
    fs = 8*getupperFreq(pzm);
    warning([sprintf('!!! no sample rate specified. Designing for fs=%2.2f Hz.', fs)...
      sprintf('\nThe filter will be redesigned later when used.')]);
  end
  % make MIIR filter
  f = tomiir(pzm, fs);
  
  if isempty(pl.find_core('name'))
    pl.pset('name', sprintf('iir(%s)', pzm.name));
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
  if isempty(ipzm)
    f.addHistory(ii, pl, [], []);
  else
    f.addHistory(ii, pl, [], ipzm.hist);
  end
  
  % Set object properties
  f.setObjectProperties(pl);
  
end % End fromPzmodel
