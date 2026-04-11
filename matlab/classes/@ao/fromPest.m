% FROMPEST Construct a AO from a pest.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    FROMPEST Construct a AO from a pest
%
% DESCRIPTION: FROMPEST Construct a AO from a pest
%
% CALL:        a = fromPest(a, pl)
%
% PARAMETER:   pl: plist containing 'pest'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function a = fromPest(a, pli)
  
  % get AO info
  ii = ao.getInfo('ao', 'From Pest');
  
  % Add default values
  pl = applyDefaults(ii.plists, pli);
  pl.getSetRandState();
  
  ps = find_core(pl, 'pest');
  param_name = find_core(pl, 'parameter');
  
  if isempty(param_name)
    names = ps.names;
  elseif isa(param_name, 'char')
    names = {param_name};
  else
    names = param_name;
  end
  a = ao.initObjectWithSize(1, numel(names));
  
  for jj = 1:numel(names)
    a(jj) = ps.find(names{jj});
  end
  
  if isempty(pl.find_core('name'))
    pl.pset('name', names);
  end
  if isempty(pl.find_core('description'))
    pl.pset('description', ps.description);
  end
  
  % Add history
  a.addHistory(ii, pl, [], []);
  
  % Set object properties from the plist
  a.setObjectProperties(pl);
  
end


