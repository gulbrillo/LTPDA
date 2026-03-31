% TEST_GETINFO tests getting the method info from the method.
function res = test_getInfo(varargin)
  
  
  utp = varargin{1};
  
  utp.expectedSets = {'Default'};
  
  % Default plist
  pl = copy(ssm.getInfo('reorganize', 'for simulate').plists,1);
  pl.remove('set');
  
  p = param({'covariance', 'The covariance of this noise between input ports for the <i>time-discrete</i> noise model.'}, []);
  pl.append(p);
  
  p = param({'CPSD', 'The one sided cross-psd of the white noise between input ports.'}, []);
  pl.append(p);
  
  p = param({'aos', 'An array of input AOs.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'constants', 'Array of DC values for the different corresponding inputs.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'Nsamples', 'The maximum number of samples to simulate (AO length(s) overide this).'}, paramValue.DOUBLE_VALUE(inf));
  pl.append(p);
  
  p = param({'ssini', 'A cell-array of vectors that give the initial position for simulation.'}, {});
  pl.append(p);
  
  p = param({'initialize', 'When set to 1, a random state value is computed for the initial point.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  p = param({'tini', 'Same as t0; kept for backwards compatibility.'}, paramValue.EMPTY_DOUBLE );
  pl.append(p);
  
  p = param({'t0', 'The initial simulation time (seconds).'}, paramValue.EMPTY_DOUBLE );
  pl.append(p);
  
  p = param({'displayTime', 'Switch off/on the display'},  paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = param({'termincond', 'A string to evaluate a termination condition on the states in x (''lastX'') or outputs in y (''lastY'')'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  p = param({'reorganize', 'When set to 0, this means the ssm does not need be modified to match the requested i/o. Faster but dangerous!'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  p = param({'force complete', 'Force the use of the complete simulation code.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  utp.expectedPlists = pl;
  
  
  % Call super class 
  res = test_getInfo@ltpda_uoh_method_tests(varargin{:});
end
% END