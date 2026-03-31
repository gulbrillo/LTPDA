% Construct an miir from coefficients
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromAB
%
% DESCRIPTION: Construct an miir from coefficients
%
% CALL:        f = fromAB(f, pli)
%
% PARAMETER:   pli: Parameter list object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f = fromAB(f, pli)
  
  ii = miir.getInfo('miir', 'From AB');
  
  % Add default values
  pl = applyDefaults(ii.plists, pli);
  
  a  = find_core(pl, 'a');
  b  = find_core(pl, 'b');
  fs = find_core(pl, 'fs');
  
  % Checking the coefficients are listed in rows
  if size(a,1)~=1
    a = a';
  end
  if size(b,1)~=1
    b = b';
  end
  
  % Zero pad to avoid 0 length history vector
  if numel(a) <= 1
    a = [a 0];
  end
  if numel(b) <= 1
    b = [b 0];
  end
  
  f.fs      = fs;
  f.a       = a;
  f.b       = b;
  f.histin  = zeros(1,f.ntaps-1);  % initialise input history
  f.histout = zeros(1,f.ntaps-1);  % initialise output history
  
  if isempty(pl.find_core('name'))
    pl.pset('name', 'AB');
  end
  
  % Add history
  f.addHistory(ii, pl, [], []);
  
  % Set object properties
  f.setObjectProperties(pl, {'a', 'b', 'fs'});
  
end % End fromAB
