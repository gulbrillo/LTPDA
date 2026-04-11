% TEST_AO_INPUT tests the cpsdForCorrelatedInputs method with an input AOs.
function res = test_ao_input(varargin)
  
  utp = varargin{1};
  
  % Build test system
  sys = ssm(plist('built-in', 'HARMONIC_OSC_1D'));
  
  % Make input noise
  fs = 10;
  nsecs = 1000;
  a = ao.randn(nsecs,fs);
  b = 0.01 * ao.randn(nsecs,fs) + 0.01 * a;
  axx = psd(a);
  bxx = psd(b);
  abxx = cpsd(a, b);
  baxx = cpsd(b, a);
  
  % Get port names
  portNames = sys.getPortNamesForBlocks(plist('blocks', {'COMMAND', 'NOISE'}));
  
  % All outputs
  outputs = sys.getPortNamesForBlocks(plist('blocks', 'HARMONIC_OSC_1D', 'type', 'outputs'));
  
  f = axx.x;
  pl = plist(...
    'AOS VARIABLE NAMES', portNames, ...
    'AOS', [axx abxx;baxx bxx], ...
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
