%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromPolesAndZeros
%
% DESCRIPTION: Construct a pzmodel from poles and zeros
%
% CALL:        pzm = fromPolesAndZeros(a, pl, callerIsMethod)
%
% PARAMETER:   pl   - plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pzm = fromPolesAndZeros(pzm, pli, callerIsMethod)

  % get pzmodel info
  if ~callerIsMethod
    ii = pzmodel.getInfo('pzmodel', 'From Poles/Zeros');
    % Combine input plist with default values
    pl = applyDefaults(ii.plists, pli);
  else
    pl = pli;
  end
  
  % Set fields
  if callerIsMethod
    pzm.gain = pl.gain;
    ps = pl.poles;
    zs = pl.zeros;
    delay = pl.delay;
  else
    pzm.gain = find_core(pl, 'gain');
    ps       = find_core(pl, 'poles');
    zs       = find_core(pl, 'zeros');
    delay    = find_core(pl, 'delay');
  end
  
  % Add only valid poles
  if ~isempty(ps)
    if ~isa(ps, 'pz')
      ps = pz(ps);
    end
    poles = [];
    for kk = 1:numel(ps)
      if ~isnan(ps(kk).f)
        poles = [poles ps(kk)];
      end
    end
    if ~callerIsMethod
      pl.pset_core('poles', poles);
    end
    pzm.poles = poles;
  end
  
  % Add only valid zeros
  if ~isempty(zs)
    if ~isa(zs, 'pz')
      zs = pz(zs);
    end
    zeros = [];
    for kk = 1:numel(zs)
      if ~isnan(zs(kk).f)
        zeros = [zeros zs(kk)];
      end
    end
    if ~callerIsMethod
      pl.pset_core('zeros', zeros);
    end
    pzm.zeros = zeros;
  end
  
  % set rest of the properties
  if ~isempty(delay)
    pzm.delay = delay;
  end
  
  % Set object properties from input plist
  if ~callerIsMethod
    pzm.setObjectProperties(pl, {'gain', 'poles', 'zeros', 'delay'});
    % Add history
    pzm.addHistory(ii, pl, [], []);
  end
end
