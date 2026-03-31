% Some iplot tests using the plotinfo
%

function test_iplot_3
  %% tsdata
  
  p      = plist('waveform', 'noise', 'fs', 10, 'nsecs', 10);
  tsao1  = ao(p);
  tsao1.setPlotinfo(plist('linestyle', '--', 'color', 'm', 'linewidth', 3, 'marker', 'x'));
  
  p      = plist('waveform', 'sine wave', 'fs', 10, 'nsecs', 10, 'f', 1, 'phi', 0);
  tsao2  = ao(p);
  tsao2.setPlotinfo(plist('linestyle', '-.', 'color', [0.1 0.1 0.9], 'linewidth', 1, 'marker', 'none'));
  
  
  ppl = plist('Linecolors', {'g', 'k'}, 'LineStyles', {'', '--'}, 'LineWidths', {1, 4});
  
  iplot(tsao1,tsao2)
  iplot(tsao1,tsao2, ppl)
  
  tsao1.setPlotinfo(plist)
  tsao2.setPlotinfo(plist)
  
  iplot(tsao1,tsao2, ppl)
  
  tsao2.setPlotinfo(plist('legend_on', false))
  
  iplot(tsao1,tsao2, ppl)
  
  
  
  %% fsdata
  
  fsd1 = resp(miir(plist('type','lowpass','fs', 100)), plist('f', logspace(-4, log10(50), 1000)));
  fsd1 = fsd1.setYunits('m V^-1');
  fsd1.setPlotinfo(plist('linestyle', '-.', 'color', [0.1 0.1 0.9], 'linewidth', 3, 'marker', ''));
  
  fsd2 = psd(tsao1+tsao2);
  fsd2.setPlotinfo(plist('linestyle', '-.', 'color', 'k', 'linewidth', 2, 'marker', '^'));
  
  fsd3 = fsd2*10;
  
  fsd4 = resp(miir(plist('type', 'highpass')));
  fsd4 = fsd4.setYunits('m V^-1');
  
  iplot(fsd1, fsd2, fsd3)
  
  fsd3.setPlotinfo(plist('legend_on', false))
  
  iplot(fsd1, fsd2, fsd3)
  
  
  
  %% xydata
  
  xy1  = ao(xydata(1:100, cos([1:100]/10)));
  xy1  = xy1.setXunits('arb');
  xy1  = xy1.setYunits('arb');
  xy1.setPlotinfo(plist('linestyle', '--', 'color', [0.1 0.1 0.9], 'linewidth', 2, 'marker', 'd'));
  
  xy2  = ao(xydata(1:100, sin([1:100]/3)));
  xy2  = xy2.setXunits('arb');
  xy2  = xy2.setYunits('arb');
  xy2.setPlotinfo(plist('linestyle', '', 'color', [], 'linewidth', 1, 'marker', ''));
  
  iplot(xy1, xy2)
  
  xy2.setPlotinfo(plist('legend_on', false))
  
  iplot(xy1, xy2)
  
  
  %% cdata
  
  cd1 = ao(1:100);
  cd1.setPlotinfo(plist('linestyle', '-', 'color', [], 'linewidth', 3, 'marker', ''));
  
  cd2 = ao(1:100);
  cd2.setPlotinfo(plist('linestyle', '', 'color', 'y', 'linewidth', 1, 'marker', 'o'));
  
  iplot(cd1,cd2)
  
  cd1.setPlotinfo(plist('legend_on', false))
  iplot(cd1,cd2)
  
  %% Bar plot
  
  x1 = ao(plist('built-in','whitenoise','nsecs',100,'fs',1));
  x2 = 0.3*ao(plist('built-in','whitenoise','nsecs',100,'fs',1));
  x2.setPlotColor('m');
  
  hpl = plist('x', -5:0.5:5);
  iplot(hist(x1, x2, hpl),plist('function','bar'));
  
  %% Set figure names
  
  iplot(x1, x2, plist('FigureNames', 'My Nice Figure'));
  iplot(x1, x2, plist('FigureNames', {'My Nice Figure'}));
  
  
  iplot(x1, x2, plist('arrangement', 'single', 'FigureNames', {'My Nice Figure'}))
  
  iplot(x1, x2, plist('arrangement', 'single', ...
    'FigureNames', {'Fig1', 'Fig2'}))
  
  close all
end
