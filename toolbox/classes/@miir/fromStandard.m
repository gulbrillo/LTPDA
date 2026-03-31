% Construct an miir from a standard types
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStandard
%
% DESCRIPTION: Construct an miir from a standard types
%
% CALL:        f = fromStandard(f, pli)
%
% PARAMETER:   type:     String with filter type description
%              pli:       Parameter list object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = fromStandard(f, pli)
  
  ii = miir.getInfo('miir', 'From Standard Type');
  
  % Add default values
  pl = applyDefaults(ii.plists, pli);
  
  % Get parameters
  type = find_core(pl, 'type');
  
  % check and fill parameter list
  plo = miir.parseFilterParams(pl);
  switch lower(type)
    case {'lowpass', 'low-pass', 'low pass'}
      f = mklowpass(f, plo);
    case {'highpass' 'high-pass', 'high pass'}
      f = mkhighpass(f, plo);
    case {'bandpass', 'band-pass', 'band pass'}
      f = mkbandpass(f, plo);
    case {'bandreject', 'band-reject', 'band reject'}
      f = mkbandreject(f, plo);
    otherwise
      error('### unknown standard filter type in miir constructor.');
  end
  
  if isempty(pl.find_core('name'))
    pl.pset('name', type);
  end
  
  % Add history
  f.addHistory(ii, pl, [], []);
  
  % Set object properties
  f.setObjectProperties(pl);
  
end % function f = miirFromStandardType(type, pli, version, algoname)


