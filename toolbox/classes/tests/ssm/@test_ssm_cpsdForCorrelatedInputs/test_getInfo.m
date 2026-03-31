% TEST_GETINFO tests getting the method info from the method.
function res = test_getInfo(varargin)
  
  
  utp = varargin{1};
  
  utp.expectedSets = {'Default'};
  
  % Default plist
  pl = copy(ssm.getInfo('reorganize', 'for cpsdForCorrelatedInputs').plists, 1);
  pl.remove('set');
  
  p = param({'covariance', 'The covariance matrix of this noise between input ports for the <i>time-discrete</i> noise model.'}, []);
  pl.append(p);
  
  p = param({'CPSD', 'The one sided cpsd matrix of the white noise between input ports.'}, []);
  pl.append(p);
  
  p = param({'aos', 'An array of input AOs, provides the cpsd of the input noise.'}, ao.initObjectWithSize(1,0));
  pl.append(p);
  
  p = param({'PZmodels', 'An array of input pzmodels, used to filter the input noise.'}, paramValue.EMPTY_DOUBLE); 
  pl.append(p);
  
  p = param({'reorganize', 'When set to 0, this means the ssm does not need be modified to match the requested i/o. Faster but dangerous!'}, paramValue.TRUE_FALSE);
  pl.append(p);

  p = param({'f2', 'The maximum frequency. Default is Nyquist or 1Hz.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'f1', 'The minimum frequency. Default is f2*1e-5.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'nf', 'The number of frequency bins. Frequencies are scale logarithmically'}, paramValue.DOUBLE_VALUE(200));
  pl.append(p);
  
  p = param({'diagonal only', 'Set to true if you want the PSD instead of the CPSD'}, paramValue.TRUE_FALSE);
  pl.append(p);

  p = param({'f', 'Specify a vector of frequencies. If this is used, ''f1'', ''f2'', and ''nf'' parameters are ignored.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  utp.expectedPlists = pl;
  
  
  % Call super class 
  res = test_getInfo@ltpda_uoh_method_tests(varargin{:});
end
% END