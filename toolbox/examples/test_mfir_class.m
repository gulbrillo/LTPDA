% TEST_MFIR_CLASS tests run on mfir class.
%
% M Hewitson 11-05-07
%
% $Id$
%
function test_mfir_class()
  
  
  % Empty constructor
  f = mfir()
  
  % Lowpass from plist
  pl = plist('type', 'lowpass', 'fs', 100, 'fc', 20);
  f  = mfir(pl)
  
  resp(f, plist('f1', 1,'f2', 50))
  
  % Highpass from plist
  pl = plist('type', 'highpass', 'fs', 100, 'fc', 20);
  f  = mfir(pl)
  
  resp(f, plist('f1', 1,'f2', 50))
  
  % Bandpass from plist
  pl = plist('type', 'bandpass', 'fs', 100, 'order', 1024, 'fc', [0.1 10]);
  % pl.append('Win', specwin('Kaiser', 10, 250));
  f  = mfir(pl)
  
  resp(f, plist('f1', 0.0001,'f2', 50));
  
  % Bandreject from plist
  pl = plist('type', 'bandreject', 'fs', 100, 'order', 1024, 'fc', [0.1 10]);
  % pl.append('Win', specwin('Kaiser', 10, 250));
  f  = mfir(pl)
  
  resp(f, plist('f1', 0.0001, 'scale', 'log'));
  
  close all
end
% END
