% TEST_PZM_TO_FIR tests converting pzmodel into an FIR filter
%
% M Hewitson 16-08-07
%
% $Id$
%
function test_pzm_to_fir()
  
  
  ps = [pz(1) pz(200)];
  zs = [pz(50)];
  
  % Make pz model
  pzm = pzmodel(1, ps, zs);
  
  % Make filter
  f = mfir(plist('pzmodel', pzm));
  
  % compute response
  resp(f)
  
  close all
end
% END