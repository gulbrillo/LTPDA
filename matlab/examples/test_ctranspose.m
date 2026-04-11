% Test ctranspose() operator for AOs.
%
% A Monsky 09-05-07
%
% $Id$
%
function test_ctranspose()
  
  
  % make test data files
  testmat=[1 2 3; 4 5 6; 7 8 9; 10 11 12i];
  
  % Load data into analysis objects
  a1 = ao(testmat);
  a1 = a1.setName;
  
  
  % Calc complex conjugate transpose
  a2 = ctranspose(a1);
  
  % Plot
  iplot(a1, a2, plist('Markers', {'s', 's'}))
  
  close all
end
% END