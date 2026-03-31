% MKBANDREJECT return a low pass filter miir(). A Butterworth filter is used.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MKBANDREJECT return a low pass filter miir().
%              A Butterworth filter is used.
%
% CALL:        f = mkbandreject(f, pl)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f = mkbandreject(f, pl)
  
  g      = find_core(pl, 'gain');
  fc     = find_core(pl, 'fc');
  fs     = find_core(pl, 'fs');
  order  = find_core(pl, 'order');
  ripple = find_core(pl, 'ripple');
  
  utils.helper.checkFilterOptions(pl);
  
  % Build filter coefficients
  [a, b] = cheby1(order, ripple, 2.*fc./fs, 'stop');
  
  % Set filter properties
  f.name    = 'bandreject';
  f.fs      = fs;
  f.a       = g.*a;
  f.b       = b;
  f.histin  = zeros(1,f.ntaps-1);   % initialise input history
  f.histout = zeros(1,f.ntaps-1);   % initialise output history
end

