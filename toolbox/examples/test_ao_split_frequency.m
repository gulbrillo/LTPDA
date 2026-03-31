% Test splitting a frequency-series AO by frequency using the split method.
%
% M Hewitson 02-03-07
%
% $Id$
%
function test_ao_split_frequency()
  
  % Make test AOs
  
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'sin(2*pi*7.433*t) + randn(size(t))');
  
  a1 = ao(pl);
  
  % Make spectrum
  a1xx = psd(a1);
  
  % Split by frequency
  freqs = [10 100];
  pl = plist('frequencies', freqs);
  b = split(a1xx, pl);
  
  
  % Plot
  iplot(a1xx, b)
  
  % Recreate from history
  a_out = rebuild(b);
  
  iplot(a_out)
  
  close all
end

% END
