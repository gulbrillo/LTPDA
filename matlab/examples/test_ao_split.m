% Test AO split method.
%
% M Hewitson 02-03-07
%
% $Id$
%
function test_ao_split()
  
  % Make test AOs
  
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'randn(size(t))');
  
  a1 = ao(pl);
  a1 = a1.setName;
  
  % Split by time
  times = [0.0 1.0 1.0 2.5 2.0 3.0];
  pl = plist('times', times);
  b = split(a1, pl);
  
  % Plot
  
  iplot(a1, b)
  
  b1 = b(2);
  
  % Recreate from history
  a_out = rebuild(b(1));
  
  iplot(a_out)
  
  % Construct an AO
  a1 = ao(plist('waveform', 'sine', 'f', 0.1, 'a', 1, 'fs', 10, 'nsecs', 10));
  
  % This should just remove the first data point
  a2 = split(a1, plist('offsets', [0.05 0]));
  
  % Check
  assert(all(a2.y == a1.y(2:end)));
  assert(all(((a2.x + a2.t0.double) - (a1.x(2:end) + a1.t0.double)) < 2*eps(a2.x)));
  
  iplot(a1, a2, plist('markers', {'+','+'}));
  
  close all
end
% END
