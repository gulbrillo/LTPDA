% SETPROPERTYVALUE sets the value of a property of one or more objects.
%
% CALL:
%        varargout = setPropertyValue(inputs, ...
%                                     input_names, ...
%                                     callerIsMethod, ...
%                                     propName, ...
%                                     setterFcn, ...
%                                     copy, ...
%                                     getInfo)
%
%
%
%
%
% The setterFcn should have the following signature:
%
%    setterFcn(object, plist, value)
%
% The plist is passed to allow the setter function to modify the plist if
% necessary.
%
%
function varargout = setPropertyValue_core(varargin)
  
  % get inputs and configuration structure
  inputs = varargin(1:end-1);
  config = varargin{end};
  
  % Collect inputs
  if config.callerIsMethod
    objects     = inputs{1};
    configPlist = [];
    values      = inputs(2:end);
    obj_innames = {};
  else
    [objects, obj_innames, rest] = utils.helper.collect_objects(inputs(:), '', config.inVarNames);
    [configPlist, ~, values]     = utils.helper.collect_objects(rest(:), 'plist');
  end
  
  % Process the values we want to set
  [objects, values] = processSetterValues(objects, configPlist, values, config.propName, config.propDefVal);
  
  % Decide on a deep copy or a modify
  bs = copy(objects, config.doCopy);
  
  usedValues = cell(size(bs));
  
  % Loop over objects and set the values by calling the setter function
  for jj = 1:numel(bs)
    % If the values are empty, we use the input plist as the value for
    % all objects. We copy if first in case the setterFcn modifies it.
    if isempty(values)
      if isempty(configPlist)
        % Here we create a plist so that the setterFcn has a plist in
        % case it wants to modify it before it goes in the history.
        configPl = plist();
        usedValues{jj} = config.setterFcn(bs(jj), configPl, values);
      else
        % Here use the input PLIST as the value
        configPl = plist();
        usedValues{jj} = config.setterFcn(bs(jj), configPl, copy(configPlist,1));
      end
    else
      usedValues{jj} = config.setterFcn(bs(jj), configPlist, values{jj});
    end
  end
  
  % Use the configPl from the setterFcn in case the setterFcn has modifies
  % the configuration PLIST.
  if exist('configPl', 'var') && ~isempty(configPl)
    configPlist = configPl;
  end
  % Make sure that we have at least an empty configuration PLIST
  if isempty(configPlist)
    configPlist = plist();
  end
  
  % Set output
  varargout{1} = bs;
  if nargout > 1
    varargout{2} = usedValues;
  end
  if nargout > 2
    varargout{3} = configPlist;
  end
  if nargout > 3
    varargout{4} = obj_innames;
  end
  
end


