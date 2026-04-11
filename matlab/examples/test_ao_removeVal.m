% Test ao/removeVal for:
% - functionality
%
% M Hueller 10-03-10
%
% $Id$
%

function test_ao_removeVal
  
  %% Start with an AO with no "bad" data in it
  a_orig = ao(plist(...
    'waveform', 'sinewave', ...
    'Nsecs', 100, ...
    'fs', 1, ...
    'f', 0.02, ...
    'yunits', 'V', ...
    't0', '2010-03-10 20:00:00.000' ...
    )) + 2;
  a_orig.setName('original');
  
  %% 1) Test the case where we remove only Inf, removing data
  value = Inf;
  % Prepare a list of index where we add the "bad" points
  N   = randi(10, 1);
  bad_index   = randi(numel(a_orig.x), N, 1);
  
  % Mix the AO with the "bad" values
  y_orig = a_orig.y();
  y_bad = y_orig;
  y_bad(bad_index)   = value;
  a_bad = a_orig.setY(y_bad);
  a_bad.setName('corrupted');
  
  % Run the ao/removeVal method
  a_clean = a_bad.removeVal(plist('value', value));
  a_clean.setName('cleaned');
  
  % Compare against the original:
  % units
  if ~isequal(a_clean.yunits, a_bad.yunits)
    disp('Warning: wrong yunits!');
  end
  if ~isequal(a_clean.xunits, a_bad.xunits)
    disp('Warning: wrong xunits!');
  end
  
  % t0
  if ~isequal(a_clean.t0, a_bad.t0)
    disp('Warning: wrong t0!');
  end
  
  index   = true(size(a_bad.x));
  index(bad_index) = false;
  
  % "good" values: x
  x_clean = a_clean.x;
  x_bad   = a_bad.x;
  if ~isequal(x_bad(index), x_clean)
    disp('Warning: wrong x values!');
  end
  
  % "good" values: y
  y_clean = a_clean.y;
  y_bad   = a_bad.y;
  if ~isequal(y_bad(index), y_clean)
    disp('Warning: wrong y values!');
  end
  
  %% 2) Test the case where we remove only NaN, removing data
  value = NaN;
  % Prepare a list of index where we add the "bad" points
  N   = randi(10, 1);
  bad_index   = randi(numel(a_orig.x), N, 1);
  
  % Mix the AO with the "bad" values
  y_orig = a_orig.y();
  y_bad = y_orig;
  y_bad(bad_index)   = value;
  a_bad = a_orig.setY(y_bad);
  a_bad.setName('corrupted');
  
  % Run the ao/removeVal method
  a_clean = a_bad.removeVal(plist('value', value));
  a_clean.setName('cleaned');
  
  % Compare against the original:
  % units
  if ~isequal(a_clean.yunits, a_bad.yunits)
    disp('Warning: wrong yunits!');
  end
  if ~isequal(a_clean.xunits, a_bad.xunits)
    disp('Warning: wrong xunits!');
  end
  
  % t0
  if ~isequal(a_clean.t0, a_bad.t0)
    disp('Warning: wrong t0!');
  end
  
  index   = true(size(a_bad.x));
  index(bad_index) = false;
  
  % "good" values: x
  x_clean = a_clean.x;
  x_bad   = a_bad.x;
  if ~isequal(x_bad(index), x_clean)
    disp('Warning: wrong x values!');
  end
  
  % "good" values: y
  y_clean = a_clean.y;
  y_bad   = a_bad.y;
  if ~isequal(y_bad(index), y_clean)
    disp('Warning: wrong y values!');
  end
  
  
  %% 3) Test the case where we remove only 0s, removing data
  value = 0;
  % Prepare a list of index where we add the "bad" points
  N   = randi(10, 1);
  bad_index   = randi(numel(a_orig.x), N, 1);
  
  % Mix the AO with the "bad" values
  y_orig = a_orig.y();
  y_bad = y_orig;
  y_bad(bad_index)   = value;
  a_bad = a_orig.setY(y_bad);
  a_bad.setName('corrupted');
  
  % Run the ao/removeVal method
  a_clean = a_bad.removeVal(plist('value', value));
  a_clean.setName('cleaned');
  
  % Compare against the original:
  % units
  if ~isequal(a_clean.yunits, a_bad.yunits)
    disp('Warning: wrong yunits!');
  end
  if ~isequal(a_clean.xunits, a_bad.xunits)
    disp('Warning: wrong xunits!');
  end
  
  % t0
  if ~isequal(a_clean.t0, a_bad.t0)
    disp('Warning: wrong t0!');
  end
  
  index   = true(size(a_bad.x));
  index(bad_index) = false;
  
  % "good" values: x
  x_clean = a_clean.x;
  x_bad   = a_bad.x;
  if ~isequal(x_bad(index), x_clean)
    disp('Warning: wrong x values!');
  end
  
  % "good" values: y
  y_clean = a_clean.y;
  y_bad   = a_bad.y;
  if ~isequal(y_bad(index), y_clean)
    disp('Warning: wrong y values!');
  end
  
  
  %% 4) Test the case where we remove Inf AND NaN AND 0s, removing data
  % Prepare a list of index where we add the "bad" points
  N_nan   = randi(10, 1);
  N_inf   = randi(10, 1);
  N_zeros = randi(10, 1);
  nan_index   = randi(numel(a_orig.x), N_nan, 1);
  inf_index   = randi(numel(a_orig.x), N_inf, 1);
  zeros_index = randi(numel(a_orig.x), N_zeros, 1);
  
  % Mix the AO with NaN, Inf, and 0s inside
  y_orig = a_orig.y();
  y_bad = y_orig;
  y_bad(nan_index)   = NaN;
  y_bad(inf_index)   = Inf;
  y_bad(zeros_index) = 0;
  a_bad = a_orig.setY(y_bad);
  a_bad.setName('corrupted');
  
  % Run the ao/removeVal method
  value = [Inf NaN 0];
  a_clean = a_bad.removeVal(plist('value', value));
  a_clean.setName('cleaned');
  
  % Compare against the original
  % units
  if ~isequal(a_clean.yunits, a_bad.yunits)
    disp('Warning: wrong yunits!');
  end
  if ~isequal(a_clean.xunits, a_bad.xunits)
    disp('Warning: wrong xunits!');
  end
  
  % t0
  if ~isequal(a_clean.t0, a_bad.t0)
    disp('Warning: wrong t0!');
  end
  
  index   = true(size(a_bad.x));
  index(nan_index) = false;
  index(inf_index) = false;
  index(zeros_index) = false;
  
  % "good" values: x
  x_clean = a_clean.x;
  x_bad   = a_bad.x;
  if ~isequal(x_bad(index), x_clean)
    disp('Warning: wrong x values!');
  end
  
  % "good" values: y
  y_clean = a_clean.y;
  y_bad   = a_bad.y;
  if ~isequal(y_bad(index), y_clean)
    disp('Warning: wrong y values!');
  end
  
  % plots the original, "bad", and "clean" data
  iplot(a_orig, a_bad, a_clean, plist('LineStyles', {'-', '-', 'None'}, 'Markers', {'.', '.', 'o'}));
  
  %% 5) Test the case where we remove Inf AND NaN AND 0s, interpolating data
  % Prepare a list of index where we add the "bad" points
  N_nan   = randi(10, 1);
  N_inf   = randi(10, 1);
  N_zeros = randi(10, 1);
  nan_index   = randi(numel(a_orig.x), N_nan, 1);
  inf_index   = randi(numel(a_orig.x), N_inf, 1);
  zeros_index = randi(numel(a_orig.x), N_zeros, 1);
  
  % Mix the AO with NaN, Inf, and 0s inside
  y_orig = a_orig.y();
  y_bad = y_orig;
  y_bad(nan_index)   = NaN;
  y_bad(inf_index)   = Inf;
  y_bad(zeros_index) = 0;
  a_bad = a_orig.setY(y_bad);
  a_bad.setName('corrupted');
  
  % Run the ao/removeVal method
  value = [Inf NaN 0];
  a_clean = a_bad.removeVal(plist('value', value, 'method', 'interp'));
  a_clean.setName('cleaned');
  
  % Compare against the original
  % units
  if ~isequal(a_clean.yunits, a_bad.yunits)
    disp('Warning: wrong yunits!');
  end
  if ~isequal(a_clean.xunits, a_bad.xunits)
    disp('Warning: wrong xunits!');
  end
  
  % t0
  if ~isequal(a_clean.t0, a_bad.t0)
    disp('Warning: wrong t0!');
  end
  
  % plots the original, "bad", and "clean" data
  iplot(a_orig, a_bad, a_clean, plist('LineStyles', {'-', '-', 'None'}, 'Markers', {'.', '.', 'o'}));
  
  %% 6) Test the case where we remove NaN, removing data
  
  % We fill the object with "bad" points
  y_bad = NaN * ones(size(y_orig));
  a_bad = a_orig.setY(y_bad);
  a_bad.setName('corrupted');
  
  % Run the ao/removeVal method
  value = [NaN];
  a_clean = a_bad.removeVal(plist('value', value, 'method', 'remove'));
  a_clean.setName('cleaned');
  
  % Compare against the original
  % units
  if ~isequal(a_clean.yunits, a_bad.yunits)
    disp('Warning: wrong yunits!');
  end
  if ~isequal(a_clean.xunits, a_bad.xunits)
    disp('Warning: wrong xunits!');
  end
  
  % t0
  if ~isequal(a_clean.t0, a_bad.t0)
    disp('Warning: wrong t0!');
  end
  
  assert(isempty(a_clean.y));
  assert(isempty(a_clean.x));
  
  %% 7) Test the case where we remove NaN, interpolating data
  
  % We fill the object with "bad" points
  y_bad = NaN * ones(size(y_orig));
  a_bad = a_orig.setY(y_bad);
  a_bad.setName('corrupted');
  
  % Run the ao/removeVal method
  value = [NaN];
  a_clean = a_bad.removeVal(plist('value', value, 'method', 'interp'));
  a_clean.setName('cleaned');
  
  % Compare against the original
  % units
  if ~isequal(a_clean.yunits, a_bad.yunits)
    disp('Warning: wrong yunits!');
  end
  if ~isequal(a_clean.xunits, a_bad.xunits)
    disp('Warning: wrong xunits!');
  end
  
  % t0
  if ~isequal(a_clean.t0, a_bad.t0)
    disp('Warning: wrong t0!');
  end
  
  assert(isempty(a_clean.y));
  assert(isempty(a_clean.x));
  
  close all
  
end
