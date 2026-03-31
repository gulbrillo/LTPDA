% Test making simulated data AOs.
%
% M Hewitson 17-03-07
%
% $Id$
%
function test_simulated_data()
  
  % Make some simulated data
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))');
  a = ao(pl);
  iplot(a);
  
  close all
end


% END
