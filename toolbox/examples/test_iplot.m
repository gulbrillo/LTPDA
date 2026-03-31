% TEST_IPLOT test some aspects of iplot.
% 
% M Hewitson
% 
% $Id$
% 
function test_iplot()

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %         TSDATA OBJECTS
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Make test AOS

  p      = plist('waveform', 'noise', 'fs', 10, 'nsecs', 10);
  tsao1  = ao(p);
  p      = plist('waveform', 'sine wave', 'fs', 10, 'nsecs', 10, 'f', 1, 'phi', 0);
  tsao2  = ao(p);

  tsvec = [tsao1 tsao2];
  tsmat = [tsao1 tsao2; tsao1 tsao2];

  %% Default plot
  iplot(tsao1, tsao2)
  iplot(tsvec)
  iplot(tsmat)

  %% Change X units
  
  p   = plist('waveform', 'noise', 'fs', 1, 'nsecs', 100000);
  a1  = ao(p);
  
  pl  = plist('Xunits', 'h');
  iplot(a1, pl)
  
  pl  = plist('Xunits', 'D');
  iplot(a1, pl)
  
  %% Try with datetick
  
  p   = plist('waveform', 'noise', 'fs', 0.01, 'nsecs', 6*3600);
  a1  = ao(p);
  a1.setT0('1980-01-01 12:00:00');
  
  pl  = plist('Xunits', 'dd HH:MM:SS');
  iplot(a1, pl)
  
  
  %% Change colors and line styles

  pl = plist('Linecolors', {'g', 'k'}, 'LineStyles', {'', '--'}, 'LineWidths', {2, 4});
  iplot(tsao1, tsao2, pl);

  %% Change arrangement to single plots

  pl = plist('Arrangement', 'single');
  iplot(tsao1, tsao2, pl);

  %% Change arrangement to subplots

  % Also override the second legend text and the first line style
  pl = plist('Arrangement', 'subplots', 'LineStyles', {'--'}, 'Legends', {'', 'My Sine Wave'});
  iplot(tsao1, tsao2, pl);

  %% Change ylabel

  % Overide the Y-labels
  pl = plist('Arrangement', 'subplots', 'YLabels', {'signal 1', 'signal 2'}, 'Legends', {'', 'My Sine Wave'});
  iplot(tsao1, tsao2, pl);

  %% Change xlabel

  % Overide the X-labels
  pl = plist('Arrangement', 'subplots', 'XLabels', {'', 'Time-stamps'}, 'Legends', {'', 'My Sine Wave'});
  iplot(tsao1, tsao2, pl);

  %% No legends

  pl = plist('Arrangement', 'subplots', 'Legends', 'off');
  iplot(tsao1, tsao2, pl);

  %% Change legends

  pl = plist('Arrangement', 'subplots', 'Legends', {'ts1', 'ts2'});
  iplot(tsao1, tsao2, pl);
  
  %% Check math functions
  iplot(tsao1, tsao2);
  iplot(tsao1.^2, (log(tsao2, plist('axis', 'x'))).^2);
  
  %% Change Y limits
  pl = plist('Arrangement', 'subplots', 'YRanges', {[-5 10], [-2 2]});
  iplot(tsao1, tsao2, pl);
  
  %% Change X limits
  pl = plist('Arrangement', 'subplots', 'XRanges', {[1 3], [2 5]});
  iplot(tsao1, tsao2, pl);
  
  %% Change Y Scales
  pl = plist('Arrangement', 'subplots', 'YScales', {'log', 'log'});
  iplot(abs(tsao1), abs(tsao2), pl);
  
  %% Use markers
  
  pl = plist('Markers', {'s', 'x'});
  iplot(tsao1, tsao2, pl);
  
  %% Clean-up
  close all
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %         FSDATA OBJECTS
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% Make test AOs

  fsd1 = resp(miir(plist('type','lowpass','fs', 100)), plist('f', logspace(-4, log10(50), 1000)));
  fsd1 = fsd1.setYunits('m V^-1');
  fsd2 = psd(tsao1+tsao2);
  fsd3 = fsd2*10;
  fsd4 = resp(miir(plist('type', 'highpass')));
  fsd4 = fsd4.setYunits('m V^-1');

  %% Default plot

  iplot(fsd1, fsd2, fsd3, fsd4)

  %% Subplots

  pl = plist('Arrangement', 'subplots');
  iplot(fsd1, fsd2, fsd3, fsd4, pl)

  %% Single plots

  pl = plist('Arrangement', 'single');
  iplot(fsd1, fsd2, fsd3, fsd4, pl)

  %% Use math function on y-data

  iplot(abs(fsd1));
  iplot(abs(fsd1, fsd2));


  %% Change colors and line styles

  pl = plist('Colors', {'g', 'k', 'm'}, 'LineStyles', {'--'}, 'LineWidths', {2, 4});
  iplot(fsd1, fsd2, pl);

  %% Use markers
  pl = plist('Colors', {'g', 'k', 'm'}, 'Markers', {'', 's'});
  iplot(fsd1, fsd2, pl);
  
  %% Change arrangement to subplots

  % Also override the second legend text and the first line style
  pl = plist('Arrangement', 'subplots', 'LineStyles', {'--'}, 'Legends', {'', 'My Sine Wave'});
  iplot(fsd1, fsd2, pl);

  %% Changel ylabel

  % Overide the Y-labels
  pl = plist('Arrangement', 'subplots', 'YLabels', {'signal 1 mag', '', 'signal 2'}, 'Legends', {'', 'My Sine Wave'});
  iplot(fsd1, fsd2, pl);

  %% Changel xlabel

  % Overide the X-labels
  pl = plist('Arrangement', 'subplots', 'XLabels', {'', 'Freq'}, 'Legends', {'', 'My Sine Wave'});
  iplot(fsd1, fsd2, pl);

  %% Change legends

  pl = plist('Arrangement', 'subplots', 'Legends', {'fsd1', 'fsd2'});
  iplot(fsd1, fsd2, pl);
  
  %% No legends

  pl = plist('Arrangement', 'subplots', 'Legends', 'off');
  iplot(fsd1, fsd2, pl);

  %% Set Y scales

  pl = plist('Arrangement', 'subplots', 'YScales', {'', 'log', 'lin'});
  iplot(fsd1, fsd2, pl);

  %% Set X scales

  pl = plist('Arrangement', 'subplots', 'XScales', {'', 'lin', 'lin'});
  iplot(fsd1, fsd2, pl);

  %% Set Y ranges

  pl = plist('Arrangement', 'subplots', 'YRanges', {[0.1 10], [], [1e-3 100]});
  iplot(fsd1, fsd2, pl);


  %% Set X ranges
  pl = plist('Arrangement', 'subplots', 'YRanges', [0.001, 10], 'XRanges', {[0.1 10], [0 10], [0.1 10]});
  iplot(fsd1, fsd2, pl);

  %% Clean-up
  close all
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %         XYDATA OBJECTS
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% Make test AOs

  xy1  = ao(xydata(1:100, cos([1:100]/10)));
  xy1  = xy1.setXunits('arb');
  xy1  = xy1.setYunits('arb');
  xy2  = ao(xydata(1:100, sin([1:100]/3)));
  xy2  = xy2.setXunits('arb');
  xy2  = xy2.setYunits('arb');


  %% Default plot
  iplot(xy1, xy2)

  %% Use Math function on y-data and x-data
  iplot(log(abs(xy1), xy2.^2, plist('axis', 'x')));


  %% Change colors and line styles

  pl = plist('Colors', {'g', 'k', 'm'}, 'LineStyles', {'--'}, 'LineWidths', {2, 4});
  iplot(xy1, xy2, pl);

  %% Change arrangement to single plots

  pl = plist('Arrangement', 'single');
  iplot(xy1, xy2, pl);

  %% Change arrangement to subplots

  % Also override the second legend text and the first line style
  pl = plist('Arrangement', 'subplots', 'LineStyles', {'--'}, 'Legends', {'', 'My Sine Wave'});
  iplot(xy1, xy2, pl);

  %% Changel ylabel

  % Overide the Y-labels
  pl = plist('Arrangement', 'subplots', 'YLabels', {'signal 1', 'signal 2'}, 'Legends', {'', 'My Sine Wave'});
  iplot(xy1, xy2, pl);

  %% Changel xlabel

  % Overide the X-labels
  pl = plist('Arrangement', 'subplots', 'XLabels', {'', 'Time-stamps'}, 'Legends', {'', 'My Sine Wave'});
  iplot(xy1, xy2, pl);

  %% No legends

  pl = plist('Arrangement', 'subplots', 'Legends', 'off');
  iplot(xy1, xy2, pl);

 %% Clean-up
  close all

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %         CDATA OBJECTS
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  %% Make test AOS

  c1  = ao(randn(1,10));
  c2  = ao(1:10);


  %% Default plot
  iplot(c1, c2)

  %% Change colors and line styles

  pl = plist('Colors', {'g', 'k', 'm'}, 'LineStyles', {'--'}, 'LineWidths', {2, 4});
  iplot(c1, c2, pl);

  %% Change arrangement to single plots

  pl = plist('Arrangement', 'single');
  iplot(c1, c2, pl);

  %% Change arrangement to subplots

  % Also override the second legend text and the first line style
  pl = plist('Arrangement', 'subplots', 'LineStyles', {'--'}, 'Legends', {'', 'My Sine Wave'}, 'Markers', {'x', 's'});
  iplot(c1, c2, pl);

  %% Changel ylabel

  % Overide the Y-labels
  pl = plist('Arrangement', 'subplots', 'YLabels', {'signal 1', 'signal 2'}, 'Legends', {'', 'My Sine Wave'});
  iplot(c1, c2, pl);

  %% Changel xlabel

  % Overide the X-labels
  pl = plist('Arrangement', 'subplots', 'XLabels', {'', 'Time-stamps'}, 'Legends', {'', 'My Sine Wave'});
  iplot(c1, c2, pl);

  %% No legends

  pl = plist('Arrangement', 'subplots', 'Legends', 'off');
  iplot(c1, c2, pl);

  %% Change legends

  pl = plist('Arrangement', 'subplots', 'Legends', {'c1', 'c2'});
  iplot(c1, c2, pl);
  
  %% Y math
  
  pl = plist('Arrangement', 'subplots');
  iplot(c1.^2, abs(c2), pl);
  
  %% X Scale
  pl = plist('Arrangement', 'subplots', 'XScales', {'log', 'log'});
  iplot(c1, c2, pl);
  
  %% Y Scale
  pl = plist('Arrangement', 'subplots', 'YScales', {'log', 'log'});
  iplot(abs(c1), abs(c2), pl);
  
  %% Y range
  pl = plist('Arrangement', 'subplots', 'YRanges', {[-5 5], [-1 12]});
  iplot(c1, c2, pl);
  
  %% X range
  pl = plist('Arrangement', 'subplots', 'XRanges', {[2 4], [1 6]});
  iplot(c1, c2, pl);
  
  %% Clean-up
  close all
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %         XYZ DATA OBJECTS
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% Test data
  nsecs = 100;
  fs    = 100;
  p     = plist('waveform', 'noise', 'fs', fs, 'nsecs', nsecs);
  n     = ao(p);
  p     = plist('waveform', 'chirp', 'fs', fs, 'nsecs', nsecs, 'f0', 0, 'f1', 50, 't1', nsecs);
  s     = ao(p);
  
  a = s+n;
  
  % Make spectrogram
  
  sxx = spectrogram(a, plist('Nfft', 4*fs));
  rxx = spectrogram(s, plist('Nfft', 4*fs));
  
  %% Plot
  
  pl = plist('Arrangement', 'subplots', 'YMaths', {'log10(y)', 'log10(y)'}, ...
            'Zmaths', {'20*log10(z)', '20*log10(z)'}, ...
            'Xmaths', {'log10(x)'});
  iplot(sxx, rxx, pl)


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %         MIXED OBJECTS
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% XY and TSDATA
  iplot(xy1, tsao1, xy2, tsao2, c1)
  close all

end
