% Test that the built-in model responds to the 'plist' call.
%

function varargout = test_builtin_model_plist(varargin)
  
  utp = varargin{1};
  
  % Get the model name from the unit test plan (UTP)
  mname = utp.modelFilename;
  
  % Check that we can get a plist back with the 'plist' input
  pl = feval(mname, 'plist');
  assert(isa(pl, 'plist'));
  
  varargout{1} = 'Model responds to plist call';
  
end
