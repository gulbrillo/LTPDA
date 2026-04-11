function test_collection_plot()
  
  %% Plot 4 AOs
  
  a = ao.randn(10,10);
  b = ao.randn(10,10);
  c = ao.randn(10,10);
  d = ao.randn(10,10);
  
  c = collection(a, b, c, d);
  
  c.plot
  
  %% Plot 2 collections on subplots
  
  a = ao.randn(10,10);
  b = ao.randn(10,10);
  c = ao.randn(10,10);
  d = ao.randn(10,10);
  
  c1 = collection(a, b);
  c2 = collection(c, d);
  
  figure
  ah(1) = subplot(211);
  ah(2) = subplot(212);
  
  c1.setPlotAxes(ah(1));
  c2.setPlotAxes(ah(2));
  
  plot(c1, c2)
  
  %% Plot 2 collections on different figures
  
  a = ao.randn(10,10); a.setName;
  b = ao.randn(10,10); b.setName;
  c = ao.randn(10,10); c.setName;
  d = ao.randn(10,10); d.setName;
  
  c1 = collection(a, b);
  c2 = collection(c, d);
  
  hfig(1) = figure;
  hfig(2) = figure;
  
  c1.setPlotFigure(hfig(1));
  c2.setPlotFigure(hfig(2));
  
  plot(c1, c2)  
  
  
  %% Plot an AO and a fit
  
  fs    = 10;
  nsecs = 10;
  x1 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'm'));
  x2 = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'm'));
  n  = ao(plist('tsfcn', 'randn(size(t))', 'fs', fs, 'nsecs', nsecs, 'yunits', 'm'));
  c = [ao(1,plist('yunits','m/m')) ao(2,plist('yunits','m/m'))];
  y = c(1)*x1 + c(2)*x2 + n;
  y.simplifyYunits;
  
  % Get a fit for the c coefficients and a constant term
  p = bilinfit(x1, x2, y)
  
  % set the xvals
  p.setXvals(x1, x2)
  
  % collection
  c = collection(y, p)
  
  % plot
  c.plot
  
  
  %% Plot PSD and pzmodel
  
  p = pzmodel(1, [0.1 1], 10, unit('m'), unit('V'));
  a = ao(p, plist('fs', 50, 'nsecs', 1000));
  axx = a.psd(plist('scale', 'as'));
  
  c = collection(axx, p);
  
  c.plot
  
  close all
end
