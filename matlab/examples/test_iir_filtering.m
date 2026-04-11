% A test script to test some IIR filtering commands.
%
% M Hewitson
%
% $Id$
%
function test_iir_filtering()
  
  
  % Make test AOs
  
  nsecs = 10000;
  fs    = 10;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))');
  
  a1 = ao(pl);
  a1.setName('a1');
  
  % Load bandpass
  pl = plist('type', 'bandpass', 'fc', [0.003 0.03], 'order', 2);
  bp = miir(pl);
  
  % Filter data and remove startup transients
  
  % parameter list for split()
  % to remove startup transient of filters
  spl = plist('offsets', [1000 -1]);
  
  % parameter list for filter()
  fpl = plist('filter', bp);
  
  % filter and split data
  a1f = split(filter(a1, fpl), spl);
  
  % Plot
  iplot(a1, a1f)
  
  close all
end

% END