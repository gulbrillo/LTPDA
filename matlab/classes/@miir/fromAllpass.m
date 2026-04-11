% Construct an miir allpass filter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStandard
%
% DESCRIPTION: Construct an miir allpass filter
%
% CALL:        f = fromAllpass(f, pli)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = fromAllpass(f, pli)
  
  ii = miir.getInfo('miir', 'Allpass');
  
  % Add default values
  pl = applyDefaults(ii.plists, pli);
  
  f = mkallpass(f, pl);
  
  if isempty(pl.find_core('name'))
    pl.pset('name', 'allpass');
  end
  
  % Add history
  f.addHistory(ii, pl, [], []);
  
  % Set object properties
  f.setObjectProperties(pl);
  
end % function f = miirFromStandardType(type, pli, version, algoname)


