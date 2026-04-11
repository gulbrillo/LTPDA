% TEST_AO_INPUT tests the simulate method with an input AO.
function res = test_ao_input(varargin)
  
  utp = varargin{1};
  
  % Build test system
  sys = ssm(plist('built-in', 'HARMONIC_OSC_1D'));
  
  % sample rate
  fs = 10;
  nSecs = 10;
  a = ao.randn(nSecs, fs);
  
  % Get port names
  portNames = sys.getPortNamesForBlocks(plist('blocks', {'COMMAND', 'NOISE'}));
  
  % All outputs
  outputs = sys.getPortNamesForBlocks(plist('blocks', 'HARMONIC_OSC_1D', 'type', 'outputs'));
  
  pl = plist(...
    'AOS VARIABLE NAMES', portNames, ...
    'AOS', [a a], ...
    'return outputs', outputs);
  
  sys.modifyTimeStep(1/fs);  
  out = simulate(sys, pl);
  
  % Checks
  assert(isa(out, 'matrix'), 'The output of ssm/simulate should be a matrix. Got object of class %s', class(out));
  assert(isequal(numel(out), 1), 'Expect a single output AO; got %d', numel(out));
  assert(isa(out.objs(1).data, 'tsdata'), 'The output AO should be a time-series');
  assert(isequal(numel(out.objs(1).x), nSecs*fs), 'The time vector returned doesn''t have the requested number of samples');
  assert(isequal(out.objs(1).fs, fs), 'The time series returned doesn''t have the same sample rate as the model');
  assert(isequal(out.objs(1).nsecs, nSecs), 'The time series returned doesn''t have the requested number of seconds');
  assert(isequal(out.objs(1).x, a.x), 'The time series returned doesn''t have the same x vector as the input AO');
  
  
  % Return message
  res = 'ssm/simulate passed ao input tests';
    
end
