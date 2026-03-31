% TEST_COVARIANCE_INPUT tests the cpsdForCorrelatedInputs method with an input covariance
% matrix.
function res = test_covariance_input(varargin)
  
  utp = varargin{1};
  
  % Build test system
  sys = ssm(plist('built-in', 'HARMONIC_OSC_1D'));
  
  % Make covariance matrix for all inputs
  cov_mat = eye(2); % The model has two inputs
  
  % Get port names
  portNames = sys.getPortNamesForBlocks(plist('blocks', {'COMMAND', 'NOISE'}));
  
  % All outputs
  outputs = sys.getPortNamesForBlocks(plist('blocks', 'HARMONIC_OSC_1D', 'type', 'outputs'));
  
  f = logspace(-2, 2, 1000);
  pl = plist(...
    'COVARIANCE VARIABLE NAMES', portNames, ...
    'COVARIANCE', cov_mat, ...
    'return outputs', outputs, ...
    'f', f);
  
  out = cpsdForCorrelatedInputs(sys, pl);
  
  % Checks
  assert(isa(out, 'matrix'), 'The output of ssm/cpsdForCorrelatedInputs should be a matrix. Got object of class %s', class(out));
  assert(isequal(numel(out), 1), 'Expect a single output AO; got %d', numel(out));
  assert(isa(out.objs(1).data, 'fsdata'), 'The output AO should be a frequency series');
  assert(isequal(out.objs(1).x, f'), 'The frequency vector returned doesn''t match the requested frequency vector');
  
  
  % Return message
  res = 'ssm/cpsdForCorrelatedInputs passed covariance input tests';
    
end
