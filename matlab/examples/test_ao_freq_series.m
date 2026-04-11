function test_ao_freq_series
  
  % Test script for frequency series AO constructor
  %
  % M Hewitson 23-02-08
  %
  % $Id$
  %
  
  %% default plist
  pl = plist('fsfcn', '1e-15.*(1e-3./f.^2 + 1e-10./f.^4)', 'nf', 100, 'yunits', 'm Hz^-1');
  
  a1 = ao(pl);
  iplot(a1, plist('Markers', 'x'))
  
  %% Specify frequency scale
  
  pl = plist('fsfcn', '1./f.^2', 'scale', 'lin', 'nf', 100, 'yunits', 'm K^-1');
  a1 = ao(pl);
  iplot(a1, plist('Markers', 'x'))
  
  close all
end
