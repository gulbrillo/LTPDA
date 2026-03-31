% MKLOWPASS return a low pass filter mfir().
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MKLOWPASS return a low pass filter mfir().
%
% CALL:        f = mklowpass(f, pl)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f = mklowpass(f, pl)

  g     = find_core(pl, 'gain');
  fc    = find_core(pl, 'fc');
  fs    = find_core(pl, 'fs');
  order = find_core(pl, 'order');
  win   = find_core(pl, 'Win');

  utils.helper.checkFilterOptions(pl);

  f.name     = 'lowpass';
  f.fs       = fs;
  f.a        = g.*fir1(order, 2*fc(1)/fs, 'low', win.win);
  f.gd       = (f.ntaps-1)/2;
  f.histout  = zeros(1,f.ntaps-1);   % initialise output history
end

