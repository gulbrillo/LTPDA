% A test script for the ao.gapfilling method
%
% J Sanjuan 28-01-08
%
% $Id$
%
function test_ao_gapfilling()
  
  % Make test AOs
  % stationary data
  nsecs = 1e4;
  fs    = 1;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'randn(size(t))');
  
  a1 = ao(pl);
  a1.setName('a1');
  
  % non-stationary data
  pl = plist();
  pl.append('nsecs', nsecs, 'fs', fs, 'tsfcn', '0.001*t + randn(size(t))');
  
  a2 = ao(pl);
  a2.setName('a2');
  
  % non-stationary data (ii)
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', 'exp(t/2.5e3) + randn(size(t))');
  
  a3 = ao(pl);
  a3.setName('a3');
  
  % Split by time the previous data
  pl = plist('split_type', 'times', 'times', [0.0 6000.0 6000.0 8999 8999 1e4]);
  
  b1 = split(a1, pl);
  
  Ta_stat = b1(1);
  Tc_stat = b1(3);
  
  b2 = split(a2, pl);
  
  Ta_nonstat = b2(1);
  Tc_nonstat = b2(3);
  
  b3 = split(a3, pl);
  
  Tx = b3(1);
  Ty = b3(3);
  
  % Use gapfilling
  % parameters list
  pl = plist('method', 'spline');
  pl = plist('addnoise', 'yes');
  
  % stationary data, a1
  a1_refilled = gapfilling(Ta_stat, Tc_stat) % default parmeters
  a1_refilled_spline = gapfilling(Ta_stat, Tc_stat, pl); % using pl
  
  % non-stationary data, a2
  a2_refilled = gapfilling(Ta_nonstat, Tc_nonstat) % default parmeters
  a2_refilled_spline = gapfilling(Ta_nonstat, Tc_nonstat, pl); % using pl
  
  % non-stationary data, a3
  a3_refilled = gapfilling(Tx, Ty) % default parmeters
  a3_refilled_spline = gapfilling(Tx, Ty, pl); % using pl
  
  % Plotting
  iplot(a1, a1_refilled, a1_refilled_spline);
  iplot(a2, a2_refilled, a2_refilled_spline);
  iplot(a3_refilled, a3_refilled_spline);
  
  % Reproduce from history
  a_out = rebuild(a1_refilled);
  a_out2 = rebuild(a2_refilled);
  
  iplot(a_out);
  
  close all
end
