% Test cases for ao/plot

function test_ao_plot()
  %% Plot with no plotinfo
  
  plotinfo.resetStyles();
  a = ao(1:10);
  a = a.plot
  
  %% Plot with errors
  a = ao(1:10);
  a.setShowsErrors(true);
  a.setPlotMarker('x')
  a.setDy(0.5);
  
  a.plot
  
  %% Plot two objects with no plotinfo
  
  a = ao(1:10);
  b = ao(2:12);
  plot(a,b)
  
  %% Plot two objects with units
  
  a = ao(1:10);
  a.setYunits('m');
  b = ao(2:12);
  b.setYunits('m');
  plot(a,b)
  
  
  %% Plot two objects with specified colors
  
  a = ao(1:10);
  a.setPlotColor('m');
  b = ao(2:12);
  b.setPlotColor([0.3 0.5 0.24]);
  plot(a,b)
  
  %% Plot two objects with specified linestyles and colors
  
  a = ao(1:10);
  a.setPlotColor('m');
  a.setPlotLineStyle('--');
  b = ao(2:12);
  b.setPlotColor([0.3 0.5 0.24]);
  plot(a,b)
  
  %% Plot with a plotinfo object
  
  a = ao.randn(10,10);
  pi = plotinfo('-', 3, 'k', 'none', 10);
  a.setPlotinfo(pi);
  
  a.plot
  
  %% Plot two objects with specified plotinfo
  
  a = ao(1:10);
  a.setPlotinfo(plotinfo('-', 3, 'r', 's', 14))
  b = ao(2:12);
  b.setPlotColor([0.3 0.5 0.24]);
  plot(a,b)
  
  %% Plot two objects with specified linewidth
  
  a = ao(1:10);
  a.setPlotLinewidth(4)
  b = ao(2:12);
  b.setPlotColor([0.3 0.5 0.24]);
  plot(a,b)
  
  
  %% Plot two objects with specified markers
  
  plotinfo.resetStyles();
  
  a = ao(1:10);
  a.setPlotMarker('p')
  a.setPlotLineStyle('none')
  b = ao(2:12);
  b.setPlotMarker('x')
  
  [a,b] = plot(a,b)
  
  % make marker bigger
  set(b.plotinfo.line, 'markerSize', 30)
  
  %% Plot two objects with units and chosen styles
  
  a = ao(1:10);
  a.setYunits('m');
  a.setPlottingStyle(3);
  b = ao(2:12);
  b.setYunits('m');
  b.setPlottingStyle(6);
  plot(a,b)
  
  
  %% Plot two objects with different units
  
  a = ao(1:10);
  a.setYunits('m');
  b = ao(2:12);
  b.setYunits('V');
  plot(a,b)
  
  %% Plot three objects with different units
  
  a = ao(1:10);
  a.setYunits('m');
  b = ao(2:12);
  b.setYunits('V');
  c = ao(3:13);
  c.setYunits('N');
  plot(a,b,c)
  
  %% Plot the two objects on the same plot
  
  a = ao(1:10);
  b = ao(2:12);
  
  plotinfo.resetStyles();
  hfig = figure();
  a.setPlotFigure(hfig);
  b.setPlotFigure(hfig);
  
  plot(a,b)
  
  %% Close figures
  
  close all
  
  %% Plot two objects on different plots
  
  a = ao(1:10);
  b = ao(2:12);
  plotinfo.resetStyles();
  hfig1 = figure();
  hfig2 = figure();
  a.setPlotFigure(hfig1);
  b.setPlotFigure(hfig2);
  
  plot(a,b)
  
  
  %% Plot two objects on subplots
  
  plotinfo.resetStyles();
  
  a = ao(1:10);
  b = ao(2:12);
  
  figure
  ah(1) = subplot(121);
  ah(2) = subplot(122);
  
  a.setPlotAxes(ah(1));
  b.setPlotAxes(ah(2));
  
  plot(a,b)
  
  
  %% Complex cdata
  
  plotinfo.resetStyles();
  
  a = ao(complex(1:10, 1:10));
  
  % plot magnitude
  a.plot
  
  % plot real and imag
  figure
  ah(1) = subplot(211);
  ah(2) = subplot(212);
  a.setPlotAxes(ah);
  
  a.plot
  
  %% Plot xydata
  
  a = ao(1:10, 1:10);
  a.setName('my a')
  a.setDescription('a little xydata');
  a.plot
  
  %% Plot xydata with y errors
  
  a = ao(1:10, randn(10,1));
  a.setShowsErrors(true);
  a.setDy(0.5);
  
  a.plot
  
  %% Plot xydata with x and y errors
  
  a = ao(1:10, randn(10,1));
  a.setShowsErrors(true);
  a.setDx(0.1*a.x);
  a.setDy(0.1*a.y);
  
  a.plot
  
  
  %% Plot two xydata
  
  a = ao(1:10, 1:10);
  a.setName('my a')
  a.setDescription('a little xydata');
  
  b = ao(4:13, 1:10);
  
  plot(a,b)
  
  %% Plot two xydata with units
  
  a = ao(1:10, 1:10);
  a.setName('my a')
  a.setDescription('a little xydata');
  a.setYunits('m');
  a.setXunits('s');
  
  b = ao(4:13, 1:10);
  b.setYunits('m');
  b.setXunits('s');
  
  plot(a,b)
  
  %% Close figures
  
  close all
  
  %% Plot two xydata with different x units
  
  a = ao(1:10, 1:10);
  a.setName('my a')
  a.setDescription('a little xydata');
  a.setYunits('m');
  a.setXunits('s');
  
  b = ao(4:13, 1:10);
  b.setYunits('m');
  b.setXunits('V');
  
  plot(a,b)
  
  %% Plot two xydata with different y units
  
  a = ao(1:10, 1:10);
  a.setName('my a')
  a.setDescription('a little xydata');
  a.setYunits('m');
  a.setXunits('s');
  
  b = ao(4:13, 1:10);
  b.setYunits('V');
  b.setXunits('s');
  
  plot(a,b)
  
  %% Plot two xydata with different x y units
  
  a = ao(1:10, 1:10);
  a.setName('my a')
  a.setDescription('a little xydata');
  a.setYunits('m');
  a.setXunits('s');
  
  b = ao(4:13, 1:10);
  b.setYunits('V');
  b.setXunits('N');
  
  plot(a,b)
  
  %% Plot tsdata
  
  a = ao.randn(10,10);
  a.setYunits('m')
  a.setName('my ao')
  a.plot
  
  %% Plot two tsdata
  
  a = ao.randn(10,10);
  a.setYunits('m')
  a.setName('my ao')
  
  b = ao.randn(10,10);
  b.setYunits('V')
  b.setName('my ao 2')
  
  plot(a,b);
  
  %% Plot tsdata with y errors
  
  a = ao.randn(10,10);
  a.setYunits('m')
  a.setName('my ao')
  a.setShowsErrors(true);
  a.setDy(0.1*a.y);
  
  a.plot
  
  %% Close figures
  
  close all
  
  %% Plot tsdata with x and y errors
  
  a = ao.randn(10,10);
  a.setYunits('m')
  a.setName('my ao')
  a.setShowsErrors(true);
  a.setDx(0.1*a.x);
  a.setDy(0.1*a.y);
  
  a.plot
  
  %% Plot two objects with different t0
  
  plotinfo.resetStyles();
  
  a = ao.randn(10,10);
  a.setName();
  a.setT0('2012-04-04 12:00:00')
  a.setToffset(5)
  b = ao.randn(10,10);
  b.setName();
  b.setT0('2012-04-04 12:00:20')
  
  [a, b] = plot(a,b)
  
  %% Add another time-series to the last plot
  
  c = ao.randn(15,10);
  c.setT0('2012-04-04 12:00:10')
  c.setPlotAxes(a.plotinfo.axes);
  c.setName;
  
  c.plot
  
  %% And add another time-series to the last plot
  
  d = ao.randn(15,10);
  d.setT0('2012-04-04 11:59:50')
  d.setPlotAxes(a.plotinfo.axes);
  d.setName;
  
  d.plot
  
  %% And add another time-series to the last plot
  
  e = ao.randn(15,10);
  e.setT0('2012-04-04 12:00:30')
  e.setToffset(10);
  e.setPlotAxes(a.plotinfo.axes);
  e.setName;
  
  e.plot
  
  %% Plot two time-series with same y units
  
  plotinfo.resetStyles();
  
  a = ao.randn(10,10);
  a.setName();
  a.setYunits('m');
  b = ao.randn(10,10);
  b.setName();
  b.setYunits('m');
  
  plot(a,b)
  
  %% Close figures
  
  close all
  
  %% Plot two time-series with different y units
  
  plotinfo.resetStyles();
  
  a = ao.randn(10,10);
  a.setName();
  a.setYunits('m');
  b = ao.randn(10,10);
  b.setName();
  b.setYunits('V');
  
  plot(a,b)
  
  %% Plot real fsdata
  
  plotinfo.resetStyles();
  a = ao.randn(10,10);
  axx = sqrt(psd(a));
  
  axx.plot
  
  %% Plot two real fsdata
  
  
  plotinfo.resetStyles();
  a = ao.randn(10,10);
  b = ao.randn(10,10);
  axx = sqrt(psd(a));
  axx.setName
  bxx = sqrt(psd(b));
  bxx.setName
  
  plot(axx, bxx)
  
  %% Plot two real fsdata with same yunits
  
  plotinfo.resetStyles();
  a = ao.randn(10,10);
  a.setYunits('m');
  b = ao.randn(10,10);
  b.setYunits('m');
  axx = sqrt(psd(a));
  axx.setName
  bxx = sqrt(psd(b));
  bxx.setName
  
  plot(axx, bxx)
  
  %% Plot two real fsdata with different yunits
  
  plotinfo.resetStyles();
  a = ao.randn(10,10);
  a.setYunits('m');
  b = ao.randn(10,10);
  b.setYunits('V');
  axx = sqrt(psd(a));
  axx.setName
  bxx = sqrt(psd(b));
  bxx.setName
  
  plot(axx, bxx)
  
  %% Close figures
  
  close all
  
  %% Plot with errors
  
  plotinfo.resetStyles();
  a = ao.randn(10,10);
  a.setYunits('m');
  a.setShowsErrors(true);
  
  b = ao.randn(10,10);
  b.setYunits('V');
  b.setShowsErrors(false);
  
  psdpl = plist('navs', 4);
  axx = sqrt(psd(a, psdpl));
  axx.setName
  axx.setDx(0.1*axx.x);
  
  bxx = sqrt(psd(b, psdpl));
  bxx.setName
  
  plot(axx, bxx)
  
  %% Transfer function
  
  plotinfo.resetStyles();
  
  a = ao.randn(1000,10);
  f = miir(plist('type', 'lowpass', 'fc', 1, 'fs', 10));
  af = a.filter(f);
  out = af + 0.1*ao.randn(1000,10);
  
  T = tfe(a, out, plist('navs', 4));
  
  figure
  ah(1) = subplot(211);
  ah(2) = subplot(212);
  
  T.setPlotAxes(ah)
  
  T.plot
  
  %% Plot complex fsdata
  
  plotinfo.resetStyles();
  p = pzmodel(1, 1, 10);
  r = p.resp();
  r.plot
  
  %% Plot both mag and phase
  
  plotinfo.resetStyles();
  p = pzmodel(1, 1, 100);
  r = p.resp();
  
  figure
  ah(1) = subplot(211);
  ah(2) = subplot(212);
  
  r.setPlotAxes(ah);
  
  r.plot
  
  %% Plot two complex fsdata, both mag and phase
  
  plotinfo.resetStyles();
  
  p1 = pzmodel(1, 1, 100);
  p1.setIunits('m');
  p1.setOunits('V');
  r1 = p1.resp();
  
  p2 = pzmodel(1, 100, 1);
  r2 = p2.resp();
  
  figure
  ah(1) = subplot(211);
  ah(2) = subplot(212);
  r1.setPlotAxes(ah);
  r2.setPlotAxes(ah);
  
  plot(r1,r2)
  
  %% Complex plot
  
  a1 = ao.randn(100, 10);
  a1.setName();
  a2 = ao.randn(100, 10);
  a2.setName();
  
  % set plotinfo
  plotinfo.resetStyles();
  
  % compute PSDs
  [S_a1, S_a2] = psd(a1, a2);
  
  % make figure
  figure
  topLeft  = subplot('Position', [0.1 0.6 0.35 0.35]);
  topRight = subplot('Position', [0.55 0.6 0.35 0.35]);
  bottom   = subplot('Position', [0.1 0.12 0.8 0.35]);
  
  a1.setPlotAxes(topLeft);
  a2.setPlotAxes(topRight);
  S_a1.setPlotAxes(bottom);
  S_a2.setPlotAxes(bottom);
  
  plot(a1, a2, S_a1, S_a2)
  
  close all
end
