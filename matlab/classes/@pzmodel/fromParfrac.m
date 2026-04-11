%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromParfrac
%
% DESCRIPTION: Construct a pzmodel from a partial fractions TF
%
% CALL:        pzm = fromParfrac(a, pl)
%
% PARAMETER:   pl   - plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pzm = fromParfrac(pzm, pli)
  
  
  % get pzmodel info
  ii = pzmodel.getInfo('pzmodel', 'From Parfrac');
    
  % Combine input plist with default values
  pl = applyDefaults(ii.plists, pli);
  
  % Set fields
  pf      = find_core(pl, 'parfrac');
  
  poles = pf.poles;
  
  % get numerator
  [num,den] = residue(pf.res,pf.poles,pf.dir);
  zeros = roots(num);
  
  % find dc gain
  ig = sum(-1*pf.res./poles) + pf.dir;
  
  % remove conjugate pairs
  if isempty(poles)
    ps = [];
  else
    ps = {poles(1)};
    for jj=2:numel(poles)
      if ~isreal(poles(jj))
        if~any(conj(poles(jj))==[ps{:}])
          ps = [ps poles(jj)];
        end
      else
        ps = [ps poles(jj)];
      end
    end
  end
  
  if isempty(zeros)
    zs = [];
  else
    zs = {zeros(1)};
    for jj=2:numel(zeros)
      if ~isreal(zeros(jj))
        if~any(conj(zeros(jj))==[zs{:}])
          zs = [zs zeros(jj)];
        end
      else
        zs = [zs zeros(jj)];
      end
    end
  end

  % divide for (-2*pi) only when a real pole or zero is found
  if ~isempty(ps)
    numps = cell2mat(ps);
    numps(imag(numps)==0) = numps(imag(numps)==0)./(2.*sign(numps(imag(numps)==0)).*pi);
    ps = num2cell(numps);
  end
  if ~isempty(zs)
    numzs = cell2mat(zs);
    numzs(imag(numzs)==0) = numzs(imag(numzs)==0)./(2.*sign(numzs(imag(numzs)==0)).*pi);
    zs = num2cell(numzs);
  end

  pzm = pzmodel(ig, ps, zs);
  
  % Override some plist values
  if isempty(pl.find_core('ounits'))
    pl.pset('ounits', pf.ounits);
  end
  
  if isempty(pl.find_core('iunits'))
    pl.pset('iunits', pf.iunits);
  end
  
  if isempty(pl.find_core('name'))
    pl.pset('name', sprintf('pzmodel(%s)', pf.name));
  end
  
  if isempty(pl.find_core('description'))
    pl.pset('description', pf.description);
  end
  
  % Add history
  pzm.addHistory(ii, pl, [], pf.hist);
  
  % Set object properties
  pzm.setObjectProperties(pl);
  
end
