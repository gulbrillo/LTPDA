% Test ao/bilinfit for:
% - functionality
% - against lscov
%
% M Hueller and D Nicolodi 07-01-10
%
% $Id$
%
function test_ao_bilinfit()
  
  
  %% test bilinfit vs lscov
  disp(' ************** ');
  disp('Example with combination of noise terms');
  disp('  ');
  fs    = 10;
  nsecs = 10;
  x1 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'T'));
  x2 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'T'));
  n  = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'm'));
  c = [ao(1,plist('yunits','m/T')) ao(2,plist('yunits','m/T'))];
  y = c(1)*x1 + c(2)*x2 + n;
  y.simplifyYunits;
  
  % Get a fit for c, using lscov (no constant term)
  disp('Using ao/lscov, no constant term');
  disp('  ');
  p_lscov = lscov(x1, x2, y);
  disp('  ');
  p_lscov.y
  disp('  ');
  
  % do linear combination
  yfit_lscov = lincom(x1, x2, p_lscov);
  
  % Get a fit for c, using bilinfit
  disp('Using ao/bilinfit');
  disp('  ');
  p_b = bilinfit(x1, x2, y);
  disp('  ');
  p_b.y
  disp('  ');
  disp(' ************** ');
  
  % do linear combination: use direct sum
  yfit_b1 = simplifyYunits(x1 * find(p_b, 'P1') + x2 * find(p_b, 'P2') + find(p_b, 'P3'));
  % do linear combination: use eval
  yfit_b2 = p_b.eval(plist('Xdata', {x1, x2}));
  
  % Plot (compare data with fit)
  iplot(y, yfit_lscov, yfit_b1, yfit_b2, plist('Linestyles', {'all','-'}))
    
  %% test with uncertainties
  fprintf('\n\n\n');
  
  fs    = 1;
  nsecs = 50;
  x1 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'C'));
  x2 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'm'));
  n  = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'N'));
  c = ao(plist('xvals', x1.x, 'yvals', ones(size(x1.y)), 'type', 'tsdata'));
  b = [ao(1,plist('yunits','N/C')) ao(2,plist('yunits','N/m'))];
  y = b(1)*x1 + b(2)*x2 + n;
  y.simplifyYunits();
  
  p_m = lscov(x1, x2, c, y, plist('weights', ao(plist('vals', 1./(ones(size(x1.x)))))));
  fprintf('AO LSCOV: Fit results: A = %f +/- %f, B = %f +/- %f, Y0 = %f +/- %f\n', ...
    p_m.y(1), p_m.dy(1)./sqrt(find(p_m.procinfo, 'mse')), ...
    p_m.y(2), p_m.dy(2)./sqrt(find(p_m.procinfo, 'mse')), ...
    p_m.y(3), p_m.dy(3)./sqrt(find(p_m.procinfo, 'mse')));
  
  % do linear combination: using linear combination
  yfit1 = simplifyYunits(x1 * find(p_m, 'C1') + x2 * find(p_m, 'C2') + find(p_m, 'C3'));
  
  % do linear combination: using eval
  yfit2 = p_m.eval(plist('Xdata',{x1, x2, c}));
  
  % Plot (compare data with fit)
  iplot(y, yfit1, yfit2, plist('Linestyles', {'-','--'}))
  
  fprintf('UTN BILINFIT:\n');
  try
    [p, perr] = bilinfit(y.y, x1.y, x2.y, ones(size(x1.x)));
  catch err
    disp(err.message);
    disp('UTN method bilinfit.m for double not available');
  end
  [x,stdx,mse] = lscov([c.y, x1.y, x2.y], y.y, 1./(ones(size(x1.x))));
  fprintf('M LSCOV: Fit results: A = %f +/- %f, B = %f +/- %f, Y0 = %f +/- %f\n', ...
    x(2), stdx(2)*sqrt(1/mse), ...
    x(3), stdx(3)*sqrt(1/mse), ...
    x(1), stdx(1)*sqrt(1/mse));
  
  p_b = bilinfit(x1, x2, y, plist('dy', ao(plist('vals', ones(size(x1.x)), 'yunits', 'N'))));
  fprintf('BILINFIT: Fit results: A = %f +/- %f, B = %f +/- %f, Y0 = %f +/- %f\n', ...
    p_b.y(1), p_b.dy(1), ...
    p_b.y(2), p_b.dy(2), ...
    p_b.y(3), p_b.dy(3));
  
  %% very simple test
  x1 = ao(plist('xvals', [1 2 3], 'yvals', [1 2 3]));
  x2 = ao(plist('xvals', [1 2 3], 'yvals', [6 4 7]));
  y  = x1 + x2;
  c = ao(plist('xvals', x1.x, 'yvals', ones(size(x1.y)), 'type', 'tsdata'));
  
  % Fit with UTN double/bilinfit
  fprintf('UTN BILINFIT:\n');
  try
    [p, perr] = bilinfit(y.y, x1.y, x2.y, ones(size(x1.x)));
  catch err
    disp(err.message);
    disp('UTN method bilinfit.m for double not available');
  end
  
  % Fit with Matlab lscov
  [x,stdx,mse] = lscov([c.y, x1.y, x2.y], y.y, 1./(ones(size(x1.x))));
  fprintf('M LSCOV: Fit results: A = %f +/- %f, B = %f +/- %f, Y0 = %f +/- %f\n', ...
    x(2), stdx(2)*sqrt(1/mse), ...
    x(3), stdx(3)*sqrt(1/mse), ...
    x(1), stdx(1)*sqrt(1/mse));
  
  % Fit with LTPDA ao/bilinfit
  [x] = bilinfit(x1, x2, y, plist('dy', ao(plist('vals', ones(size(x1.x))))));
  fprintf('BILINFIT: Fit results: A = %f +/- %f, B = %f +/- %f, Y0 = %f +/- %f\n', ...
    x.y(1), x.dy(1), ...
    x.y(2), x.dy(2), ...
    x.y(3), x.dy(3));
  
  %% More tests about format of inputs
  
  %% Make fake AO
  nsecs = 100;
  fs    = 10;
  
  unit_list = unit.supportedUnits;
  u1 = unit(cell2mat(utils.math.randelement(unit_list,1)));
  u2 = unit(cell2mat(utils.math.randelement(unit_list,1)));
  u3 = unit(cell2mat(utils.math.randelement(unit_list,1)));
  
  pl1 = plist('nsecs', nsecs, 'fs', fs, ...
    'tsfcn', 'randn(size(t))', ...
    'yunits', u1);
  
  pl2 = plist('nsecs', nsecs, 'fs', fs, ...
    'tsfcn', 'randn(size(t))', ...
    'yunits', u2);
  
  pl3 = plist('nsecs', nsecs, 'fs', fs, ...
    'tsfcn', 'randn(size(t))', ...
    'yunits', u3);
  
  x1 = ao(pl1);
  x2 = ao(pl2);
  x3 = ao(pl3);
  
  n  = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'm'));
  c = [ao(1,plist('yunits', unit('m')/u1)) ao(2,plist('yunits', unit('m')/u2)) ao(3,plist('yunits', unit('m')/u3))];
  y = c(1)*x1 + c(2)*x2 + c(3)*x3 + n;
  y.simplifyYunits;
  
  %% Fit with bilinfit
  
  p11 = bilinfit(x1, x2, x3, y, plist(...
    ));
  p12 = bilinfit(x1, x2, x3, y, plist(...
    'dy', 0.1 ...
    ));
  p22 = bilinfit(x1, x2, x3, y, plist(...
    'dx', [0.1 0.1 0.1], ...
    'dy', 0.1, ...
    'P0', [0 0 0 0]));
  p13 = bilinfit(x1, x2, x3, y, plist(...
    'dy', ao(0.1, plist('yunits', y.yunits)) ...
    ));
  p23 = bilinfit(x1, x2, x3, y, plist(...
    'dx', [ao(0.1, plist('yunits', x1.yunits)) ...
    ao(0.1, plist('yunits', x2.yunits)) ...
    ao(0.1, plist('yunits', x3.yunits))], ...
    'dy', ao(0.1, plist('yunits', y.yunits)), ...
    'P0', [0 0 0 0]));
  p14 = bilinfit(x1, x2, x3, y, plist(...
    'dy', ao(0.1*ones(size(x1.y)), plist('yunits', y.yunits)) ...
    ));
  p24 = bilinfit(x1, x2, x3, y, plist(...
    'dx', [ao(0.1*ones(size(x1.x)), plist('yunits', x1.yunits)) ...
    ao(0.1*ones(size(x2.x)), plist('yunits', x2.yunits)) ...
    ao(0.1*ones(size(x3.x)), plist('yunits', x3.yunits))], ...
    'dy', ao(0.1*ones(size(x1.y)), plist('yunits', y.yunits)), ...
    'P0', [0 0 0 0]));
  p25 = bilinfit(x1, x2, x3, y, plist(...
    'dx', [0.1 0.1 0.1], ...
    'dy', 0.1, ...
    'P0', ao([0 0 0 0])));
  p26 = bilinfit(x1, x2, x3, y, plist(...
    'dx', [0.1 0.1 0.1], ...
    'dy', 0.1, ...
    'P0', p11));
  
  %% Compute fit: evaluating pest
  
  b11  = p11.eval(plist('XData', {x1, x2, x3}));
  b12  = p12.eval(x1, x2, x3);
  b22  = p22.eval(plist('XData', {x1.y, x2.y, x3.y}));
  b23  = p23.eval(plist('XData', [x1 x2 x3]));
  b24  = p24.eval(x1, x2, x3);
  b25  = p25.eval(plist('XData', {x1, x2, x3}));
  b26  = p26.eval([x1 x2 x3]);

  close all
end
