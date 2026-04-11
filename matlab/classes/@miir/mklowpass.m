% MKLOWPASS return a low pass filter miir(). A Butterworth filter is used.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MKLOWPASS return a low pass filter miir().
%              A Butterworth filter is used.
%
% CALL:        f = mklowpass(f, pl)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f = mklowpass(f, pl)

  g     = find_core(pl, 'gain');
  fc    = find_core(pl, 'fc');
  fs    = find_core(pl, 'fs');
  order = find_core(pl, 'order');

  utils.helper.checkFilterOptions(pl);

  % Build coefficients
  [a, b] = butter(order, 2*fc(1)/fs);

  % Set filter properties
  f.name    = 'lowpass';
  f.fs      = fs;
  f.a       = a.*g;
  f.b       = b;
  f.histin  = zeros(1,f.ntaps-1); % initialise input history
  f.histout = zeros(1,f.ntaps-1); % initialise output history
end

