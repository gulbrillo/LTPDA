% test script for tsdata class
%
% M Hueller 21/01/2012
%
% $Id$
%
function test_tsdata_class
  
  %% Test all the constructors syntax described in the help
  
  
  %%      ts = tsdata()        - creates a blank time-series object
  
  ts = tsdata();
  assert(isempty(ts.x), 'Failed: internal x');
  assert(isequal(ts.toffset, 0), 'Failed: toffset');
  assert(isempty(ts.getX), 'Failed: user x');
  assert(isempty(ts.y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(isequal(ts.nsecs, 0), 'Failed: nsecs');
  assert(isnan(ts.fs), 'Failed: fs');
  assert(isequal(ts.t0, time(0)), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  
  %%      ts = tsdata(y)       - creates a time-series object with the given
  %                              y-data. The data are assumed to be evenly
  %                              sampled at 1Hz.
  
  y = randn(100, 1);
  ts = tsdata(y);
  assert(isempty(ts.x), 'Failed: internal x');
  assert(isequal(ts.toffset, 0), 'Failed: toffset');
  assert(isequal(ts.getX, [0:1:99]'), 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(isequal(ts.nsecs, 100), 'Failed: nsecs');
  assert(isequal(ts.fs, 1), 'Failed: fs');
  assert(isequal(ts.t0, time(0)), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  
  %%      ts = tsdata(x,y)     - creates a time-series object with the given
  %                              (x,y)-data. The sample rate is then set using
  %                              the static method fitfs(). This computes the
  %                              best sample rate that fits the data. If the
  %                              data is evenly sampled, the sample rate is set
  %                              as 1/median(diff(x)) and the x data is then
  %                              not stored (empty vector).
  
  % Evenly sampled data, starting at 0
  y = randn(100, 1);
  x = tsdata.createTimeVector(10, 10);
  ts = tsdata(x, y);
  assert(isempty(ts.x), 'Failed: internal x');
  assert(isequal(ts.toffset, 0), 'Failed: toffset');
  assert(isequal(ts.getX, x), 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(isequal(ts.nsecs, 10), 'Failed: nsecs');
  assert(isequal(ts.fs, 10), 'Failed: fs');
  assert(isequal(ts.t0, time(0)), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  % Evenly sampled data, not starting at 0
  toff = 2.1;
  ts = tsdata(x + toff, y);
  assert(isempty(ts.x), 'Failed: internal x');
  assert(isequal(ts.toffset, toff * 1000), 'Failed: toffset');
  assert(isequal(ts.getX, x + toff), 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(isequal(ts.nsecs, 10), 'Failed: nsecs');
  assert(isequal(ts.fs, 10), 'Failed: fs');
  assert(isequal(ts.t0, time(0)), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  % Unevenly sampled data, starting at 0
  y = randn(80, 1);
  x = [0:0.1:5 5.2:0.1:8]';
  ts = tsdata(x, y);
  assert(isequal(ts.x, x), 'Failed: internal x');
  assert(isequal(ts.toffset, 0), 'Failed: toffset');
  assert(isequal(ts.getX, x), 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(isequal(ts.nsecs, 8.1), 'Failed: nsecs');
  assert(isequal(ts.fs, 10), 'Failed: fs');
  assert(isequal(ts.t0, time(0)), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  % Unevenly sampled data, not starting at 0
  y = randn(70, 1);
  x = [1:0.1:5 5.2:0.1:8]';
  ts = tsdata(x, y);
  TOL = 1e-13;
  assert(isequal(ts.x, x), 'Failed: internal x');
  assert(isequal(ts.toffset, 0), 'Failed: toffset');
  assert(isequal(ts.getX, x), 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(isequal(ts.nsecs, 7.1), 'Failed: nsecs');
  assert((abs(ts.fs - 10) / 10) < TOL, 'Failed: fs');
  assert(isequal(ts.t0, time(0)), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  
  %%      ts = tsdata(y,fs)    - creates a time-series object with the given
  %                              y-data. The data is assumed to be evenly sampled
  %                              at the given sample rate with the first sample
  %                              assigned time 0. No x vector is created.
  
  y = randn(100, 1);
  fs = 5;
  ts = tsdata(y, fs);
  assert(isempty(ts.x), 'Failed: internal x');
  assert(isequal(ts.toffset, 0), 'Failed: toffset');
  assert(isequal(ts.getX, tsdata.createTimeVector(5, 20)), 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(isequal(ts.nsecs, 20), 'Failed: nsecs');
  assert(isequal(ts.fs, fs), 'Failed: fs');
  assert(isequal(ts.t0, time(0)), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  
  %%      ts = tsdata(y,t0)    - creates a time-series object with the given
  %                              y-data. The data are assumed to be evenly
  %                              sampled at 1Hz. The first sample is assumed to
  %                              be at 0s offset from t0 and t0 is set to the
  %                              user specified value.
  
  y = randn(100, 1);
  t0 = time();
  ts = tsdata(y, t0);
  assert(isempty(ts.x), 'Failed: internal x');
  assert(isequal(ts.toffset, 0), 'Failed: toffset');
  assert(isequal(ts.getX, [0:1:99]'), 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(isequal(ts.nsecs, 100), 'Failed: nsecs');
  assert(isequal(ts.fs, 1), 'Failed: fs');
  assert(isequal(ts.t0, t0), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  
  %%      ts = tsdata(x,y,fs)  - creates a time-series object with the given
  %                              x/y data vectors. The sample rate is set to
  %                              fs.
  
  % Evenly sampled data, starting at 0
  y = randn(100, 1);
  x = tsdata.createTimeVector(10, 10);
  fs = 10;
  ts = tsdata(x, y, fs);
  assert(isempty(ts.x), 'Failed: internal x');
  assert(isequal(ts.toffset, 0), 'Failed: toffset');
  assert(isequal(ts.getX, x), 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(isequal(ts.nsecs, 10), 'Failed: nsecs');
  assert(isequal(ts.fs, fs), 'Failed: fs');
  assert(isequal(ts.t0, time(0)), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  % Evenly sampled data, not starting at 0
  toff = 2.1;
  ts = tsdata(x + toff, y, fs);
  assert(isempty(ts.x), 'Failed: internal x');
  assert(isequal(ts.toffset, toff * 1000), 'Failed: toffset');
  assert(isequal(ts.getX, x + toff), 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(isequal(ts.nsecs, 10), 'Failed: nsecs');
  assert(isequal(ts.fs, fs), 'Failed: fs');
  assert(isequal(ts.t0, time(0)), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  % Unevenly sampled data, starting at 0
  y = randn(80, 1);
  x = [0:0.1:5 5.2:0.1:8]';
  fs = 10;
  ts = tsdata(x, y, fs);
  assert(isequal(ts.x, x), 'Failed: internal x');
  assert(isequal(ts.toffset, 0), 'Failed: toffset');
  assert(isequal(ts.getX, x), 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(isequal(ts.nsecs, 8.1), 'Failed: nsecs');
  assert(isequal(ts.fs, fs), 'Failed: fs');
  assert(isequal(ts.t0, time(0)), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  % Unevenly sampled data, not starting at 0
  y = randn(70, 1);
  x = [1:0.1:5 5.2:0.1:8]';
  fs = 10;
  ts = tsdata(x, y, fs);
  assert(isequal(ts.x, x), 'Failed: internal x');
  assert(isequal(ts.toffset, 0), 'Failed: toffset');
  assert(isequal(ts.getX, x), 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(isequal(ts.nsecs, 7.1), 'Failed: nsecs');
  assert(isequal(ts.fs, fs), 'Failed: fs');
  assert(isequal(ts.t0, time(0)), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  
  %%      ts = tsdata(x,y,t0)  - creates a time-series object with the given
  %                              x/y data vectors. The t0 property is set to
  %                              the supplied t0 and the sample rate is
  %                              computed from the x vector using the static
  %                              method fitfs(). If the data is found to be
  %                              evenly sampled, the x vector is discarded.
  
  % Evenly sampled data, starting at 0
  y = randn(1000, 1);
  x = tsdata.createTimeVector(50, 20);
  fs = 50;
  t0 = time(1.3e9);
  ts = tsdata(x, y, t0);
  assert(isempty(ts.x), 'Failed: internal x');
  assert(isequal(ts.toffset, 0), 'Failed: toffset');
  assert(isequal(ts.getX, x), 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(isequal(ts.nsecs, 20), 'Failed: nsecs');
  assert(isequal(ts.fs, fs), 'Failed: fs');
  assert(isequal(ts.t0, t0), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  % Evenly sampled data, not starting at 0
  toff = 10.1;
  ts = tsdata(x + toff, y, t0);
  TOL = 1e-14;
  assert(isempty(ts.x), 'Failed: internal x');
  assert(isequal(ts.toffset, toff * 1000), 'Failed: toffset');
  assert(max(abs(ts.getX - (x + toff))) < TOL, 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(abs(ts.nsecs - 20)/20 < TOL, 'Failed: nsecs');
  assert(abs(ts.fs - fs)/fs < TOL, 'Failed: fs');
  assert(isequal(ts.t0, t0), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  % Unevenly sampled data, starting at 0
  y = randn(400, 1);
  x = [0:0.02:5 5.04:0.02:8]';
  fs = 50;
  ts = tsdata(x, y, t0);
  assert(isequal(ts.x, x), 'Failed: internal x');
  assert(isequal(ts.toffset, 0), 'Failed: toffset');
  assert(isequal(ts.getX, x), 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(isequal(ts.nsecs, 8.02), 'Failed: nsecs');
  assert(abs(ts.fs - fs)/fs < TOL, 'Failed: fs');
  assert(isequal(ts.t0, t0), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  % Unevenly sampled data, not starting at 0
  y = randn(300, 1);
  x = [0:0.02:5 5.04:0.02:6]';
  fs = 50;
  toff = 10.1;
  ts = tsdata(x + toff, y, t0);
  TOL = 1e-13;
  assert(isequal(ts.x, x + toff), 'Failed: internal x');
  assert(isequal(ts.toffset, 0), 'Failed: toffset');
  assert(max(abs(ts.getX - (x + toff))) < TOL, 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(abs(ts.nsecs - 6.02)/6.02 < TOL, 'Failed: nsecs');
  assert(abs(ts.fs - fs)/fs < TOL, 'Failed: fs');
  assert(isequal(ts.t0, t0), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  
  %%      ts = tsdata(y,fs,t0) - creates a time-series object with the given
  %                              y-data. The data are assumed to be evenly
  %                              sampled at fs and the t0 property is set to
  %                              the supplied t0. No x vector is generated.
  
  y = randn(100, 1);
  t0 = time();
  fs = 4;
  ts = tsdata(y, fs, t0);
  assert(isempty(ts.x), 'Failed: internal x');
  assert(isequal(ts.toffset, 0), 'Failed: toffset');
  assert(isequal(ts.getX, [0:0.25:24.75]'), 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(isequal(ts.nsecs, 25), 'Failed: nsecs');
  assert(isequal(ts.fs, fs), 'Failed: fs');
  assert(isequal(ts.t0, t0), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  
  %%      ts = tsdata(x,y,fs,t0)-creates a time-series object with the given
  %                              x-data, y-data, fs and t0.
  
  % Evenly sampled data, starting at 0
  y = randn(1000, 1);
  x = tsdata.createTimeVector(50, 20);
  fs = 50;
  t0 = time(1.3e9);
  ts = tsdata(x, y, fs, t0);
  assert(isempty(ts.x), 'Failed: internal x');
  assert(isequal(ts.toffset, 0), 'Failed: toffset');
  assert(isequal(ts.getX, x), 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(isequal(ts.nsecs, 20), 'Failed: nsecs');
  assert(isequal(ts.fs, fs), 'Failed: fs');
  assert(isequal(ts.t0, t0), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  % Evenly sampled data, not starting at 0
  toff = 10.1;
  ts = tsdata(x + toff, y, fs, t0);
  TOL = 1e-14;
  assert(isempty(ts.x), 'Failed: internal x');
  assert(isequal(ts.toffset, toff * 1000), 'Failed: toffset');
  assert(max(abs(ts.getX - (x + toff))) < TOL, 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(abs(ts.nsecs - 20)/20 < TOL, 'Failed: nsecs');
  assert(abs(ts.fs - fs)/fs < TOL, 'Failed: fs');
  assert(isequal(ts.t0, t0), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  % Unevenly sampled data, starting at 0
  y = randn(400, 1);
  x = [0:0.02:5 5.04:0.02:8]';
  fs = 50;
  ts = tsdata(x, y, fs, t0);
  TOL = 1e-15;
  assert(isequal(ts.x, x), 'Failed: internal x');
  assert(isequal(ts.toffset, 0), 'Failed: toffset');
  assert(isequal(ts.getX, x), 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(isequal(ts.nsecs, 8.02), 'Failed: nsecs');
  assert(abs(ts.fs / fs - 1) < TOL, 'Failed: fs');
  assert(isequal(ts.t0, t0), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
  % Unevenly sampled data, not starting at 0
  y = randn(300, 1);
  x = [0:0.02:5 5.04:0.02:6]';
  fs = 50;
  toff = 10.1;
  ts = tsdata(x + toff, y, fs, t0);
  TOL = 1e-13;
  assert(isequal(ts.x, x + toff), 'Failed: internal x');
  assert(isequal(ts.toffset, 0), 'Failed: toffset');
  assert(max(abs(ts.getX - (x + toff))) < TOL, 'Failed: user x');
  assert(isequal(ts.y, y), 'Failed: y');
  assert(isempty(ts.dx), 'Failed: dx');
  assert(isempty(ts.dy), 'Failed: dy');
  assert(abs(ts.nsecs / 6.02 - 1) < TOL, 'Failed: nsecs');
  assert(abs(ts.fs / fs - 1) < TOL, 'Failed: fs');
  assert(isequal(ts.t0, t0), 'Failed: t0');
  assert(isequal(ts.xunits, unit()), 'Failed: xunits');
  assert(isequal(ts.yunits, unit()), 'Failed: yunits');
  
end
