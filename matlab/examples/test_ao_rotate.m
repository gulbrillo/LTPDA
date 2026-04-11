function test_ao_rotate()
  % test the rotate method
  
  % assume that the math is done right and test only the method interface
  
  % construct input AOs
  v1 = ao(1);
  v2 = ao(1);
 
  % two AOs - no rotation
  v = rotate(v1, v2);
  v1r = index(v, 1);
  v2r = index(v, 2);
  assert(abs(v1r.y - 1) < 1e-15);
  assert(abs(v2r.y - 1) < 1e-15);
  
  % two AOs and a scalar
  v = rotate(v1, v2, pi);
  v1r = index(v, 1);
  v2r = index(v, 2);
  assert(abs(v1r.y - -1) < 1e-15);
  assert(abs(v2r.y - -1) < 1e-15);
  
  % three AOs
  v = rotate(v1, v2, ao(pi));
  v1r = index(v, 1);
  v2r = index(v, 2);
  assert(abs(v1r.y - -1) < 1e-15);
  assert(abs(v2r.y - -1) < 1e-15);
  
  % two AOs and a plist
  v = rotate(v1, v2, plist('ang', pi));
  v1r = index(v, 1);
  v2r = index(v, 2);
  assert(abs(v1r.y - -1) < 1e-15);
  assert(abs(v2r.y - -1) < 1e-15);
  
  % two AOs and a plist with an AO
  v = rotate(v1, v2, plist('ang', ao(pi)));
  v1r = index(v, 1);
  v2r = index(v, 2);
  assert(abs(v1r.y - -1) < 1e-15);
  assert(abs(v2r.y - -1) < 1e-15);

  % check that original vectors didn't change
  assert(v1.y == 1);
  assert(v2.y == 1);
  
  % invalid call as modifier
  try
    rotate(v1, v2, plist('ang', ao(pi)));
    assert(false, 'this call should fail');
  catch e
    assert(strncmp(e.message, '### ao/rotate can not be used as a modifier method. Please give at least one output', ...
      length('### ao/rotate can not be used as a modifier method. Please give at least one output')));
  end
  
  % invalid call with one AO
  try
    v = rotate(v1, plist('ang', ao(pi))); %#ok<NASGU,ASGLU>
    assert(false, 'this call should fail');
  catch e
    assert(strncmp(e.message, '### wrong number of input AOs', length('### wrong number of input AOs')));
  end
  
  % invalid call with four AOs
  try
    v = rotate(v1, v2, v1, v2); %#ok<NASGU,ASGLU>
    assert(false, 'this call should fail');
  catch e
    assert(strncmp(e.message, '### wrong number of input AOs', length('### wrong number of input AOs')));
  end
  
  % test with vectors
  v1 = ao(ones(100, 1));
  v2 = ao(ones(100, 1));
 
  % two AOs and a scalar
  v = rotate(v1, v2, pi);
  v1r = index(v, 1);
  v2r = index(v, 2);
  assert(all(abs(v1r.y - -1) < 1e-15));
  assert(all(abs(v2r.y - -1) < 1e-15));

  % invalid call with two AOs and a scalar as a modifier
  try
    rotate(v1, v2, pi);
    assert(false, 'this call should fail');
  catch e
    assert(strncmp(e.message, '### ao/rotate can not be used as a modifier method. Please give at least one output', ...
      length('### ao/rotate can not be used as a modifier method. Please give at least one output')));
  end   
  
  % test with sine waves and different rotation angle
  v1 = ao(plist('waveform', 'sine', 'fs', 10, 'nsecs', 100, 'f', 0.01));
  v2 = ao(plist('tsfcn', 'zeros(size(t))', 'fs', 10, 'nsecs', 100));
  % iplot(v1, v2);
  
  % rotate by 45 degrees
  v = rotate(v1, v2, 0.25*pi);
  v1r = index(v, 1);
  v2r = index(v, 2);
  % iplot(v1r, v2r);
  assert(almostEqual(v1r, v1/sqrt(2)));
  assert(almostEqual(v2r, v1/sqrt(2))); 
  
  % rotate by 90 degrees
  v = rotate(v1, v2, 0.5*pi);
  v1r = index(v, 1);
  v2r = index(v, 2);
  % iplot(v1r, v2r);
  assert(almostEqual(v1r, v2));
  assert(almostEqual(v2r, v1)); 
  
  % rotate by 180 degrees
  v = rotate(v1, v2, pi);
  v1r = index(v, 1);
  v2r = index(v, 2);
  % iplot(v1r, v2r);
  assert(almostEqual(v1r, -v1));
  assert(almostEqual(v2r,  v2)); 
  
  % rotate by -45 degrees
  v = rotate(v1, v2, -0.25*pi);
  v1r = index(v, 1);
  v2r = index(v, 2);
  % iplot(v1r, v2r);
  assert(almostEqual(v1r,  v1/sqrt(2)));
  assert(almostEqual(v2r, -v1/sqrt(2))); 
  
end

function rv = almostEqual(x, y, t)
  if nargin == 2
    t = 1e-15;
  end
  rv = all(abs(x.y - y.y) < t);
end
