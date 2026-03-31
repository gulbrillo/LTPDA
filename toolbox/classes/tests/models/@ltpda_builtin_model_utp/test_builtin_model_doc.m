% Test that the built-in model responds to the 'doc' call
%

function varargout = test_builtin_model_doc(varargin)
  
  utp = varargin{1};
  
  % Get the model name from the unit test plan (UTP)
  mname = utp.modelFilename;
  
  % Check that the 'doc' call works and returns a non-empty string
  desc = feval(mname, 'doc');
  assert(ischar(desc));
  assert(~isempty(desc));
  
  varargout{1} = 'Model responds to doc';
  
end
