% Test that the built-in model responds to the 'info' call
%

function varargout = test_builtin_model_info(varargin)
  
  utp = varargin{1};
  
  % Get the model and class name from the unit test plan (UTP)
  clname    = utp.className;
  mname     = utp.methodName;
  mfilename = utp.modelFilename;
  
  info = feval(mfilename, 'info');
  assert(isa(info, 'minfo'));
  
  % build the model and check the history has the same info
  m = feval(clname, plist('built-in', mname).combine(utp.configPlist));
  
  if utils.helper.isSubclassOf(class(m), 'ltpda_uoh')
    for ii = 1:numel(m)
      assert(isequal(m(ii).hist.methodInfo.children, info.clearSets(), 'created', 'UUID', 'proctime'))
    end
  end
  
  varargout{1} = 'Model responds to info call';
  
end
