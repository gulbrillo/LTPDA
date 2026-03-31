% Test abs() operator for AOs.
%
% M Hewitson 19-04-07
%
% $Id$
%
function test_abs()
  
  % Make test AOs
  
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'randn(size(t))');
  
  a1 = ao(pl);
  a1.setName('a1');
  
  % Take abs
  a2 = abs(a1);
  
  % Plot
  iplot(a1, a2, plist('YScales', 'lin'))
  
  % Rebuild it
  a3 = rebuild(a2);
  
  close all
end

% END