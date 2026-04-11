% Test that all versions of the built-in model can be built, and re-built
%

function varargout = test_builtin_model_versions(varargin)
  
  utp = varargin{1};
  
  % Get the model and class name from the unit test plan (UTP)
  mname     = utp.methodName;
  clname    = utp.className;
  mfilename = utp.modelFilename;
  
  % get the default plist of the model
  pl = feval(mfilename, 'plist');
  
  % get list of the available versions
  versions = pl.getOptionsForParam('version');
  
  % try to build each version
  ipl = plist('built-in', mname);
  ipl = ipl.combine(utp.configPlist);
  for kk=1:numel(versions)
    v = versions{kk};
    ipl.pset('version', v);
    obj = feval(clname, ipl);
    
    if utils.helper.isSubclassOf(class(obj), 'ltpda_uoh')
      r = rebuild(obj);  
      assert(isequal(r, obj, 'proctime', 'UUID', 'methodInvars', 'context'), 'Failed to rebuild version %s of %s', v, mname);
    end
  end
  
  varargout{1} = 'Model can build all versions';
  
end
