% Test transpose() operator for AOs.
%
% A Monsky 09-05-07
%
% $Id$
%
function test_transpose()
  
  
  % make test data files
  testmat=[1 2 3; 4 5 6; 7 8 9];
  
  % Load data into analysis objects
  a1 = ao(testmat);
  a1 = a1.setName('a1');
  
  % Calc transpose
  a2 = transpose(a1);
  
  % Plot
  iplot([a1 a2])
  
  close all
end

% END