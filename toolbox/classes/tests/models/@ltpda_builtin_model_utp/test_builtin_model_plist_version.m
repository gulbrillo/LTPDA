% Test that the built-in model has a default plist with a 'VERSION' key.
%

function varargout = test_builtin_model_plist_version(varargin)
  
  utp = varargin{1};
  
  % Get the model name from the unit test plan (UTP)
  mname = utp.modelFilename;
  
  pl = feval(mname, 'plist');
  ver = pl.find('version');
  assert(ischar(ver));
  assert(~isempty(ver));
  
  varargout{1} = 'Model plist contains the VERSION key';
  
end
