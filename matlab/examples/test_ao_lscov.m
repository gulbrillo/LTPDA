% TEST_AO_LSCOV tests the lscov method of the AO class.
%
% M Hueller 19-03-10
%
% $Id$
%
function test_ao_lscov()
  
  %% 1) Determine the coefficients of a linear combination of noises:
  %
  % Make some data
  fs    = 10;
  nsecs = 10;
  B1 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'T'));
  B2 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'T'));
  B3 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'T'));
  n  = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'm'));
  c = [ao(1,plist('yunits','m/T')) ao(2,plist('yunits','m/T')) ao(3,plist('yunits','m T^-1'))];
  y = c(1)*B1 + c(2)*B2 + c(3)*B3 + n;
  y.simplifyYunits;
  % Get a fit for c
  p_s = lscov(B1, B2, B3, y);
  % do linear combination: using lincom
  yfit1 = lincom(B1, B2, B3, p_s);
  yfit1.simplifyYunits;
  % do linear combination: using eval
  yfit2 = p_s.eval(B1, B2, B3);
  
  % Plot (compare data with fit)
  iplot(y, yfit1, yfit2, plist('Linestyles', {'-','--'}))
  
  %% 2) Determine the coefficients of a linear combination of noises:
  %
  % Make some data
  fs    = 10;
  nsecs = 10;
  x1 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'T'));
  x2 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'm'));
  x3 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'C'));
  n  = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'm'));
  c = [ao(1,plist('yunits','m/T')) ao(2,plist('yunits','m/m')) ao(3,plist('yunits','m C^-1'))];
  y = c(1)*x1 + c(2)*x2 + c(3)*x3 + n;
  y.simplifyYunits;
  % Get a fit for c
  p_m = lscov(x1, x2, x3, y);
  % do linear combination: using lincom
  yfit1 = lincom(x1, x2, x3, p_m);
  % do linear combination: using eval
  pl_split = plist('times', [1 5]);
  yfit2 = p_m.eval(plist('Xdata', {split(x1, pl_split), split(x2, pl_split), split(x3, pl_split)}));
  % Plot (compare data with fit)
  iplot(y, yfit1, yfit2, plist('Linestyles', {'-','--'}))
  
  close all
  
end
