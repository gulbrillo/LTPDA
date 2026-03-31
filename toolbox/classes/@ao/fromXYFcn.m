% FROMXYFCN Construct an ao from a function f(x) string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromXYfcn
%
% DESCRIPTION: Construct an ao from a function f(x) string
%
% CALL:        a = fromXYfcn(pl)
%
% PARAMETER:   pl: Parameter list object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = fromXYFcn(a, pli)
  
  % get AO info
  ii = ao.getInfo('ao', 'From XY Function');
  
  % Add default values
  pl = applyDefaults(ii.plists, pli);
  pl.getSetRandState();
  
  % Get parameters
  fcn = find_core(pl, 'xyfcn');
  x   = find_core(pl, 'X');
  
  % Make data
  ts = xydata(x,eval([fcn ';']));
  
  % Make an analysis object
  a.data = ts;
  
  % Set errors from plist
  a.data.setErrorsFromPlist(pl);
  
  % Add history
  a.addHistory(ii, pl, [], []);
  
  % Set xunits
  a.data.setXunits(pl.find_core('xunits'));
  
  % Set yunits
  a.data.setYunits(pl.find_core('yunits'));
  
  % Set object properties from the plist
  a.setObjectProperties(pl, {'xunits', 'yunits', 'x'});
  
end


