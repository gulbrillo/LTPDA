% Test that the built-in model responds to the 'describe' call
%

function varargout = test_builtin_model_describe(varargin)
  
  utp = varargin{1};
  
  % Get the model name from the unit test plan (UTP)
  mname = utp.modelFilename;
  
  desc = feval(mname, 'describe');
  assert(ischar(desc));
  assert(~isempty(desc));
  
  desc = feval(mname, 'description');
  assert(ischar(desc));
  assert(~isempty(desc));
  
  varargout{1} = 'Model responds to describe and description';
  
end
