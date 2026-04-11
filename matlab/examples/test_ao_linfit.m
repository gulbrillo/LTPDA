% TEST_AO_LINFIT tests the linfit method of the AO class.
%
% M Hueller 02-03-10
%
% $Id$
%
function test_ao_linfit()
  
  
  %% Make fake AO from polyval
  nsecs = 100;
  fs    = 10;
  
  unit_list = unit.supportedUnits;
  u1 = unit(cell2mat(utils.math.randelement(unit_list,1)));
  u2 = unit(cell2mat(utils.math.randelement(unit_list,1)));
  
  pl1 = plist('nsecs', nsecs, 'fs', fs, ...
    'tsfcn', 'polyval([10 1], t) + randn(size(t))', ...
    'xunits', 's', 'yunits', u1);
  
  pl2 = plist('nsecs', nsecs, 'fs', fs, ...
    'tsfcn', 'polyval([-5 0.2], t) + randn(size(t))', ...
    'xunits', 's', 'yunits', u2);
  
  a1 = ao(pl1);
  a2 = ao(pl2);
  a = scatterData(a1, a2);
  
  %% Fit with a straight line
  
  p11 = linfit(a1, plist(...
    ));
  p12 = linfit(a1, plist(...
    'dy', 0.1));
  p22 = linfit(a1, plist(...
    'dx', 0.1, 'dy', 0.1, 'P0', [0 0]));
  p13 = linfit(a1, plist(...
    'dy', 0.1*ones(size(a1.y))));
  p23 = linfit(a1, plist(...
    'dx', 0.1*ones(size(a1.x)), 'dy', 0.1*ones(size(a1.y)), 'P0', [0 0]));
  p14 = linfit(a1, plist(...
    'dy', ao(0.1, plist('yunits', a1.yunits))));
  p24 = linfit(a1, plist(...
    'dx', ao(0.1, plist(...
    'yunits', a1.xunits)), 'dy', ao(0.1, plist('yunits', a1.yunits)), 'P0', [0 0]));
  p15 = linfit(a1, plist(...
    'dy', ao(0.1*ones(size(a1.y)), plist('yunits', a1.yunits))));
  p25 = linfit(a1, plist(...
    'dx', ao(0.1*ones(size(a1.x)), plist('yunits', a1.xunits)), 'dy', ao(0.1*ones(size(a1.y)), plist('yunits', a1.yunits)), 'P0', [0 0]));
  p26 = linfit(a1, plist(...
    'dx', 0.1, 'dy', 0.1, 'P0', ao([0 0])));
  p27 = linfit(a1, plist(...
    'dx', 0.1, 'dy', 0.1, 'P0', p11));
  
  %% Compute fit: evaluating pest
  
  b11 = p11.eval(plist('type', 'tsdata', 'XData', a1, 'xfield', 'x'));
  b12 = p12.eval(plist('XData', a1, 'xfield', 'x'));
  b22 = p22.eval(a1, plist('xfield', 'x'));
  b13 = p13.eval(plist('XData', a1, 'xfield', 'x'));
  b23 = p23.eval(a1, plist('type', 'tsdata', 'xfield', 'x'));
  b14 = p14.eval(plist('XData', a1, 'xfield', 'x'));
  b24 = p24.eval(a1, plist('type', 'tsdata', 'xfield', 'x'));
  b15 = p15.eval(a1, plist('xfield', 'x'));
  b25 = p25.eval(plist('XData', a1, 'xfield', 'x'));
  b26 = p26.eval(plist('type', 'tsdata', 'XData', a1.x));
  b27 = p27.eval(plist('type', 'tsdata', 'XData', a1.x));
  
  %% Plot fit
  iplot(a1, b11, b12, b13, b14, b15, b26, b27, ...
    b22, b23, b24, b25, ...
    plist('LineStyles', {'', '--'}));
  
  %% Remove linear trend
  c = a1-b11;
  iplot(c)
  
  %% Reproduce from history
  disp('Try rebuilding')
  a_out = rebuild(c);
  iplot(a_out)
  
  %% Fit with a straight line
  
  p = linfit(a, plist(...
    ));
  
  %% Compute fit: evaluating pest
  
  b1 = p.eval(plist('XData', a, 'xfield', 'x'));
  b2 = p.eval(a, plist('xfield', 'x'));
  b3 = p.eval(plist('type', 'xydata', 'XData', a.x, 'xunits', a.xunits));
  b4 = p.eval(plist('XData', a.x, 'xunits', a.xunits));
  
  %% Plot fit
  iplot(a, b1, b2, b3, b4,  ...
    plist('LineStyles', {'', '--'}));
  
  %% Fit with a straight line
  
  p11 = linfit(a1, a2, plist(...
    ));
  p12 = linfit(a1, a2, plist(...
    'dy', 0.1));
  p22 = linfit(a1, a2, plist(...
    'dx', 0.1, 'dy', 0.1, 'P0', [0 0]));
  p13 = linfit(a1, a2, plist(...
    'dy', 0.1*ones(size(a1.x))));
  p23 = linfit(a1, a2, plist(...
    'dx', 0.1*ones(size(a1.x)), 'dy', 0.1*ones(size(a1.x)), 'P0', [0 0]));
  p14 = linfit(a1, a2, plist(...
    'dy', ao(0.1, plist('yunits', a2.yunits))));
  p24 = linfit(a1, a2, plist(...
    'dx', ao(0.1, plist('yunits', a1.yunits)), 'dy', ao(0.1, plist('yunits', a2.yunits)), 'P0', [0 0]));
  p15 = linfit(a1, a2, plist(...
    'dy', ao(0.1*ones(size(a2.y)), plist('yunits', a2.yunits))));
  p25 = linfit(a1, a2, plist(...
    'dx', ao(0.1*ones(size(a1.y)), plist('yunits', a1.yunits)), 'dy', ao(0.1*ones(size(a2.y)), plist('yunits', a2.yunits)), 'P0', [0 0]));
  p26 = linfit(a1, a2, plist(...
    'dx', 0.1, 'dy', 0.1, 'P0', ao([0 0])));
  p27 = linfit(a1, a2, plist(...
    'dx', 0.1, 'dy', 0.1, 'P0', p11));
  
  %% Compute fit: evaluating pest
  
  b11 = p11.eval(plist('type', 'xydata', 'XData', a1.y, 'xunits', a1.yunits));
  b12 = p12.eval(plist('type', 'xydata', 'XData', a1.y, 'xunits', a1.yunits));
  b22 = p22.eval(a1, plist('type', 'xydata'));
  b13 = p13.eval(plist('type', 'xydata', 'XData', a1.y, 'xunits', a1.yunits));
  b23 = p23.eval(a1, plist('type', 'xydata'));
  b14 = p14.eval(plist('type', 'xydata', 'XData', a1.y, 'xunits', a1.yunits));
  b24 = p24.eval(a1, plist('type', 'xydata'));
  b15 = p15.eval(a1, plist('type', 'xydata'));
  b25 = p25.eval(plist('type', 'xydata', 'XData', a1.y));
  b26 = p26.eval(plist('type', 'xydata', 'XData', a1.y));
  b27 = p27.eval(plist('type', 'xydata', 'XData', a1.y));
  
  % Build reference object
  a12 = ao(plist('xvals', a1.y, 'yvals', a2.y, ...
    'xunits', a1.yunits, 'yunits', a2.yunits));
  %% Plot fit
  iplot(b22, b23, b24, b15, ...
    b12, b13, b14, b11, ...
    plist('LineStyles', {'', '--'}));
  
  %% Plot fit
  iplot(b25, b26, b27, ...
    plist('LineStyles', {'', '--'}));
  
  %% Remove linear trend
  c = a12-b27;
  iplot(c)
  
  %% Reproduce from history
  disp('Try rebuilding')
  a_out = rebuild(c);
  iplot(a_out)
  
  close all
end
