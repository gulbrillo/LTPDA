% Construct an mfir from coefficients
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromA
%
% DESCRIPTION: Construct an mfir from coefficients
%
% CALL:        f = fromA(f, pli)
%
% PARAMETER:   pli:       Parameter list object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f = fromA(f, pli)
  
  ii = mfir.getInfo('mfir', 'From A');
  
  % Add default values
  pl = applyDefaults(ii.plists, pli);
  
  a  = find_core(pl, 'a');
  fs = find_core(pl, 'fs');
  
  % Checking the coefficients are listed in rows
  if size(a,1)~=1
    a = a';
  end
  
  % Zero pad coefficients to avoid zero length history
  if numel(a) <= 1
    a = [a 0];
  end
  
  f.fs      = fs;
  f.a       = a;
  f.gd      = (f.ntaps-1)/2;
  f.histout = zeros(1,f.ntaps-1); % initialise output history
  
  % Override some properties of the input plist
  if isempty(pl.find_core('name'))
    pl.pset('name', 'A');
  end
  
  % Add history
  f.addHistory(ii, pl, [], []);
  
  % Set object properties
  f.setObjectProperties(pl, {'a', 'fs'});
  
end % End fromA
