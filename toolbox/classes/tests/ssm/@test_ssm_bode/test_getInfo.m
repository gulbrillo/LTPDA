% TEST_GETINFO tests getting the method info from the method.
function res = test_getInfo(varargin)
  
  
  utp = varargin{1};
  
  utp.expectedSets = {'Default'};
  
  % Default plist  
  pl = copy(ssm.getInfo('reorganize', 'for bode').plists, 1);
  pl.remove('set');
  
  p = param({'f', 'A frequency vector (replaces f1, f2 and nf).'}, paramValue.EMPTY_DOUBLE) ;
  pl.append(p);
  
  p = param({'f2', 'The maximum frequency. Default is Nyquist or 1Hz.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'f1', 'The minimum frequency. Default is f2*1e-5.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'nf', 'The number of frequency bins.'}, paramValue.DOUBLE_VALUE(1000));
  pl.append(p);
  
  p = param({'scale', 'Distribute frequencies on a ''log'' or ''lin'' scale.'}, {1, {'log', 'lin'}, paramValue.SINGLE});
  pl.append(p);
  
  p = param({'reorganize', 'When set to 0, this means the ssm does not need be modified to match the requested i/o. Faster but dangerous!'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = param({'numeric output', 'When set to ture, the output of bode will be purely numeric - no analysis objects.'}, paramValue.FALSE_TRUE);
  pl.append(p);

  utp.expectedPlists = pl;  
  
  % Call super class 
  res = test_getInfo@ltpda_uoh_method_tests(varargin{:});
end
% END