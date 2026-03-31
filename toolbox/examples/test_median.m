% TEST_MEDIAN test median() operator for analysis objects.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TEST_MEDIAN Test median() operator for analysis objects with
%                       tsdata, fsdata cdata and xydata
%
% CALL:    test_median;
%
% HISTORY: 31-05-2007 Diepholz
%             Creation.
%
% VERSION: $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test_median()
  
  % Create tsdata with a sinewave
  pl = plist('fs', 100, 'nsecs', 5, 'waveform', 'sine wave', 'f', 1.23, 'phi', 30);
  
  ts_data = ao(pl);
  
  % Create cdata with a 3x3 Matrix
  matr = [1 2 3; 4 5 6; 7 8 9];
  
  c_data = ao(matr);
  
  % Create xydata with a exp function
  x = 1:1000;
  y = exp(x.^.5/2);
  
  xy_data = ao(x,y);
  
  % Some tests
  ao_out = median(ts_data);
  ao_out = median(ts_data, ts_data, ts_data);
  ao_out = median(ts_data, c_data, xy_data);
  
  ao_out = median(ts_data, xy_data);
  ao_out = median(c_data, plist('axis', 'y'));
  
  % Create different parameter lists to control the median test
  pl1 = plist('axis', 'y');
  ao_out = median(ts_data, pl1);
  
  pl2 = plist('axis', 'y');
  ao_out = median(xy_data, pl2);
  
  pl3 = plist('axis', 'x');
  ao_out = median(xy_data, pl3);
  
  pl4 = plist('axis', 'xy');
  ao_out = median(xy_data, pl4);
  
end
