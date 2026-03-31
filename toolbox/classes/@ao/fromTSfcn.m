% FROMTSFCN Construct an ao from a ts-function string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromTSfcn
%
% DESCRIPTION: Construct an ao from a ts-function string
%
% CALL:        a = fromTSfcn(pl)
%
% PARAMETER:   pl: Parameter list object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = fromTSfcn(a, pli)
  
  % get AO info
  ii = ao.getInfo('ao', 'From Time-series Function');
  
  % Add default values
  pl = applyDefaults(ii.plists, pli);
  pl.getSetRandState();
  
  nsecs       = find_core(pl, 'nsecs');
  fs          = find_core(pl, 'fs');
  fcn         = find_core(pl, 'tsfcn');
  t0          = find_core(pl, 't0');
  toffset     = find_core(pl, 'toffset');
  
  % Build t vector
  if isempty(nsecs) || nsecs == 0
    error('### Please provide ''Nsecs'' for ts-function constructor.');
  end
  if  isempty(fs) || fs == 0
    error('### Please provide ''fs'' for ts-function constructor.');
  end
  
  
  % make time vector
  t = tsdata.createTimeVector(fs, nsecs);
  
  % make y data
  y = eval([fcn ';']);
  
  % if the user passed a string which is not a function of t, then a
  % constant value is calculated
  if numel(t) ~= numel(y)
    if numel(y) == 1
      disp('The function input is not a function of t; a constant value is calculated.');
      y = y*ones(size(t));
    else
      error('### The function input size does not match the time base size');
    end
  end
  
  % Make an analysis object
  a.data = tsdata(t,y,fs);
  
  % set t0
  a.data.setT0(t0);
  
  % set toffset
  a.data.setToffset(toffset*1e3);
  
  % Set errors from plist
  a.data.setErrorsFromPlist(pl);
  
  % Set xunits and yunits
  a.data.setXunits(pl.find_core('xunits'));
  a.data.setYunits(pl.find_core('yunits'));
  
  % Add history
  a.addHistory(ii, pl, [], []);
  % Set object properties from the plist
  a.setObjectProperties(pl, {'xunits', 'yunits', 'fs', 't0', 'toffset'});
  
end


