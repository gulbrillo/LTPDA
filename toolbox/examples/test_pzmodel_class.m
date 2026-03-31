% Test script for pzmodel class.
%
% M Hewitson 03-04-07
%
% $Id$
%
function test_pzmodel_class()
  
  % direct
  poles = [pz(1,2) pz(40)];
  zeros = [pz(10,3) pz(100)];
  pzm   = pzmodel(10, poles, zeros)
  resp(pzm)
  
  % From plist
  pl  = plist('name', 'test model', 'gain', 10, 'poles', [pz(1,2) pz(40)], 'zeros', [pz(10,3) pz(100)]);
  pzm = pzmodel(pl)
  
  string(pzm)
  eval(ans)
  
  rpl = plist('f1', 0.1, 'f2', 1000, 'nf', 10000);
  
  pzm = pzmodel(plist('name', 'pzmodel', ...
    'gain', 1,         ...
    'poles', pz(plist('f', 1, 'q', 3)), ...
    'zeros', pz(3)))
  a = resp(pzm, rpl)
  iplot(a)
  
  % Make IIR filter
  
  pzm = pzmodel(1, pz(1), pz(10))
  
  filt = miir(plist('pzmodel', pzm))
  newfilt = redesign(filt, 2000);
  
  filtresp = resp(filt);
  newfiltresp = resp(newfilt, plist('f', filtresp.data.x));
  
  
  % Reproduce from history
  a_out = rebuild(filtresp);
  
  iplot(a_out)
  
  close all
end

