% TEST_AO_DETREND tests the detrend method of the AO class.
%
% M Hueller 19-06-14
%
%
function test_ao_detrend()
  
  
  %% Make fake AO from waveform + noise + trend
  nsecs = 10000;
  fs    = 1;
  A     = 1;
  f = 0.001;
  t = 1e-6;
  
  unit_list = unit.supportedUnits;
  u1 = unit(cell2mat(utils.math.randelement(unit_list, 1)));
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'yunits', u1);
  
  wave  = A*ao(pl.pset('waveform', 'squarewave', 'f', f));
  noise = t*ao(pl.pset('waveform', 'noise'));
  trend = t*ao(pl.pset('tsfcn', 't.^2 + t'));
  
  data = wave + noise + trend;
  
  %% Detrend
  detrended_data = detrend(data, plist('order', 2, 'times', [2600 2900]));
  iplot(data, detrended_data)
  detrended_data.viewHistory;
  %% Reproduce from history
  disp('Try rebuilding')
  data_out = rebuild(detrended_data);
  iplot(data_out)
  close all
  
end
