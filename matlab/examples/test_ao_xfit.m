% Tests for xfit
%
% $Id$
%

function test_ao_xfit
  
  %% Case 1: Fit with function in plist
  % Fit to a frequency-series
  
  % Create a frequency-series
  datapl = plist('fsfcn', '0.01./(0.0001+f) + 5*abs(randn(size(f))) ', 'f1', 1e-5, 'f2', 5, 'nf', 1000, ...
    'xunits', 'Hz', 'yunits', 'N/Hz');
  data = ao(datapl);
  data.setName;
  
  % Do fit
  fitpl = plist('Function', 'P(1)./(P(2) + Xdata) + P(3)', ...
    'P0', [0.1 0.01 1]);
  params = xfit(data, fitpl);
  
  % Evaluate model
  BestModel = eval(params, plist('type','fsdata','xdata',data,'xfield','x'));
  BestModel.setName;
  
  % Display results
  iplot(data,BestModel)
  
  %% Case 2: Fit with function in plist
  
  % Create a noisy sine-wave
  fs    = 10;
  nsecs = 500;
  datapl = plist('waveform', 'Sine wave', 'f', 0.01, 'A', 0.6, 'fs', fs, 'nsecs', nsecs, ...
    'xunits', 's', 'yunits', 'm');
  sw = ao(datapl);
  noise = ao(plist('tsfcn', '0.01*randn(size(t))', 'fs', fs, 'nsecs', nsecs));
  data = sw+noise;
  data.setName;
  
  % Do fit
  fitpl = plist('Function', 'P(1).*sin(2*pi*P(2).*Xdata + P(3))', ...
    'P0', [1 0.01 0]);
  params = xfit(data, fitpl);
  
  % Evaluate model
  BestModel = eval(params, plist('type','tsdata','xdata',data,'xfield','x'));
  BestModel.setName;
  
  % Display results
  iplot(data,BestModel)
  
  %% Case 3: Fit with smodel
  
  % Fit an smodel of a straight line to some data
  
  % Create a noisy straight-line
  datapl = plist('xyfcn', '2.33 + 0.1*x + 0.01*randn(size(x))', 'x', 0:0.1:10, ...
    'xunits', 's', 'yunits', 'm');
  data = ao(datapl);
  data.setName;
  
  % Model to fit
  mdl = smodel('a + b*x');
  mdl.setXvar('x');
  mdl.setParams({'a', 'b'}, {1 2});
  
  % Fit model
  fitpl = plist('Function', mdl, 'P0', [1 1]);
  params = xfit(data, fitpl);
  
  % Evaluate model
  BestModel = eval(params,plist('xdata',data,'xfield','x'));
  BestModel.setName;
  
  % Display results
  iplot(data,BestModel)
  
  %% Case 4: Fit with smodel:
  % Fit a chirp-sine firstly starting from an initial guess (quite close
  % to the true values) (bad convergency) and secondly by a Monte Carlo
  % search (good convergency)
  
  % Create a noisy chirp-sine
  fs    = 10;
  nsecs = 1000;
  
  % Model to fit and generate signal
  mdl = smodel(plist('name', 'chirp', 'expression', 'A.*sin(2*pi*(f + f0.*t).*t + p)', ...
    'params', {'A','f','f0','p'}, 'xvar', 't', 'xunits', 's', 'yunits', 'm'));
  
  % signal
  s = mdl.setValues({10,1e-4,1e-5,0.3});
  s.setXvals(0:1/fs:nsecs-1/fs);
  signal = s.eval;
  signal.setName;
  
  % noise
  noise = ao(plist('tsfcn', '1*randn(size(t))', 'fs', fs, 'nsecs', nsecs));
  
  % data
  data = signal + noise;
  data.setName;
  
  % Fit model from the starting guess
  fitpl_ig = plist('Function', mdl, 'P0',[8,9e-5,9e-6,0]);
  params_ig = xfit(data, fitpl_ig);
  
  % Evaluate model
  BestModel_ig = eval(params_ig,plist('xdata',data,'xfield','x'));
  BestModel_ig.setName;
  
  % Display results
  iplot(data,BestModel_ig)
  
  % Fit model by a Monte Carlo search
  fitpl_mc = plist('Function', mdl, ...
    'MonteCarlo', 'yes', 'Npoints', 1000, 'LB', [8,9e-5,9e-6,0], 'UB', [11,3e-4,2e-5,2*pi]);
  params_mc = xfit(data, fitpl_mc);
  
  % Evaluate model
  BestModel_mc = eval(params_mc,plist('xdata',data,'xfield','x'));
  BestModel_mc.setName;
  
  % Display results
  iplot(data,BestModel_mc)
  
  %% Case 5: Fit multichannel with smodel
  
  % Ch.1 data
  datapl = plist('xyfcn', '0.1*x + 0.01*randn(size(x))', 'x', 0:0.1:10, 'name', 'channel 1', ...
    'xunits', 'K', 'yunits', 'Pa');
  a1 = ao(datapl);
  % Ch.2 data
  datapl = plist('xyfcn', '2.5*x + 0.1*sin(2*pi*x) + 0.01*randn(size(x))', 'x', 0:0.1:10, 'name', 'channel 2', ...
    'xunits', 'K', 'yunits', 'T');
  a2 = ao(datapl);
  
  % Model to fit
  mdl1 = smodel('a*x');
  mdl1.setXvar('x');
  mdl1.setParams({'a'}, {1});
  mdl1.setXunits('K');
  mdl1.setYunits('Pa');
  
  mdl2 = smodel('b*x + a*sin(2*pi*x)');
  mdl2.setXvar('x');
  mdl2.setParams({'a','b'}, {1,2});
  mdl2.setXunits('K');
  mdl2.setYunits('T');
  
  % Fit model
  params = xfit(a1,a2, plist('Function', [mdl1,mdl2]));
  
  % evaluate model
  b = eval(params, plist('index',1,'xdata',a1,'xfield','x'));
  b.setName('fit Ch.1');
  r = a1-b;
  r.setName('residuals');
  iplot(a1,b,r)
  
  b = eval(params, plist('index',2,'xdata',a2,'xfield','x'));
  b.setName('fit Ch.2');
  r = a2-b;
  r.setName('residuals');
  iplot(a2,b,r)
  
  close all
end


