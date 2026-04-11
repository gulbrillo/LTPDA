% TEST_AO_POLYFIT tests the polyfit method of the AO class.
%
% M Hewitson 05-06-07
%
% $Id$
%
function test_ao_polyfit()
  
  
  %% Make fake AO from polyval
  nsecs = 100;
  fs    = 10;
  
  unit_list = unit.supportedUnits;
  u = unit(cell2mat(utils.math.randelement(unit_list,1)));
  
  pl = plist('nsecs', nsecs, 'fs', fs, ...
    'tsfcn', 'polyval([3 2 1 ], t) + 1000*randn(size(t))', ...
    'xunits', 's', 'yunits', u);
  
  a1 = ao(pl);
  
  %% Fit a polynomial
  N = 3;
  p1 = polyfit(a1, plist('N', N));
  p2 = polyfit(a1, plist('N', N, 'rescale', true));
  
  
  %% Compute fit: from polyval
  
  b1 = ao(plist('polyval', p1, 't', a1, 'xunits', a1.xunits));
  b2 = ao(plist('polyval', p2, 't', a1, 'xunits', a1.xunits));
  
  %% Plot fit
  iplot(a1, b1, plist('LineStyles', {'', '--'}));
  
  %% Remove polynomial
  c = a1-b1;
  iplot(c)
  
  %% Reproduce from history
  disp('Try rebuilding')
  a_out = rebuild(c);
  iplot(a_out)
  
  %% Compute fit: evaluating pest
  
  b11 = p1.eval(a1, plist('type', 'tsdata', 'xfield', 'x'));
  b21 = p2.eval(plist('type', 'tsdata', 'XData', a1, 'xfield', 'x'));
  
  %% Plot fit
  iplot(a1, b11, b21, plist('LineStyles', {'all','-'}));
  
  close all
end
% END
