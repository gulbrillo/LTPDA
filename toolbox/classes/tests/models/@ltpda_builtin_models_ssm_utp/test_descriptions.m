% TEST_DESCRIPTIONS checks that the descriptions for the different fields
% of all versions has been filled (is not empty).
function res = test_descriptions(varargin)
  
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
    
    % check input descriptions
    assert(~any(cellfun('isempty', {obj.inputs.description})), 'At least one input block description is empty for version %s', v);
    
    ports = [obj.inputs.ports];
    assert(~any(cellfun('isempty', {ports.description})), 'At least one input port description is empty for version %s', v);
    
    % check output descriptions
    assert(~any(cellfun('isempty', {obj.inputs.description})), 'At least one input block description is empty for version %s', v);
    
    ports = [obj.outputs.ports];
    assert(~any(cellfun('isempty', {ports.description})), 'At least one output port description is empty for version %s', v);
    
    % check parameter descriptions
    if numel(obj.numparams.params) > 0
      assert(~any(cellfun('isempty', {obj.numparams.params.desc})), 'At least one parameter description is empty for version %s', v);
    end
    if numel(obj.params.params) > 0
      assert(~any(cellfun('isempty', {obj.params.params.desc})), 'At least one parameter description is empty for version %s', v);
    end
  end
  
  res = 'Checked descriptions of all model fields';
  
end
% END