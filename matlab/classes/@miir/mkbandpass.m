% MKBANDPASS return a bandpass filter miir(). A Cheby filter is used.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MKBANDPASS return a bandpass filter miir().
%              A Cheby filter is used.
%
% CALL:        f = mkbandpass(f, pl)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f = mkbandpass(f, pl)
  
  g      = find_core(pl, 'gain');
  fc     = find_core(pl, 'fc');
  fs     = find_core(pl, 'fs');
  order  = find_core(pl, 'order');
  ripple = find_core(pl, 'ripple');
  
  utils.helper.checkFilterOptions(pl);
  
  % Build filter coefficients
  [a, b] = cheby1(order, ripple, 2.*fc./fs);
  
  % Set filter properties
  f.name    = 'bandpass';
  f.fs      = fs;
  f.a       = g.*a;
  f.b       = b;
  f.histin  = zeros(1,f.ntaps-1); % initialise input history
  f.histout = zeros(1,f.ntaps-1); % initialise output history
end

