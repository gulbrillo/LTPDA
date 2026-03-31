% ADDALIASES Add the key-value pairs to the alias-names and alias-values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ADDALIASES Add the key-value pairs to the alias-names and
%              alias-values. This method will add the key-value pairs to
%              the properties 'aliasNames' and 'aliasValues'. If the
%              alias-name exist then replace this method the existing value
%              with the new value.
%
% CALL:        obj = obj.addAliases('name', 'value');
%              obj = obj.addAliases(key-value pairs);
%              obj = obj.addAliases(plist);
%              obj = obj.addAliases(two cell-arrays);
%
% INPUTS:      obj         - a ltpda smodel object.
%              key-value   - A single key-value pair or a list of key-value
%                            pairs. Thereby it is important that the key is
%                            followed by the value.
%              plist       - Parameter list with values for the keys
%                            'names' and 'values'. The values can be a
%                            single value or a cell array with multiple
%                            values. The number of 'names' and 'values'
%                            must be the same.
%              cell-arrays - Two cell-arrays with the first of the 'names'
%                            and the second with the 'values'.
%
% REMARK:      This function will replace the alias-value if the
%              alias-names already exist
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'addAliases')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = addAliases(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    sm     = varargin{1}; % smodel-object(s)
    names  = varargin{2}; % cell-array with alias-names
    values = varargin{3}; % call-array with alias-values
    
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
    %%% If the input PLIST have the keys 'names' and 'values' then use also
    %%% the
    if length(pls) == 1 && isa(pls, 'plist') && isparam_core(pls, 'names') && isparam_core(pls, 'values')
      names  = find_core(pls, 'names');
      values = find_core(pls, 'values');
      
      % Make sure that the names and the values are cell-arrays
      if ~iscell(names)
        names = cellstr(names);
      end
      if ~iscell(values)
        values = num2cell(values);
      end
      
    end
    
    % Check if we have two cell-array for the 'names' and 'values'
    if numel(rest) == 2 && iscell(rest{1}) && iscell(rest{2})
      names  = [names  rest{1}];
      values = [values rest{2}];
    else
      
      % Check for key-value pairs
      if mod(numel(rest), 2) ~= 0
        error('### Please specify for each alias-name a alias-value');
      end
      nrest = numel(rest);
      names  = [names  rest(1:2:nrest)];
      values = [values rest(2:2:nrest)];
    end
    
    % Combine input plists and default PLIST
    pls = applyDefaults(getDefaultPlist(), pls);
    
  end
  
  % Check that we have the same number of names as the number of values.
  if numel(names) ~= numel(values)
    error('### Please specify for each alias name [%d] one alias value [%d]', numel(names), numel(values));
  end
  
  % Decide on a deep copy or a modify
  sm = copy(sm, nargout);
  
  % Loop over smodel objects
  for oo=1:numel(sm)
    
    for kk=1:numel(names)
      % Look for the index we have to change
      idx = strcmp(sm(oo).aliasNames, names{kk});
      
      if any(idx)
        % Change at the index the value
        sm(oo).aliasValues{idx} = values{kk};
      else
        % Append the alias key-value pair
        sm(oo).aliasNames  = [sm(oo).aliasNames  names(kk)];
        sm(oo).aliasValues = [sm(oo).aliasValues values(kk)];
      end
    end
    
    if ~callerIsMethod
      plh = pls.pset('names',  names);
      plh.pset('values', values);
      sm(oo).addHistory(getInfo('None'), plh, sm_invars(oo), sm(oo).hist);
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
    pl   = getDefaultPlist;
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
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist();
  
  % alias names
  p = param({'names', 'A cell-array with the alias names.'}, paramValue.EMPTY_CELL);
  pl.append(p);
  
  % alias values
  p = param({'values', 'A cell-array with the alias values.'}, paramValue.EMPTY_CELL);
  pl.append(p);
end

