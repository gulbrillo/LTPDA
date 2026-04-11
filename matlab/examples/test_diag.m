% Tests ao.diag method.
%
% A Monsky 09-05-07
%
% $Id$
%
function test_diag()
  
  % make test data files
  testmat = [0 2 3; 4 5 6; 7 8 10];
  
  % Load data into analysis objects
  a1 = ao(testmat);
  a1.setName;
  
  % Create plist
  pl = plist('option', 1);
  
  % Calculate diagonal
  a2 = diag(a1, pl);
  
  % Plot
  iplot(a1, a2)
  
  close all
end
% END
