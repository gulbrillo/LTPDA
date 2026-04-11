%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromResidualsPolesDirect
%
% DESCRIPTION: Construct a partial fraction TF from residuals, poles, and
%              direct terms.
%
% CALL:        pf = fromResidualsPolesDirect(a, pl)
%
% PARAMETER:   pl   - plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pf = fromResidualsPolesDirect(pf, pli)
  
  % get pzmodel info
  ii = parfrac.getInfo('parfrac', 'From Residuals/Poles/Direct');
  
  % Combine input plist with default values
  pl = applyDefaults(ii.plists, pli);
  
  % Set fields
  pf.res = find_core(pl, 'res');
  pf.dir = find_core(pl, 'dir');
  
  % deal with poles
  poles = find_core(pl, 'poles');
  if isnumeric(poles)
    pf.poles = poles;
  elseif isa(poles, 'pz')
    pf.poles = [];
    for ii = 1:length(poles)
      tpl = poles(ii).ri;
      if (poles(ii).q > 0.5) || (poles(ii).q < 0.5)
        pf.poles = [pf.poles tpl(1) tpl(2)];
      else
        pf.poles = [pf.poles tpl];
      end
    end
  elseif iscell(poles)
    pf.poles = [];
    for jj = 1:length(poles)
      tpl = poles{jj};
      pf.poles = [pf.poles tpl];
    end
  else
    error('### Poles are in unknown format');
  end
  
  % Checking for high multiplicity poles
  res = pf.res;
  pls = pf.poles;
  % mults contain poles multiplicity and indx is the corresponding position
  [mults, indx] = mpoles( pls, 1e-15, 0 );
  % Sorting poles and residues in the mults order
  pf.res = res(indx);
  pf.poles = pls(indx);
  pf.pmul = mults.'; % a vector with the corresponding poles multiplicity
  
  if numel(pf.poles) ~= numel(pf.res)
    error('### The number of residual and poles must be equal.');
  end
  
  % Add history
  pf.addHistory(ii, pl, [], []);
  
  % Set object properties from input plist
  pf.setObjectProperties(pl);
  
end
