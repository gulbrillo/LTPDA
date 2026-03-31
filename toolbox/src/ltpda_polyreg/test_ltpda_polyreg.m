% function test_ltpda_polydetrend()
% A test script for the AO implementation of detrending.
%
% M Hewitson 02-02-07
%
% $Id$
%

clear all;

for N = -1:3
      
  Nsecs = 100000;
  
  %% Make test AOs
  
  pl1 = plist('waveform', 'sine wave', 'f', 0.1/Nsecs, 'nsecs', Nsecs, 'fs', 10);
  pl2 = plist('waveform', 'noise', 'nsecs', Nsecs, 'fs', 10);
  a = ao(pl1) + 0.01.*ao(pl2);
  iplot(a)
  
  %% Detrend with MATLAB
  
  pl = plist('N', N);
  tic
  c = detrend(a, pl);
  toc
  c.setName('matlab');
  
  %% Detrend with mex
  
  tic
  [y, a] = ltpda_polyreg(a.data.y, N);
  toc
  
  ts = c.data;
  ts.setY(y);
  d = ao(ts);
  d.setName('mex');
  
  
  %% Plot
  
  iplot(c,d);
  iplot(c./d)
end
