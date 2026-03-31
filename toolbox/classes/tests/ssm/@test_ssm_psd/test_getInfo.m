% TEST_GETINFO tests getting the method info from the method.
function res = test_getInfo(varargin)
  
  
  utp = varargin{1};
  
  utp.expectedSets = {'Default'};
  
  % Default plist
  pl = copy(ssm.getInfo('reorganize', 'for PSD').plists, 1);
  pl.remove('set');
  
  p = param({'variance', 'The variance vector of this noise between input ports for the <i>time-discrete</i> noise model. '}, []);
  pl.append(p);
  
  p = param({'PSD', 'The one sided psd vector of the white noise between input ports.'}, []);
  pl.append(p);
  
  p = param({'aos', 'A vector of input PSD AOs, The spectrum of this noise between input ports for the <i>time-continuous</i> noise model.'}, ao.initObjectWithSize(1,0));
  pl.append(p);
  
  p = param({'PZmodels', 'vector of noise shape filters for the different corresponding inputs.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'reorganize', 'When set to 0, this means the ssm does not need be modified to match the requested i/o. Faster but dangerous!'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = param({'f2', 'The maximum frequency. Default is Nyquist or 1Hz.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'f1', 'The minimum frequency. Default is f2*1e-5.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'nf', 'The number of frequency bins. Frequencies are scale logarithmically'}, paramValue.DOUBLE_VALUE(200));
  pl.append(p);
  
  p = param({'f', 'Specify a vector of frequencies. If this is used, ''f1'', ''f2'', and ''nf'' parameters are ignored.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  utp.expectedPlists = pl;
  
  
  % Call super class 
  res = test_getInfo@ltpda_uoh_method_tests(varargin{:});
end
% END