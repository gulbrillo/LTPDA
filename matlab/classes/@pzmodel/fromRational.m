%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromRational
%
% DESCRIPTION: Construct a pzmodel from a rational TF
%
% CALL:        pzm = fromRational(a, pl)
%
% PARAMETER:   pl   - plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pzm = fromRational(pzm, pli)
  
  % get pzmodel info
  ii = pzmodel.getInfo('pzmodel', 'From Rational');
    
  % Combine input plist with default values
  pl = applyDefaults(ii.plists, pli);
  
  % Set fields
  rat      = find_core(pl, 'rational');
  
  poles = roots(rat.den);
  zeros = roots(rat.num);
  
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
  
  % get gain - must be a nicer way, but...
  ig = abs(resp(rat, plist('f', 0)));
  
  % divide for (-2*pi) only when a real pole or zero is found
  if ~isempty(ps)
    numps = cell2mat(ps);
    numps(imag(numps)==0) = numps(imag(numps)==0)/(-2*pi);
    ps = num2cell(numps);
  end
  if ~isempty(zs)
    numzs = cell2mat(zs);
    numzs(imag(numzs)==0) = numzs(imag(numzs)==0)/(-2*pi);
    zs = num2cell(numzs);
  end
  
  % convert to pzmodel
  pzm = pzmodel(ig.data.getY, ps, zs);
  
  % Override some plist values using the input object
  if isempty(pl.find_core('ounits'))
    pl.pset('ounits', rat.ounits);
  end
  
  if isempty(pl.find_core('iunits'))
    pl.pset('iunits', rat.iunits);
  end
  
  if isempty(pl.find_core('name'))
    pl.pset('name', sprintf('pzmodel(%s)', rat.name));
  end
  
  if isempty(pl.find_core('description'))
    pl.pset('description', rat.description);
  end
  
  % Add history
  pzm.addHistory(ii, pl, [], rat.hist);
  
  % Set object properties
  pzm.setObjectProperties(pl);
  
end
