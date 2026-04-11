% Tests conj() operator for AOs.
%
% A Monsky 09-05-07
%
% $Id$
%
function test_conj()
    
  % make test complex data
  td = complex(randn(10,1), randn(10,1));
  
  % Load data into analysis objects
  a1 = ao(td);
  a1.setName;
  
  % Calc complex conjugate
  a2 = conj(a1);
  
  % Plot
  iplot(real(a1), real(a2), imag(a1), imag(a2), plist('Markers', {'All', 'o'}))
  
  close all
end
% END