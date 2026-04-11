% TEST_MEAN test mean() operator for analysis objects.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TEST_MEAN Test mean() operator for analysis objects with
%                       tsdata, fsdata cdata and xydata
%
% CALL:    test_mean;
%
% HISTORY: 31-05-2007 Diepholz
%             Creation.
%
% VERSION: $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test_mean()
  
  % Create tsdata with a sinewave
  pl = plist('fs', 100, 'nsecs', 5, 'waveform', 'sine wave', 'f', 1.23, 'phi', 30);
  
  ts_data = ao(pl);
  
  % Create cdata with a 3x3 Matrix
  matr_1 = [1 2 3; 4 5 6; 7 8 9];
  matr_2 = [0 1 2; 3 4 5; 6 7 8; 9 10 11];
  
  c_data_1 = ao(matr_1);
  c_data_2 = ao(matr_2);
  
  % Create xydata with a exp function
  x = 1:1000;
  y = exp(x.^.5/2);
  
  xy_data = ao(x,y);
  
  % Some tests
  ao_out = mean(c_data_1);
  ao_out = mean(c_data_2);
  ao_out = mean(ts_data);
  ao_out = mean(ts_data, ts_data, ts_data);
  ao_out = mean(ts_data, c_data_1, xy_data);
  
  ao_out = mean(ts_data, xy_data);
  ao_out = mean(c_data_1, plist('axis', 'y'));
  
  % Create different parameter lists to control the mean test
  pl1 = plist('axis', 'y');
  ao_out = mean(ts_data, pl1);
  
  pl2 = plist('axis', 'y');
  ao_out = mean(xy_data, pl2);
  
  pl3 = plist('axis', 'x');
  ao_out = mean(xy_data, pl3);
  
  pl4 = plist('axis', 'xy');
  ao_out = mean(xy_data, pl4);
  
  pl5 = plist('dim', []);
  ao_out = mean(c_data_1, pl5);
  ao_out = mean(c_data_2, pl5);
  
  pl6 = plist('dim', 1);
  ao_out = mean(c_data_1, pl6);
  ao_out = mean(c_data_2, pl6);
  
  pl7 = plist('dim', 2);
  ao_out = mean(c_data_1, pl7);
  ao_out = mean(c_data_2, pl7);
  
  % Make test AOs
  
  nsecs = 10;
  fs    = 1000;
  
  pl = plist('nsecs', nsecs, 'fs', fs, 'tsfcn', '10 + sin(2*pi*7.433*t) + randn(size(t))');
  
  a1 = ao(pl);
  a1 = a1.setName('a1')
  
  % Take abs
  a2 = mean(a1)
  a3 = a1 - a2;
  
  % Plot
  iplot(a1, a3)
  
  close all
end

