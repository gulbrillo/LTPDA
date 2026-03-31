function test_ao_timeaverage()
  
  % create a tsdata ao
  a = ao(plist('waveform', 'noise', 'fs', 10, 'nsecs', 1000, ...
    't0', time(plist('time', '2010-05-01 00:00:00.00', 'timezone', 'UTC'))));
  
  % times vector
  times = [ 0 100 200 300 400 500 ];
  
  % average
  b1 = timeaverage(a, plist('times', times));
  
  % this should have produced a time series with 3 points
  assert(len(b1) == 3);
  % check expected X values
  assert(almostEqual(b1.x, [50 250 450], 0.055));
  % check expected Y values
  assert(almostEqual(b1.y, [0; 0; 0], 0.1));
  
  % average
  b2 = timeaverage(a, plist('start time', 0, 'duration', 100, 'decay time', 100, 'repetitions', 3));
  
  % this should have produced the same values
  assert(len(b2) == 3);
  assert(almostEqual(b2.x, b1.x));
  assert(almostEqual(b2.y, b1.y));
  assert(isequal(b2.t0, a.t0))
  assert(isequal(b2.toffset, a.toffset))
  
  % average
  b3 = timeaverage(a, plist('times', times, 'function', @mean));
  
  % this should have produced the same values
  assert(len(b3) == 3);
  assert(almostEqual(b3.x, b1.x));
  assert(almostEqual(b3.y, b1.y));
  assert(isequal(b3.t0, a.t0))
  assert(isequal(b3.toffset, a.toffset))
  
  % average
  b4 = timeaverage(a, plist('times', times, 'xfunction', @min, 'yfunction', @mean));
  
  % this should have produced the same values
  assert(len(b4) == 3);
  assert(almostEqual(b4.x, [0 200 400]));
  assert(almostEqual(b4.y, b1.y));
  assert(isequal(b4.t0, a.t0))
  assert(isequal(b4.toffset, a.toffset))
  
  % average
  b5 = timeaverage(a, plist('times', times, 'function', 'center'));
  
  % this should have produced similar values
  assert(len(b5) == 3);
   % check expected X values
  assert(almostEqual(b1.x, [50 250 450], 0.055));
  % check expected Y values
  assert(almostEqual(b1.y, [0; 0; 0], 0.1));
  assert(isequal(b5.t0, a.t0))
  assert(isequal(b5.toffset, a.toffset))
  
end

function rv = almostEqual(x, y, delta)
  % fix dimensions
  x = x(:);
  y = y(:);
  
  % default tollerance
  if nargin < 3
    delta = 2*eps(x);
  end
  
  rv = all(abs(x - y) < delta);
end
