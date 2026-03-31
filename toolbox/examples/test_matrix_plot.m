function test_matrix_plot()
  
  %% Plot 2x1
  
  a = ao.randn(10,10);
  b = ao.randn(10,10);
  a.setName;
  b.setName;
  
  m = matrix(a, b)
  size(m.objs)
  
  % plot
  m.plot
  
  %% Plot 2x2
  
  a1 = ao.randn(10,10);
  a1.setName;
  
  a2 = ao.randn(10,10);
  a2.setName;
  
  a3 = ao.randn(10,10);
  a3.setName;
  
  a4 = ao.randn(10,10);
  a4.setName;
  
  % create a 2x2 matrix
  m1 = matrix([a1 a2; a3 a4])
  
  m1.plot
  
  %% Plot two 2x2 on different figures
  
  a1 = ao.randn(10,10);
  a1.setName;
  
  a2 = ao.randn(10,10);
  a2.setName;
  
  a3 = ao.randn(10,10);
  a3.setName;
  
  a4 = ao.randn(10,10);
  a4.setName;
  
  % create a 2x2 matrix
  m1 = matrix([a1 a2; a3 a4])
  m2 = matrix([a2 a4; a3 a1])
  
  hfig(1) = figure;
  hfig(2) = figure;
  
  m1.setPlotFigure(hfig(1));
  m2.setPlotFigure(hfig(2));  
  
  plot(m1, m2);
  
  %% Plot two 2x2 on different axes
  
  a1 = ao.randn(10,10);
  a1.setName;
  
  a2 = ao.randn(10,10);
  a2.setName;
  
  a3 = ao.randn(10,10);
  a3.setName;
  
  a4 = ao.randn(10,10);
  a4.setName;
  
  % create a 2x2 matrix
  m1 = matrix([a1 a2; a3 a4])
  m2 = matrix([a2 a4; a3 a1])
  
  hfig(1) = figure;
  ax(1) = subplot(211);
  ax(2) = subplot(212);
  
  m1.setPlotAxes(ax(1));
  m2.setPlotAxes(ax(2));  
  
  plot(m1, m2);
  
  %% Plot 2x1 with collections
  
  a1 = ao.randn(10,10);
  a1.setName;
  
  a2 = ao.randn(10,10);
  a2.setName;
  
  a3 = ao.randn(10,10);
  a3.setName;
  
  c1 = collection(a1)
  c2 = collection(a2, a3);
  
  m = matrix([c1; c2])
  
  m.plot
  
  %% Plot 3x2
  
  for kk=1:6
    a(kk) = ao.randn(10,10);
    a(kk).setName(sprintf('Object %d', kk));
  end
  
  m = matrix(a, plist('shape', [3 2]));
  m.plot
  
  %% Plot 2x3
  
  for kk=1:6
    a(kk) = ao.randn(10,10);
    a(kk).setName(sprintf('Object %d', kk));
  end
  
  m = matrix(a, plist('shape', [2 3]));
  m.plot
  
  %% Plot 2x2 with collections
  
  for kk=1:6
    a(kk) = ao.randn(10,10);
    a(kk).setName(sprintf('Object %d', kk));
  end
  
  c1 = collection(a(1:2))
  c2 = collection(a(3))
  c3 = collection(a(4))
  c4 = collection(a(5:6));
  
  m = matrix([c1 c2; c3 c4]);
  
  m.plot
  
  close all
end

