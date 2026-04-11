% TEST_AO_INTERP tests the interp method of AO class.
%
% M Hewitson 05-06-07
%
% $Id$
%
function test_ao_interp()
  
  % Make fake AO from polyval
  nsecs = 100;
  fs    = 10;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*1.733*t)');
  a1 = ao(pl);
  
  % Interpolate on a new time vector
  t = linspace(0, a1.data.nsecs - 1/a1.data.fs, 2*len(a1));
  pl = plist('vertices', t);
  
  b = interp(a1, pl);
  
  iplot([a1 b], plist('Markers', {'x', 'o'}, 'LineColors', {'k'}, 'XRanges', [0 1]));
  
  
  % Reproduce from history
  a_out = rebuild(b);
  
  iplot(a_out)
  
  close all
end
% END
