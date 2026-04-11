% MKBANDPASS return a bandpass filter mfir(). A Cheby filter is used.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MKBANDPASS return a bandpass filter mfir().
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
  win    = find_core(pl, 'Win');
  
  utils.helper.checkFilterOptions(pl);
  
  f.name    = 'bandpass';
  f.fs      = fs;
  f.a       = g.*fir1(order, 2.*fc/fs, 'bandpass', win.win);
  f.gd      = (f.ntaps-1)/2;
  f.histout = zeros(1,f.ntaps-1);   % initialise output history
end

