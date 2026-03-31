% TEST_AO_COV test cov() operator for analysis objects.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TEST_COV Test cov() operator for analysis objects with
%                       tsdata, fsdata cdata and xydata
%
% CALL:    test_ao_cov;
%
% HISTORY: M Hewitson 09-10-2008
%             Creation.
%
% VERSION: $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test_ao_cov()
  
  % Create tsdata with a sinewave
  pl = plist('fs', 100, 'nsecs', 5, 'waveform', 'noise');
  
  ts_data_1 = ao(pl);
  ts_data_2 = ao(pl);
  ts_data_3 = ao(pl);
  
  % Create cdata with a 3x3 Matrix
  matr = randn(3, 3);
  
  c_data_1 = ao(matr);
  c_data_2 = ao(matr + 2);
  
  % Create xydata with a exp function
  x = 1:1000;
  y = exp(x.^.5/2);
  
  xy_data_1 = ao(x, y);
  xy_data_2 = ao(x, y - 3);
  
  % Some tests
  ao_out = cov(ts_data_1, ts_data_2);
  ao_out = cov(ts_data_1, ts_data_2, ts_data_3);
  ao_out = cov(ts_data_1, ts_data_2, ts_data_2);
  ao_out = cov(ts_data_1, ts_data_1);
  ao_out = cov(c_data_1, c_data_2);
  ao_out = cov(xy_data_1, xy_data_2);
  
end
