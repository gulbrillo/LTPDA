% SETPARAMETERS Set some parameters to the symbolic model (smodel) object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETPARAMETERS Set some parameters to the symbolic model
%              (smodel) object. It is possible to set only the parameter
%              name or to set the parameter names with their values.
%              Exist the parameter-name in the object then replace this
%              method the existing value.
%
% CALL:        obj = obj.setParameters(key-value pairs);
%              obj = obj.setParameters(plist);
%              obj = obj.setParameters(two cell-arrays);
%              obj = obj.setParameters(single cell-array of names);
%
% INPUTS:      obj         - a ltpda smodel object.
%              key-value   - A single key-value pair or a list of key-value
%                            pairs. Thereby it is important that the key is
%                            followed by the value.
%              plist       - Parameter list with values for the keys
%                            'params' and 'values'. The values can be a
%                            single value or a cell array with multiple
%                            values.
%              cell-arrays - Two cell-arrays with the first of the 'params'
%                            and the second with the 'values'.
%
% REMARK:      This function will replace the parameter value if the
%              parameter name already exist
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'setParameters')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setParameters(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    sm     = varargin{1}; % smodel-object(s)
    names  = varargin{2}; % cell-array with parameter-names
    values = varargin{3}; % call-array with parameter-values
    
  else
    % Check if this is a call for parameters
    if utils.helper.isinfocall(varargin{:})
      varargout{1} = getInfo(varargin{3});
      return
    end
    
    import utils.const.*
    utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
    
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Collect all smodel objects
    [sm,  sm_invars, rest] = utils.helper.collect_objects(varargin(:), 'smodel', in_names);
    [pls, dummy,     rest] = utils.helper.collect_objects(rest(:), 'plist');
    
    names = {};
    values = {};
    %%% If the input PLIST have the keys 'params' and 'values' then use also
    %%% the
    if length(pls) == 1 && isa(pls, 'plist') && isparam_core(pls, 'params')
      names  = find_core(pls, 'params');
      values = find_core(pls, 'values');
      % Make sure that the param names and the values are cell-arrays
      names = cellstr(names);
      if ~iscell(values) && ~isempty(values)
        values = num2cell(values);
      end
    end
    
    % Get the parameter names and the values from the input
    nRest = numel(rest);
    if nRest == 0
      % Don't do anything
    elseif nRest == 1 && iscell(rest{1})
      % setParameters({'a', 'b'})
      names = [names rest{1}];
    elseif ~isempty(rest) && iscellstr(rest)
      % setParameters('a', 'b', 'c')
      names = [names rest];
    elseif nRest == 2 && iscell(rest{1}) && isnumeric(rest{2})
      % setParameters({'a', 'b'}, [1 2])
      names  = [names  rest{1}];
      values = [values num2cell(rest{2})];
    elseif nRest == 2 && iscell(rest{1}) && iscell(rest{2})
      % setParameters({'a', 'b'}, {1 2})
      names  = [names  rest{1}];
      values = [values rest{2}];
    else
      % setParameters('a', 1, 'b', 2, 'c', 3)
      names  = [names  rest(1:2:nRest)];
      values = [values rest(2:2:nRest)];
    end
    
    % Combine input plists and default PLIST
    pls = applyDefaults(getDefaultPlist(), pls);
    
  end
  
  % Check that we have the same number of param names as the number of values.
  if ~isempty(values) && numel(names) ~= numel(values)
    error('### Please specify for each parameter name [%d] one parameter value [%d]', numel(names), numel(values));
  end
  
  % Decide on a deep copy or a modify
  sm = copy(sm, nargout);
  
  % Loop over smodel objects
  for jj = 1:numel(sm)
    
    % Append the key-value pair
    sm(jj).params = names;
    if ~isempty(values)
      sm(jj).values = values;
    end
    
    if ~callerIsMethod
      plh = pls.pset('params',  names);
      plh.pset('values', values);
      sm(jj).addHistory(getInfo('None'), plh, sm_invars(jj), sm(jj).hist);
    end
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, sm);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist();
  
  % parameter names
  p = param({'params', 'A cell-array with the parameter names.'}, paramValue.EMPTY_CELL);
  pl.append(p);
  
  % parameter values
  p = param({'values', 'A cell-array with the parameter values.'}, paramValue.EMPTY_CELL);
  pl.append(p);
end

