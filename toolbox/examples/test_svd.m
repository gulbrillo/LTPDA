% Test ao.svd method.
%
% A Monsky 09-05-07
%
% $Id$
%
function test_svd()
  
  
  % make test data files
  testmat = [1 2 3; 4 5 6; 7 8 9; 10 11 12];
  
  % Load data into analysis objects
  a1 = ao(testmat);
  a1.setName('a1');
  
  % Create plist
  pl = plist('option', 'econ');
  pl1 = plist('option', 0);
  
  % Calculate svd
  u = svd(a1, pl);  % produces the "economy size" decomposition (see help svd)
  u = svd(a1, pl1);
  
  % Plot
  iplot(u)
  
  close all
end

% END
