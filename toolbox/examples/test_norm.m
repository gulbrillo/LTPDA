% Test ao.norm method.
%
% A Monsky 09-05-07
%
% $Id$
%
function test_norm()
  
  % make test data
  testmat = [1 2 3; 4 5 6; 7 8 9; 10 11 12];
  
  % Load data into analysis objects
  a1 = ao(testmat);
  a1.setName('a1');
  
  % Create plist
  pl  = plist('option', 'fro');
  pl1 = plist('option', 1); % it is the 1-norm of X, the largest column sum, = max(sum(abs(X))).
  
  % Calculate norm
  a2 = norm(a1, pl);
  a3 = norm(a1, pl1);
  
  % Plot
  iplot(a1, a2, a3, plist('Markers', {'o', 'o', 'o'}))
  
  close all
end

% END
