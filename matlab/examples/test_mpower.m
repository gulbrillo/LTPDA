% A test script for the AO mpower.
%
% M Hewitson 16-03-07
%
% $Id$
%
function test_mpower()
  
  
  % Load data into analysis objects
  a1 = ao(randn(10,10));
  
  % square and plot
  a3  = a1^2;
  iplot(a3, plist('Markers', 'o'))
  
  % Reproduce from history
  a_out = rebuild(a3);
  
  iplot(a_out,'o')
  
  close all
end

