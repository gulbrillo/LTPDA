% PROCESSMODELINPUTS processes the various input options for built-in
% models. 
% 
% The function requires various pieces of information about the model:
% 
% [info, pl, constructorInfo, fcn] = ...
%         processModelInputs(options, ... 
%                            modelname, ...
%                            getModelDescription,  ...
%                            getModelDocumentation, ...
%                            getVersion, ...
%                            versionTable)
% 
% options - the options passed by the constructor to the model
%                       
% 

function [info, pl, constructorInfo, fcn] = processModelInputs(options, modelname, getModelDescription, getModelDocumentation, getVersion, versionTable, varargin)
  
  KEY_ACTION_NONE = double(mpipeline.ltpdapreferences.DisplayPrefGroup.KEY_ACTION_NONE);
  
  info = [];
  pl   = [];
  constructorInfo = [];
  fcn  = [];
    
  if ischar(options{1})
    if strcmpi(options{1}, 'describe') || strcmpi(options{1}, 'description')
      if numel(options) == 2 && ischar(options{2})
        version = options{2};
      else
        vt = versionTable();
        version = vt{1};
      end
      info = utils.models.getDescription(getModelDescription, versionTable, version, getVersion);
    elseif strcmpi(options{1}, 'doc')
      info = getModelDocumentation();
      if isempty(info)
        info = 'no documentation';
      end
    elseif strcmpi(options{1}, 'versionTable')
      info = versionTable();
    elseif strcmpi(options{1}, 'version')
      info = getVersion();
    elseif strcmpi(options{1}, 'plist') % for backwards compatibility
      if numel(options) == 2 && ischar(options{2})
        info = utils.models.getDefaultPlist(getModelDescription, versionTable, options{2});
      else
        info = utils.models.getDefaultPlist(getModelDescription, versionTable);
      end
    elseif strcmpi(options{1}, 'parameters') 
      vt = versionTable();
      if numel(options) == 2 && ischar(options{2})
        version = options{2};
      else
        version = vt{1};
      end
      
      versionFcn = vt{1+find(strcmp(version, vt))};
      info = feval(versionFcn, 'parameters');
    elseif strcmpi(options{1}, 'states') 
      vt = versionTable();
      if numel(options) == 2 && ischar(options{2})
        version = options{2};
      else
        version = vt{1};
      end
      
      versionFcn = vt{1+find(strcmp(version, vt))};
      info = feval(versionFcn, 'states');      
    elseif strcmpi(options{1}, 'outputs') 
      vt = versionTable();
      if numel(options) == 2 && ischar(options{2})
        version = options{2};
      else
        version = vt{1};
      end
      
      versionFcn = vt{1+find(strcmp(version, vt))};
      info = feval(versionFcn, 'outputs');
    elseif strcmpi(options{1}, 'inputs') 
      vt = versionTable();
      if numel(options) == 2 && ischar(options{2})
        version = options{2};
      else
        version = vt{1};
      end
      
      versionFcn = vt{1+find(strcmp(version, vt))};
      info = feval(versionFcn, 'inputs');
      
    elseif strcmpi(options{1}, 'info')
      if numel(options) == 2 && ischar(options{2})
        ver = options{2};
      else
        pl = utils.models.getDefaultPlist(getModelDescription, versionTable);
        ver = pl.find('version');
      end
      info = utils.models.getInfo(modelname, getModelDescription, versionTable, ver, getVersion, varargin{:});
    else
      error('incorrect inputs');
    end
    return
  end
  
  % Inputs and default values
  userPlist = options{1};
  version = userPlist.find('version');
  if isempty(version)
    vers = versionTable();
    version = vers{1};
  end
  if numel(options) > 1
    constructorInfo = options{2};
    pl = combine(userPlist, constructorInfo.plists, utils.models.getDefaultPlist(getModelDescription, versionTable, version));
  else
    constructorInfo = '';
    pl = combine(userPlist, utils.models.getDefaultPlist(getModelDescription, versionTable, version));
  end
    
  % Build the object
  fcn = utils.models.functionForVersion(getModelDescription, versionTable, version);
  
  if ~isempty(constructorInfo)
    constructorInfo.addChildren(utils.models.getInfo(modelname, getModelDescription, versionTable, version, getVersion, varargin{:}));
  end
  
end
