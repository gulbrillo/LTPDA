% MKBANDREJECT return a low pass filter mfir(). A Butterworth filter is used.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MKBANDREJECT return a low pass filter mfir().
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
  win    = find_core(pl, 'Win');
  
  utils.helper.checkFilterOptions(pl);
  
  f.name    = 'bandreject';
  f.fs      = fs;
  f.a       = g.*fir1(order, 2.*fc/fs, 'stop', win.win);
  f.gd      = (f.ntaps-1)/2;
  f.histout = zeros(1,f.ntaps-1);   % initialise output history
end

