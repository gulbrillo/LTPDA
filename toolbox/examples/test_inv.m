% Tests ao.inv method.
%
% A Monsky 09-05-07
%
% $Id$
%
function test_inv()
  
  % make test data files
  testmat = [0 2 3; 4 5 6; 7 8 10];
  
  % Load data into analysis objects
  a1 = ao(testmat);
  a1.setName;
  
  % Calculate inverse
  a2 = inv(a1);
  
  % Plot
  iplot(a1, a2)
  
  close all
end
% END
