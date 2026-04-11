% Construct an miir from a parfrac
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromParfrac
%
% DESCRIPTION: Construct an miir from a parfrac
%
% CALL:        f = fromParfrac(f, pli)
%
% PARAMETER:   type:     String with filter type description
%              pli:       Parameter list object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = fromParfrac(f, pli)
  
  ii = miir.getInfo('miir', 'From Parfrac');
  
  % Add default values
  pl = applyDefaults(ii.plists, pli);
  
  % Get parameters
  pf  = find_core(pl, 'parfrac');
  fs  = find_core(pl, 'fs');
  idx = find_core(pl, 'index');
  
  if isempty(fs)
    % get max freq in pzmodel
    fs = 8*getupperFreq(pf);
    warning([sprintf('!!! no sample rate specified. Designing for fs=%2.2f Hz.', fs)...
      sprintf('\nThe filter will be redesigned later when used.')]);
  end
  % make MIIR filter
  pfstruct = utils.math.lp2z('INOPT', 'PF', 'RES', pf.res, 'POLES', pf.poles, ...
    'DTERMS', pf.dir, 'MODE', 'DBL', 'FS', fs);
  
  for jj=1:numel(pfstruct)
    pl = copy(pl,1);
    
    f(jj).a  = pfstruct(jj).num;
    f(jj).b  = pfstruct(jj).den;
    f(jj).fs = fs;
    
    if isempty(pl.find_core('name'))
      pl.pset('name', sprintf('iir(%s_%d)', pf.name, jj));
    end
    if isempty(pl.find_core('description'))
      pl.pset('description', pf.description);
    end
    if isempty(pl.find_core('iunits'))
      pl.pset('iunits', pf.iunits);
    end
    if isempty(pl.find_core('ounits'))
      pl.pset('ounits', pf.ounits);
    end
    pl.pset('index', jj);
    
    % Add history
    f(jj).addHistory(ii, pl, [], pf.hist);
  end
  
  % Set object properties
  f.setObjectProperties(pl);
  
  % Index the output filter
  if ~isempty(idx)
    f = f(idx);
  end
  
end % End fromParfrac
