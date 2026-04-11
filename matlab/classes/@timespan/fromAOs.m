%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromAOs
%
% DESCRIPTION: Construct an timespan from the each input AO and returns the
%              absolute time rande (it is a wrapper of the AO method
%              getAbsTimeRange().
%
% CALL:        ts = fromAOs(ts, pl)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = fromAOs(obj, pli)
  
  % Get the m-info for this constructor
  ii = timespan.getInfo('timespan', 'From AOs');
  
  % Apply defaults to plist
  plh = applyDefaults(ii.plists, pli);
  
  % Get AOs from the PLIST
  aos = plh.find_core('aos');
  
  % Use the AO method getAbsTimeRange() to get the timespan of these AOs.
  obj = aos.getAbsTimeRange();
  
  if isempty(obj)
    error('Could not create any timespan objects from the inputs AOs. Perhaps no time-series AOs were specified?');
  end
  
  % add history
  for oo = 1:numel(obj)
    plh = plh.pset('aos', aos(oo));
    obj(oo).addHistory(ii, plh, [], []);
  end
  
end
