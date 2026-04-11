function test_iplot_2


  %% When cdata contains a matrix
  c  = ao(randn(10,10));
  c1 = ao(randn(10,10));
  c2 = ao(randn(10,10));


  iplot(c, plist('Markers', 'o', 'LineStyles', '--'))

  %% When cdata is complex

  c = ao(complex(randn(1,100), randn(1,100)));

  iplot(c, plist('LineStyles', 'none', 'Markers', 'x'))

  %% Time-series with different start times

  pl = plist('waveform', 'sine wave', 'f', 0.1, 'fs', 10, 'nsecs', 20);
  a1 = ao(pl);
  a1 = a1.setT0('2008-01-01 12:00:00.5');
  a2 = ao(pl);
  a2 = a2.setT0('2008-01-01 12:00:10');

  iplot(a1,a2, plist('arrangement', 'stacked'))
  iplot(a1,a2, plist('arrangement', 'subplots'))
  iplot(a1,a2, plist('arrangement', 'single'))

  %% Set XRange for time-series

  iplot(a1,a2, plist('arrangement', 'stacked', 'XRanges', [0 12]))
  iplot(a1,a2, plist('arrangement', 'subplots', 'XRanges', {[0 12], [15 20]}))

  %% Set YRanges for time-series

  iplot(a1,a2, plist('arrangement', 'stacked', 'YRanges', [0 1]))
  iplot(a1,a2, plist('arrangement', 'subplots', 'YRanges', {[-1 1], [-2 2]}))

  %% Set XRange for cdata

  iplot(c, plist('arrangement', 'stacked', 'XRanges', [0 12]))
  iplot(c, c, plist('arrangement', 'subplots', 'XRanges', {[0 1], [1 2]}))

  %% Set YRange for cdata

  iplot(c, plist('arrangement', 'stacked', 'YRanges', [0 1]))
  iplot(c, c, plist('arrangement', 'subplots', 'YRanges', {[-1 1], [-2 2]}))

  %% Test 'all' line properties for cdata

  iplot(c1, c1, plist('linecolors', {'ALL', 'c'}))
  iplot(c1, c2, plist('linewidths', {'all', 4}))
  iplot(c1, c2, plist('linestyles', {'all', '--'}))
  iplot(c1, c2, plist('Markers', {'All', 'x'}))

  %% Test 'all' axes properties for tsdata

  iplot(c1, c2, plist('Yscales', {'All', 'lin'}))
  iplot(abs(c1), abs(c2), plist('arrangement', 'subplots', 'Yscales', {'All', 'log'}))
  iplot(c1, c2, plist('arrangement', 'subplots', 'Xscales', {'All', 'lin'}))
  iplot(c1, c2, plist('arrangement', 'subplots', 'YRanges', {'All', [-3 10]}))

  %% Test 'all' line properties for tsdata

  iplot(a1, a2, plist('linecolors', {'ALL', 'c'}))
  iplot(a1, a2, plist('linewidths', {'all', 4}))
  iplot(a1, a2, plist('linestyles', {'all', '--'}))
  iplot(a1, a2, plist('Markers', {'All', 'x'}))

  %% Test 'all' axes properties for tsdata

  iplot(a1, a2, plist('Yscales', {'All', 'lin'}))
  iplot(abs(a1), abs(a2), plist('arrangement', 'subplots', 'Yscales', {'All', 'log'}))
  iplot(a1, a2, plist('arrangement', 'subplots', 'Xscales', {'All', 'lin'}))
  iplot(a1, a2, plist('arrangement', 'subplots', 'YRanges', {'All', [-3 10]}))

  %% Test 'all' line properties for fsdata

  fsd1 = resp(miir(plist('type','lowpass','fs', 100)), plist('f', logspace(-4, log10(50), 1000)));
  fsd1 = fsd1.setYunits('m V^-1');
  fsd2 = psd(a1+a2);
  fsd3 = fsd2*10;
  fsd4 = resp(miir(plist('type', 'highpass')));
  fsd4 = fsd4.setYunits('m V^-1');


  iplot(fsd1, fsd2, fsd3, fsd4, plist('linecolors', {'ALL', 'c'}))
  iplot(fsd1, fsd2, fsd3, fsd4, plist('linewidths', {'all', 4}))
  iplot(fsd1, fsd2, fsd3, fsd4, plist('linestyles', {'all', '--'}))
  iplot(fsd1, fsd2, fsd3, fsd4, plist('Markers', {'All', 'x'}))

  %% Test 'all' axes properties for fsdata

  iplot(fsd1, fsd2, fsd3, fsd4, plist('Yscales', {'All', 'lin'}))
  iplot(fsd1, fsd2, fsd3, fsd4, plist('arrangement', 'subplots', 'Yscales', {'All', 'log'}))
  iplot(fsd1, fsd2, fsd3, fsd4, plist('arrangement', 'subplots', 'Xscales', {'All', 'lin'}))
  iplot(fsd1, fsd2, fsd3, fsd4, plist('arrangement', 'subplots', 'YRanges', {'All', [1e-6 100]}))

  close all
end
