% TEST_SUBSTITUTE tests substituting parameters.
function res = test_substitute(varargin)
  
  
  utp = varargin{1};
  
  % Test System
  sys = utp.testData;

  % Substitute one parameter
  out1 = sys.subsParameters(plist('names', 'M'));
  
  assert(isa(out1, 'ssm'), 'The output of subsParameters should be an ssm object');
  assert(~strcmp(out1.UUID, sys.UUID), 'The output ssm object of subsParameters should have a different UUID when we are not modifying');
  assert(~out1.params.isparam('M'), 'The parameter ''M'' should not appear in the output system''s parameter list.');
  assert(out1.numparams.isparam('M'), 'The parameter ''M'' should appear in the output system''s numerical parameter list.');
  % check the original didn't get modified
  assert(sys.params.isparam('M'), 'The parameter ''M'' should appear in the input system''s parameter list.');
  assert(~sys.numparams.isparam('M'), 'The parameter ''M'' should appear in the input system''s numerical parameter list.');
  
  % Substitute two parameters
  out2 = sys.subsParameters(plist('names', {'M', 'K'}));
  
  assert(isa(out2, 'ssm'), 'The output of subsParameters should be an ssm object');
  assert(~strcmp(out2.UUID, sys.UUID), 'The output ssm object of subsParameters should have a different UUID when we are not modifying');
  assert(~out2.params.isparam('M'), 'The parameter ''M'' should not appear in the output system''s parameter list.');
  assert(out2.numparams.isparam('M'), 'The parameter ''M'' should appear in the output system''s numerical parameter list.');
  assert(~out2.params.isparam('K'), 'The parameter ''K'' should not appear in the output system''s parameter list.');
  assert(out2.numparams.isparam('K'), 'The parameter ''K'' should appear in the output system''s numerical parameter list.');
  % check the original didn't get modified
  assert(sys.params.isparam('M'), 'The parameter ''M'' should appear in the input system''s parameter list.');
  assert(~sys.numparams.isparam('M'), 'The parameter ''M'' should appear in the input system''s numerical parameter list.');
  assert(sys.params.isparam('K'), 'The parameter ''K'' should appear in the input system''s parameter list.');
  assert(~sys.numparams.isparam('K'), 'The parameter ''K'' should appear in the input system''s numerical parameter list.');
  
  % Modify
  sys2 = copy(sys,1);
  sys2.subsParameters(plist('names', {'M', 'K'}));
  assert(isa(sys2, 'ssm'), 'The output of subsParameters should be an ssm object');
  assert(~sys2.params.isparam('M'), 'The parameter ''M'' should not appear in the output system''s parameter list.');
  assert(sys2.numparams.isparam('M'), 'The parameter ''M'' should appear in the output system''s numerical parameter list.');
  assert(~sys2.params.isparam('K'), 'The parameter ''K'' should not appear in the output system''s parameter list.');
  assert(sys2.numparams.isparam('K'), 'The parameter ''K'' should appear in the output system''s numerical parameter list.');
  
  % Substitute all
  out3 = sys.subsParameters;
  assert(isa(out3, 'ssm'), 'The output of subsParameters should be an ssm object');
  assert(~out3.params.isparam('M'), 'The parameter ''M'' should not appear in the output system''s parameter list.');
  assert(out3.numparams.isparam('M'), 'The parameter ''M'' should appear in the output system''s numerical parameter list.');
  assert(~out3.params.isparam('K'), 'The parameter ''K'' should not appear in the output system''s parameter list.');
  assert(out3.numparams.isparam('K'), 'The parameter ''K'' should appear in the output system''s numerical parameter list.');
  assert(~out3.params.isparam('VBETA'), 'The parameter ''VBETA'' should not appear in the output system''s parameter list.');
  assert(out3.numparams.isparam('VBETA'), 'The parameter ''VBETA'' should appear in the output system''s numerical parameter list.');
  % check the original didn't get modified
  assert(sys.params.isparam('M'), 'The parameter ''M'' should appear in the input system''s parameter list.');
  assert(~sys.numparams.isparam('M'), 'The parameter ''M'' should appear in the input system''s numerical parameter list.');
  assert(sys.params.isparam('K'), 'The parameter ''K'' should appear in the input system''s parameter list.');
  assert(~sys.numparams.isparam('K'), 'The parameter ''K'' should appear in the input system''s numerical parameter list.');
  assert(sys.params.isparam('VBETA'), 'The parameter ''VBETA'' should appear in the input system''s parameter list.');
  assert(~sys.numparams.isparam('VBETA'), 'The parameter ''VBETA'' should appear in the input system''s numerical parameter list.');
    
  % Call super class 
  res = 'Performed tests of subsParameters';
end
% END
