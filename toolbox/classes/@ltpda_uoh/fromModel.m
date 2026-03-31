% FROMMODEL Construct an a built in model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromModel
%
% DESCRIPTION: Construct an ltpda uder objects with history from a
%              built-in model
%
% CALL:        a = fromModel(a, pl)
%
% PARAMETER:   pl: Parameter list object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function obj = fromModel(obj, pl)

  [obj, ii, fcnname, pl] = fromModel@ltpda_uo(obj, pl);
  
  if isempty(obj)
    return
  end
  
  % Add history
  try 
    % If we have the version, pass it. It's much more efficient that way
    % because we only want to add the info about this model version.
    ver = pl.find_core('version');
    if isempty(ver)
      feval(fcnname, 'info');
    else
      feval(fcnname, 'info', ver);
    end
  catch
    % if the model doesn't respond to an 'info' call, then it is an old
    % style model and we need to add history.
    obj.addHistory(ii, pl, [], []);
  end
  
  % Here we make a check on the default plist keys because these properties
  % may have been set in the model. We make the assumption that if they are
  % empty, the user had no intention of setting them so we can remove them
  % and keep the value set in the model.
  if isempty(pl.find_core('name'))
    pl.remove('name');
  end
  if isempty(pl.find_core('description'))
    pl.remove('description');
  end
  if isempty(pl.find_core('timespan'))
    pl.remove('timespan');
  end
  
  % Set object properties
  if ~isempty(obj)
    obj.setObjectProperties(pl);
  end
  
end

