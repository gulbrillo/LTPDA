%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromRational
%
% DESCRIPTION: Construct a parfrac from a rational TF
%
% CALL:        pf = fromRational(a, pl)
%
% PARAMETER:   pl - plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pf = fromRational(pf, pli)
  
  % get pzmodel info
  ii = parfrac.getInfo('parfrac', 'From Rational');
  
  % Combine input plist with default values
  pl = applyDefaults(ii.plists, pli);
  
  % Set fields
  rat = find_core(pl, 'rational');
  
  % if the denominator is not a polynomial but a single number, then the
  % model is not really a rational model. It is practically a polynomial
  % model and cannot be converted in partial fractions. Output PF model
  % will be a zero residues and poles. Dterms will contain the numerator
  % polynomial
  if numel(rat.den)==1
    pf.res = 0;
    pf.poles = 0;
    pf.dir = (rat.num)./(rat.den);
    pf.pmul = 0;
  else % convert a true rational model in partial fractions
    [res, poles, dterms, pmul] = utils.math.cpf('INOPT', 'RAT', ...
      'NUM', rat.num, ...
      'DEN', rat.den, 'MODE', 'SYM');
    
    pf.res = res;
    pf.poles = poles;
    pf.dir = dterms;
    pf.pmul = pmul;
  end
  
  % Set properties from rational object
  if isempty(pl.find_core('ounits'))
    pl.pset('ounits', rat.ounits);
  end
  
  if isempty(pl.find_core('iunits'))
    pl.pset('iunits', rat.iunits);
  end
  
  if isempty(pl.find_core('name'))
    pl.pset('name', sprintf('parfrac(%s)', rat.name));
  end
  
  if isempty(pl.find_core('description'))
    pl.pset('description', rat.description);
  end
  
  % Add history
  pf.addHistory(ii, pl, [], rat.hist);
  
  % Set object properties
  pf.setObjectProperties(pl);
  
end
