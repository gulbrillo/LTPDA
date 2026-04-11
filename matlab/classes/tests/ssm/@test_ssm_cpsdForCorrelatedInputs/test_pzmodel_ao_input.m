% TEST_PZMODEL_AO_INPUT tests the cpsdForCorrelatedInputs method with an input AOs and pzmodels.
function res = test_pzmodel_ao_input(varargin)
  
  utp = varargin{1};
  
  % Build test system
  sys = ssm(plist('built-in', 'HARMONIC_OSC_1D'));
  
  % Make input noise
  a = ao.randn(10,1000);
  b = 0.01 * ao.randn(10,1000) + 0.01 * a;
  axx = psd(a);
  bxx = psd(b);
  abxx = cpsd(a, b);
  baxx = cpsd(b, a);
  
  % Make pzmodels
  p11 = pzmodel(1, 1, []);
  p12 = pzmodel(0.1, 1, 0.1);
  p21 = pzmodel(0.1, 1, 0.1);
  p22 = pzmodel(1, 1, []);
  
  % Get port names
  portNames = sys.getPortNamesForBlocks(plist('blocks', {'COMMAND', 'NOISE'}));
  
  % All outputs
  outputs = sys.getPortNamesForBlocks(plist('blocks', 'HARMONIC_OSC_1D', 'type', 'outputs'));
  
  f = axx.x;
  pl = plist(...
    'AOS VARIABLE NAMES', portNames, ...
    'AOS', [axx abxx; baxx bxx], ...
    'PZMODEL VARIABLE NAMES', portNames, ...
    'PZMODELS', [p11 p12; p21 p22], ...
    'return outputs', outputs);
  
  out = cpsdForCorrelatedInputs(sys, pl);
  
  % Checks
  assert(isa(out, 'matrix'), 'The output of ssm/cpsdForCorrelatedInputs should be a matrix. Got object of class %s', class(out));
  assert(isequal(numel(out), 1), 'Expect a single output AO; got %d', numel(out));
  assert(isa(out.objs(1).data, 'fsdata'), 'The output AO should be a frequency series');
  assert(isequal(out.objs(1).x, f), 'The frequency vector returned doesn''t match the input frequency vector');
  
  
  % Return message
  res = 'ssm/cpsdForCorrelatedInputs passed ao input tests';
    
end
