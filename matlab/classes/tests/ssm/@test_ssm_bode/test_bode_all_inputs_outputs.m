% TEST_BODE_ALL_INPUTS_OUTPUTS tests the bode method with all inputs and outputs.
function res = test_bode_all_inputs_outputs(varargin)
  
  utp = varargin{1};
  
  % Test data
  sys = utp.testData;
  
  % Make bode
  out = bode(sys, utp.configPlist);
  
  % Check output class
  assert(isa(out, 'matrix'), 'The output of ssm/bode should be a matrix object');
  
  % Check number of resulting bodes
  % for the harmonic oscillator model we have 2 inputs and 1 output
  assert(isequal(numel(out.objs), 2), 'The output of bode should contain 2 AOs.');
  
  % Check frequency vectors
  for kk=1:numel(out.objs)
    obj = out.objs(kk);
    assert(isequal(obj.x', utp.configPlist.find('f')), 'The frequency vector in the output AOs should match the specified frequency vector.');    
  end  
  
  % Return message
  res = 'ssm/bode passed all input/output tests';
    
end
