%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromTimespanDef
%
% DESCRIPTION: Construct an timespan from start and end time
%
% CALL:        ts = fromTimespanDef(ts, t1, t2)
%
% INPUT:       ts = timespan-object
%              t1 = start time (char or time-object)
%              t2 = end   time (char or time-object)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = fromTimespanDef(obj, pli, callerIsMethod)
  
  if callerIsMethod
    % do nothing
  else
    % get timespan info
    ii = timespan.getInfo('timespan', 'From Timespan Definition');
  end
  
  if callerIsMethod
    pl = pli;
  else
    % apply default values
    pl = applyDefaults(ii.plists, pli);
  end
  
  % obtain parameters from plist
  t1 = pl.find_core('start');
  t2 = pl.find_core('stop');

  tf = find_core(pl, 'timeformat');
  tz = find_core(pl, 'timezone');
  
  if isa(t1, 'time');
    % if parameter is a time object copy it
    t1 = copy(t1, 1);
  else
    % otherwise costruct a time object from input parameters
    t1 = time(plist('time', t1, 'timeformat', tf, 'timezone', tz));
  end
  if isa(t2, 'time');
    % if parameter is a time object copy it
    t2 = copy(t2, 1);
  else
    % otherwise costruct a time object from input parameters
    t2 = time(plist('time', t2, 'timeformat', tf, 'timezone', tz));
  end
  
  % set start and end times
  obj.startT = t1;
  obj.endT   = t2;
  
  % NOTE: in principle we should have been able to set the startT and endT
  % in the plist and let setObjectProperties do the seeting, but since
  % these properties have non-standard case, it's hard to dynamically
  % construct the setter name.
  
  if ~callerIsMethod
    % add history
    obj.addHistory(ii, pl, [], obj.hist);
  end
  
  % set object properties from plist
  obj.setObjectProperties(pl, {'start', 'end'});
  
end
