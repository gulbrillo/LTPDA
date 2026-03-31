% FROMSMODEL Construct a AO from an smodel.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    FROMSMODEL Construct a AO from an smodel
%
% DESCRIPTION: FROMSMODEL Construct a AO from an smodel
%
% CALL:        a = fromSModel(a, pl)
%
% PARAMETER:   pl: plist containing 'model'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function a = fromSModel(a, pli, callerIsMethod)
  
  if callerIsMethod
    % do nothing
  else
    % get AO info
    ii = ao.getInfo('ao', 'From Smodel');
  end
  
  if callerIsMethod
    pl = pli;
  else
    % Combine input plist with default values
    pl = applyDefaults(ii.plists, pli);
  end
  
  pl.getSetRandState();
  
  mdl = find_core(pl, 'model');
  
  % Build the plist needed for the smodel/eval call
  pl_eval = plist(...
    'output x',      find_core(pl, 'x'), ...
    'output xunits', find_core(pl, 'xunits'), ...
    'output type',   find_core(pl, 'type'), ...
    't0', 0);
  
  % Build the object by calling smodel/eval
  a = mdl.eval(pl_eval);
  
  if isempty(pl.find_core('name'))
    pl.pset('name', sprintf('eval(%s)', mdl.name));
  end
  if isempty(pl.find_core('description'))
    pl.pset('description', mdl.description);
  end
  
  if callerIsMethod
    % do nothing
  else
    % Add history
    a.addHistory(ii, pl, [], mdl.hist);
  end
  
  % Set object properties from the plist
  a.setObjectProperties(pl, {'x', 'xunits'});
  
end


