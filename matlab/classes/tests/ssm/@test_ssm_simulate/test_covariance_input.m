% TEST_COVARIANCE_INPUT tests the simulate method with an input covariance
% matrix.
function res = test_covariance_input(varargin)
  
  utp = varargin{1};
  
  % Build test system
  sys = ssm(plist('built-in', 'HARMONIC_OSC_1D'));
  
  % sample rate
  fs = 10;
  
  % Make covariance matrix for all inputs
  cov = eye(2); % The model has two inputs
  
  % Get port names
  portNames = sys.getPortNamesForBlocks(plist('blocks', {'COMMAND', 'NOISE'}));
  
  % All outputs
  outputs = sys.getPortNamesForBlocks(plist('blocks', 'HARMONIC_OSC_1D', 'type', 'outputs'));
  
  nSecs = 100;
  pl = plist(...
    'COVARIANCE VARIABLE NAMES', portNames, ...
    'COVARIANCE', cov, ...
    'return outputs', outputs, ...
    'nsamples', nSecs*fs);
  
  sys.modifyTimeStep(1/fs);
  out = simulate(sys, pl);
  
  % Checks
  assert(isa(out, 'matrix'), 'The output of ssm/simulate should be a matrix. Got object of class %s', class(out));
  assert(isequal(numel(out), 1), 'Expect a single output AO; got %d', numel(out));
  assert(isa(out.objs(1).data, 'tsdata'), 'The output AO should be a time-series');
  assert(isequal(numel(out.objs(1).x), nSecs*fs), 'The time vector returned doesn''t have the requested number of samples');
  assert(isequal(out.objs(1).fs, fs), 'The time series returned doesn''t have the same sample rate as the model');
  assert(isequal(out.objs(1).nsecs, nSecs), 'The time series returned doesn''t have the requested number of seconds');
  
  
  % Return message
  res = 'ssm/simulate passed covariance input tests';
    
end
