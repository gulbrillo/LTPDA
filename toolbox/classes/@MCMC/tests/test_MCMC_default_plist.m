%
% Tests the default plist
%
function test_MCMC_default_plist(~)
  
  result = true;  
  pl     = MCMC.getDefaultPlist;
  
  % Total # of parameters
  if numel(pl.params) ~= 72; result  = false; end
  
  % Check main plist inputs
  if ~pl.isparam('Nsamples'),    result = false; end
  if ~pl.isparam('cov'),         result = false; end
  if ~pl.isparam('Fitparams'),   result = false; end
  if ~pl.isparam('noise'),       result = false; end
  if ~pl.isparam('model'),       result = false; end
  if ~pl.isparam('search'),      result = false; end
  if ~pl.isparam('simplex'),     result = false; end
  if ~pl.isparam('heat'),        result = false; end
  if ~pl.isparam('Tc'),          result = false; end
  if ~pl.isparam('x0'),          result = false; end
  if ~pl.isparam('jumps'),       result = false; end
  if ~pl.isparam('plot traces'), result = false; end
  if ~pl.isparam('debug'),       result = false; end
  if ~pl.isparam('f1'),          result = false; end
  if ~pl.isparam('f2'),          result = false; end
  if ~pl.isparam('noise scale'), result = false; end
  if ~pl.isparam('freqs'),       result = false; end
  if ~pl.isparam('split'),       result = false; end
  if ~pl.isparam('order'),       result = false; end
  if ~pl.isparam('tol'),         result = false; end
  if ~pl.isparam('window'),      result = false; end
  if ~pl.isparam('navs'),        result = false; end
  % Check default value
  if ~isequal(pl.find('Nsamples'), 1000),  result = false; end
  if ~isequal(pl.find('cov'), []),         result = false; end
  if ~isequal(pl.find('Fitparams'), []),   result = false; end
  if ~isequal(pl.find('noise'), ''),       result = false; end
  if ~isequal(pl.find('search'), true),    result = false; end
  if ~isequal(pl.find('simplex'), false),  result = false; end
  if ~isequal(pl.find('heat'), 1),         result = false; end
  if ~isequal(pl.find('Tc'), [0 1]),       result = false; end
  if ~isequal(pl.find('x0'), []),          result = false; end
  if ~isequal(pl.find('jumps'), []),       result = false; end
  if ~isequal(pl.find('plot'), []),        result = false; end
  if ~isequal(pl.find('debug'), false),    result = false; end
  
  if result
    message = 'Pass';
  else
    message = 'The default Plist of the MCMC class has been modified.';
  end
  
  assert(result, message)
  
end