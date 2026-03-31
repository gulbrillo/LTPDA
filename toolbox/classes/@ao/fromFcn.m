% FROMFCN Construct an ao from a function string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromFcn
%
% DESCRIPTION: Construct an ao from a function string
%
% CALL:        a = fromFcn(a, pl)
%
% PARAMETER:   pl: Parameter list object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = fromFcn(a, pli)
  
  % get AO info
  ii = ao.getInfo('ao', 'From Function');
  
  % Add default values
  pl = combine(pli, ii.plists);
  % Tell parse that the output value for fcn should be a double so that it evals the user input
  pl = parse(pl, plist('fcn', []));
  % Set random state in case we are rebuilding and the function used rand etc
  pl.getSetRandState();
  
  fcn = find_core(pl, 'fcn');
  
  % Set data of analysis object
  if ischar(fcn)
    a.data  = cdata(eval(fcn));
  elseif isnumeric(fcn)
    a.data = cdata(fcn);
  else
    error('### unknown format for the function');
  end
  
  % Set errors from plist
  a.data.setErrorsFromPlist(pl);
  
  % Set non-object properties
  a.setYunits(pl.find_core('yunits'));
  
  % Add history
  a.addHistory(ii, pl, [], []);
  
  % Set object properties
  a.setObjectProperties(pl);
  
end

