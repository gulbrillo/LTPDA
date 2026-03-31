% Tests for ao/linedetect
%
% $Id$
%

function test_ao_linedetect
  %% Data production
  
  % Select how many and which lines to put on
  Nlines = 6;
  f = [0.002 0.123 0.00765 0.02 0.09 0.0041];
  A = [1:1:Nlines];
  
  % Sampling rate, duration, units
  fs = 1;
  nsecs = 10000;
  yunits = 'T';
  
  % Prepare the input time-series data as: noise + signals
  an = ao(plist('waveform', 'noise', 'sigma', 0.05, 'nsecs', nsecs, 'fs', fs, 'yunits', yunits));
  al = ao(plist('waveform', 'sine', 'f', f, 'A', A, 'nsecs', nsecs, 'fs', fs, 'yunits', yunits));
  a = al + an;
  
  
  %% Data analysis
  
  % evaluate the PSD of the time-series
  s = a.psd;
  
  % check the lines are in the spectrum
  iplot(s)
  
  %% run the linedetect method
  
  l = linedetect(s, plist('N', 5, 'fsearch',[0 fs/2],'bw', 20, 'hc', 0.9));
  l.x
  
  close all
end
