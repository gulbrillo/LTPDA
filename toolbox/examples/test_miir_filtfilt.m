% Test the filtfilt function for the miir class.
%
%
% M Hewitson 02-03-07
%
% $Id$
%
function test_miir_filtfilt()
  
  % make a bandpass filter
  pl = plist('type', 'bandpass', 'fs', 1000, 'fc', [50 100], 'order', 3);
  f  = miir(pl);
  
  % Make an analysis object
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'randn(size(t))');
  
  a1 = ao(pl);
  
  % Filter the input data
  a2 = filtfilt(a1, plist('filter', f));
  
  % Plot time-series
  iplot(a1, a2)
  
  % Make TF
  a3 = tfe(a1,a2);
  b  = a3;
  
  % Plot TF
  iplot(b)
  
  % Reproduce from history
  a_out = rebuild(b);
  
  iplot(a_out)
  
  close all
end
