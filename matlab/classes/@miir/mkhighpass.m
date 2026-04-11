% MKHIGHPASS return a high pass filter miir(). A Butterworth filter is used.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MKHIGHPASS return a high pass filter miir().
%              A Butterworth filter is used.
%
% CALL:        f = mkhighpass(f, pl)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f = mkhighpass(f, pl)

  g     = find_core(pl, 'gain');
  fc    = find_core(pl, 'fc');
  fs    = find_core(pl, 'fs');
  order = find_core(pl, 'order');

  utils.helper.checkFilterOptions(pl);

  % Build filter coefficients
  [a, b] = butter(order, 2*fc(1)/fs, 'high');

  % Set filter properties
  f.name    = 'highpass';
  f.fs      = fs;
  f.a       = g.*a;
  f.b       = b;
  f.histin  = zeros(1,f.ntaps-1); % initialise input history
  f.histout = zeros(1,f.ntaps-1); % initialise output history
end

