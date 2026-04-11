% APPLYDEFAULTS apply the default plist to the input plists
% 
% CALL:
%       plout = applyDefaults(defaultPlist, pl1, pl2, ..., pl3)
%       [plout, pl_unused] = applyDefaults(defaultPlist, pl1, pl2, ..., pl3)
% 
% The default plist is assumed to be the first one.
% 
% The plists are combined and the resulting keys are compared to the keys
% in the default plist. If any key is missing from the default plist a
% warning is issued.
% 

function varargout = applyDefaults(varargin)
  
  
  % Try to just form an array of the inputs. If that fails, fall back to
  % collect_objects.
  try
    inputs = [varargin{:}];
    exceptions = {};
    fail_action = [];
  catch
    inputs      = utils.helper.collect_objects(varargin(:), 'plist');
    exceptions  = utils.helper.collect_objects(varargin(:), 'cell');
    fail_action = utils.helper.collect_objects(varargin(:), 'double');
  end
  
  % Note: any keys which are in 'exceptions' will be propagated from the
  % input user plist to the output. This is done by adding the exceptions
  % to the default plist below which 'tricks' this method into propagating
  % the parameters.
  
  % Decide what to do in the case the user input parameters not belonging to the default plist
  KEY_ACTION_WARNING = double(mpipeline.ltpdapreferences.DisplayPrefGroup.KEY_ACTION_WARNING);
  KEY_ACTION_ERROR = double(mpipeline.ltpdapreferences.DisplayPrefGroup.KEY_ACTION_ERROR);
  
  if isempty(fail_action)
    prefs = getappdata(0, 'LTPDApreferences');
    fail_action = double(prefs.getDisplayPrefs.getDisplayKeyAction);
  end
  
  % trivial case
  if numel(inputs) == 1
    varargout{1} = copyWithDefault(inputs, true);
    return;
  end  
  
  % Get the default plist and copy it because we modify it by setting the
  % user's values
  default = copyWithDefault(inputs(1), true);
  
  % Get the rest
  pls = inputs(2:end);
  
  % combine the user's input plists
  if numel(pls) == 1
    userplist = copy(pls, 1);
  else
    userplist = combine(pls);
  end
  
  % add exceptions to the default plist so they will be propagated to the
  % output plist
  if ~isempty(exceptions)
    userex = find(utils.helper.ismember(exceptions, userplist.getAllKeys));
    for kk=1:numel(userex)
      default.pset(exceptions{userex(kk)}, []);
    end
  end
  
  % check keys against default keys  
  res = matchKeys_core(userplist, default.getAllKeys);
  if ~all(res)
    keyNames = userplist.getKeys();
    msg = sprintf('The following keys were not found in the default plist and will be ignored: [%s]\n', strtrim(sprintf('%s ', keyNames{~res})));
    switch fail_action
      case KEY_ACTION_ERROR
        error(msg);
      case KEY_ACTION_WARNING
        warning(msg);
      otherwise
    end
  end
    
  % combine defaults
  [default, unused] = overrideDefaults(userplist, default);
    

  % output the used and unused plists
  varargout{1} = default;
  if nargout >= 2
    varargout{2} = unused;
  end
  
end


function [default, unused] = overrideDefaults(userplist, default)
  
  unused = [];
  
  for kk = 1:numel(userplist.params)
    
    % which key are we acting on
    key = userplist.params(kk).key;
    
    % get override value from user
    val = userplist.params(kk).val;
    
    % decide what to do based on the presence or not of the parameter in the default plist
    if isparam_core(default, key)
      % set the parameter value      
      if isa(val, 'paramValue')
        val = val.getVal;
      end
      
      idx = matchKeys_core(default, key);
      if sum(idx) ~= 1
        error('A user key was not found (or found more than once) in the default plist.');
      end
      default.params(idx).setVal(val);
      
    else
      if isempty(unused)
        unused = plist();
      end
      % append the parameter value, to the unused parameters plist
      unused.append(copy(userplist.params(kk), true));
    end
  end
  
  % reset cached keys
  default.resetCachedKeys();
  if ~isempty(unused)
    unused.resetCachedKeys();
  end
end
