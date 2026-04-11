% Test script for ao/lincom
%
% $Id$
%

function test_ao_lincom
  %% Make some data
  ple = plist('Exceptions', {'created', 'proctime', 'UUID', 'methodInvars', 'plistUsed', 'ao/name'});
  
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
  
  % do linear combination: list + plist with pest
  yfit_01 = lincom(x1, x2, x3, plist('coeffs', p_m));
  r01 = yfit_01.rebuild();
  isequal(yfit_01, r01, ple)
  
  
  % do linear combination: list + plist with vector of cdata aos
  yfit_02 = lincom(x1, x2, x3, plist('coeffs', p_m.find));
  r02 = yfit_02.rebuild();
  isequal(yfit_02, r02, ple)
  
  % do linear combination: vector + plist with pest
  yfit_03 = lincom([x1, x2, x3], plist('coeffs', p_m));
  r03 = yfit_03.rebuild();
  isequal(yfit_03, r03, ple)
  
  % do linear combination: vector + plist with vector of cdata aos
  yfit_04 = lincom([x1, x2, x3], plist('coeffs', p_m.find));
  r04 = yfit_04.rebuild();
  isequal(yfit_04, r04, ple)
  
  % do linear combination: list + pest
  yfit_05 = lincom(x1, x2, x3, p_m);
  r05 = yfit_05.rebuild();
  isequal(yfit_05, r05, ple)
  
  % do linear combination: list + vector of cdata aos
  yfit_06 = lincom(x1, x2, x3, p_m.find);
  r06 = yfit_06.rebuild();
  isequal(yfit_06, r06, ple)
  
  % do linear combination: vector pest
  yfit_07 = lincom([x1, x2, x3], p_m);
  r07 = yfit_07.rebuild();
  isequal(yfit_07, r07, ple)
  
  % % do linear combination: vector + vector of cdata aos
  yfit_08 = lincom([x1, x2, x3], p_m.find);
  r08 = yfit_08.rebuild();
  isequal(yfit_08, r08, ple)
  
  %% Make some data
  fs    = 10;
  nsecs = 10;
  B1 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'T'));
  B2 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'T'));
  B3 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'T'));
  n  = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'm'));
  c = ao([1 2 3], plist('yunits','m/T'));
  
  % do linear combination: list + cdata ao with coefficients
  yfit_11 = lincom(B1, B2, B3, c);
  r11 = yfit_11.rebuild();
  isequal(yfit_11, r11, ple)
  
  % do linear combination: vector + cdata ao with coefficients
  yfit_12 = lincom([B1, B2, B3], c);
  r12 = yfit_12.rebuild();
  isequal(yfit_12, r12, ple)
  
  % do linear combination: list + plist with vector of double
  yfit_13 = lincom(B1, B2, B3, plist('coeffs', p_m.y));
  r13 = yfit_13.rebuild();
  isequal(yfit_13, r13, ple)
  
  % do linear combination: vector + plist with vector of double
  yfit_14 = lincom([B1, B2, B3], plist('coeffs', p_m.y));
  r14 = yfit_14.rebuild();
  isequal(yfit_14, r14, ple)
  
  close all
end
