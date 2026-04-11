% TEST_PZMODEL_AO_INPUT tests the cpsd method with an input AOs and pzmodels.
function res = test_pzmodel_ao_input(varargin)
  
  utp = varargin{1};
  
  % Build test system
  sys = ssm(plist('built-in', 'HARMONIC_OSC_1D'));
  
  % Make input noise
  a = psd(ao.randn(10,1000));
  
  % Make pzmodels
  p1 = pzmodel(1, 1, []);
  p2 = pzmodel(0.1, 1, 0.1);
  
  % Get port names
  portNames = sys.getPortNamesForBlocks(plist('blocks', {'COMMAND', 'NOISE'}));
  
  % All outputs
  outputs = sys.getPortNamesForBlocks(plist('blocks', 'HARMONIC_OSC_1D', 'type', 'outputs'));
  
  f = a.x;
  pl = plist(...
    'AOS VARIABLE NAMES', portNames, ...
    'AOS', [a a], ...
    'PZMODEL VARIABLE NAMES', portNames, ...
    'PZMODELS', [p1 p2], ...
    'return outputs', outputs);
  
  out = cpsd(sys, pl);
  
  % Checks
  assert(isa(out, 'matrix'), 'The output of ssm/cpsd should be a matrix. Got object of class %s', class(out));
  assert(isequal(numel(out), 1), 'Expect a single output AO; got %d', numel(out));
  assert(isa(out.objs(1).data, 'fsdata'), 'The output AO should be a frequency series');
  assert(isequal(out.objs(1).x, f), 'The frequency vector returned doesn''t match the input frequency vector');
  
  
  % Return message
  res = 'ssm/cpsd passed ao input tests';
    
end
