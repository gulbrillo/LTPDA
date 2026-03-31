% Test the ao/filter function for the miir class.
%
%
% M Hewitson 11-02-07
%
% $Id$
%
function test_miir_filter()
  
  % make a bandpass filter
  pl = plist('type', 'bandpass', 'fs', 1000, 'fc', [5 100], 'order', 3);
  f  = miir(pl)
  
  % Make an analysis object
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', '5+randn(size(t))');
  
  a1 = ao(pl);
  
  % Filter the input data
  a2 = filter(a1,plist('filter', f));
  
  % Plot time-series
  iplot(a1, a2)
  
  % Make PSDs of input and output
  nfft = a1.data.fs;
  w = specwin('Hanning', nfft);
  pl = plist('Win', w, 'Nfft', nfft);
  a3 = psd(a1, pl);
  a4 = psd(a2, pl);
  
  % Plot PSDs
  iplot(a3, a4)
  
  % Make amplitude ratio
  a5 = a4./a3;
  
  iplot(a5)
  
  % Reproduce from history
  a_out = rebuild(a5);
  
  iplot(a_out)
  
  close all
end
