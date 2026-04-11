% TEST_VARIANCE_INPUT tests the psd method with an input variance vector.
function res = test_variance_input(varargin)
  
  utp = varargin{1};
  
  % Build test system
  sys = ssm(plist('built-in', 'HARMONIC_OSC_1D'));
  
  
  % Get port names
  portNames = sys.getPortNamesForBlocks(plist('blocks', {'COMMAND', 'NOISE'}));
  
  % All outputs
  outputs = sys.getPortNamesForBlocks(plist('blocks', 'HARMONIC_OSC_1D', 'type', 'outputs'));
  
  f = logspace(-2, 2, 1000);
  pl = plist(...
    'VARIANCE VARIABLE NAMES', portNames, ...
    'VARIANCE', [1 1], ...
    'return outputs', outputs, ...
    'f', f);
  
  out = psd(sys, pl);
  
  % Checks
  assert(isa(out, 'matrix'), 'The output of ssm/psd should be a matrix. Got object of class %s', class(out));
  assert(isequal(numel(out), 1), 'Expect a single output AO; got %d', numel(out));
  assert(isa(out.objs(1).data, 'fsdata'), 'The output AO should be a frequency series');
  assert(isequal(out.objs(1).x, f'), 'The frequency vector returned doesn''t match the requested frequency vector');
  
  
  % Return message
  res = 'ssm/psd passed covariance input tests';
    
end
