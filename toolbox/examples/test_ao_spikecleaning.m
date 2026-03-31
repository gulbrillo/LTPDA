% A test script for the spikecleaning method
%
% J Sanjuan 26-01-08
%
% $Id$
%
function test_ao_spikecleaning()
  
  % Make test AOs
  nsecs = 1e4;
  fs    = 1;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*1.433*t) + randn(size(t))');
  
  a1 = ao(pl);
  
  % Make spike cleaning of each
  
  % parameters list
  pl = plist('kspike', 1, 'method', 'mean');
  
  % use spike cleaning
  a3 = spikecleaning(a1); % default parameters list
  a4 = spikecleaning(a1, pl);
  
  % Plot (a1,a3)
  iplot(a1,a3)
  
  % Plot (a1,a4)
  iplot(a1,a4)
  
  % Reproduce from history
  a_out = rebuild(a3);
  a_out2 = rebuild(a4);
  
  close all
end
