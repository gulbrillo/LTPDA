% Test functionality of analysis objects.
%
%
% M Hewitson 01-02-07
%
% $Id$
%
function test_ao_1()
  
  % Make test AOs
  
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'randn(size(t))');
  
  a1 = ao(pl);
  a2 = ao(pl);
  a3 = ao(pl);
  
  % Add the two analysis objects
  
  a4 = a3+a2;
  a5 = a4+a1;
  
  %% Plot both
  
  % Rebuid
  a_out = a5.rebuild;
  
  iplot(a_out)
  
  close all
end
