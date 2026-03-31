% SETPARAMS Set the property 'params' AND 'values'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETPARAMS Set the property 'params' AND 'values'
%
% CALL:        obj = obj.setParams({'a', 'b'}, {1 2});
%              obj = obj.setParams({'a', 'b'});
%              obj = obj.setParams(plist('params', {'a', 'b'}, 'values', {1 2}));
%              obj = obj.setParams(plist('params', {'a', 'b'}));
%
% INPUTS:      obj - one ltpda model.
%              pl  - to set the name with a plist specify only one plist with
%                    only the key-words 'params' and 'values'.
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'setParams')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setParams(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    objs   = varargin{1};
    params = varargin{2}; % cell-array
    vals   = varargin{3}; % cell-array
    
  else
    % Check if this is a call for parameters
    if utils.helper.isinfocall(varargin{:})
      varargout{1} = getInfo(varargin{3});
      return
    end
    
    %%% Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    [objs, obj_invars, rest] = utils.helper.collect_objects(varargin(:), '', in_names);
    [pls,  invars, rest] = utils.helper.collect_objects(rest(:), 'plist');
    [pst,  invars, rest] = utils.helper.collect_objects(rest(:), 'pest');
    
    vals   = {};
    params = {};
    %%% If pls contains only one plist with the two keys 'params' and
    %%% 'values' then set the property with a plist.
    if length(pls) == 1 && isa(pls, 'plist') && pls.isparam_core('params')
      params = cellstr(find_core(pls, 'params'));
      if pls.isparam_core('values')
        vals = pls.find_core('values');
        if isnumeric(vals)
          vals = num2cell(vals);
        end
      end
    end
    
    % Look for the parameter values
    if numel(rest) == 1 && iscell(rest{1})
      % setParams({'a1', 'a1'})
      params = [params rest{1}];
    elseif numel(rest) == 2 && iscell(rest{1}) && ( iscell(rest{2}) || isnumeric(rest{2}))
      % setParams({'a1', 'a2'}, [1 2])
      % setParams({'a1', 'a2'}, {1 2})
      params = [params rest{1}];
      if iscell(rest{2})
        vals = [vals rest{2}];
      else
        vals = [vals num2cell(rest{2})];
      end
    elseif numel(rest) == 2 && ischar(rest{1}) && isnumeric(rest{2})
      params = rest(1);
      vals   = rest(2);
    elseif ~isempty(rest) && iscellstr(rest)
      params = rest;
    end
    
    %%% if params are set with pest object
    if isa(pst, 'pest')
      params = pst.names;
      vals  = pst.y;
    end
    
    if isempty(params)
      error('### Please provide at least the params, either directly or inside a plist');
    end
    
    % Combine input plists and default PLIST
    pls = applyDefaults(getDefaultPlist(), pls);
    
  end % callerIsMethod
  
  % Convert 'params' and 'values' into a cell-array
  if ischar(params)
    params = cellstr(params);
  end
  if ~iscell(vals)
    vals = num2cell(vals);
  end
  
  if ~isempty(vals) && numel(params) ~= numel(vals)
    error('### Please specify one value per parameter.');
  end
  
  %%% decide whether we modify the input smodel object, or create a new one.
  objs = copy(objs, nargout);
  
  for objLoop = 1:numel(objs)
    
    % if 'vals' are not empty but the 'values' of the object then create
    % default values for object 'values'
    if ~isempty(vals) && isempty(objs(objLoop).values)
      objs(objLoop).values = cell(size(objs(objLoop).params));
    end
    
    for ll = 1:numel(params)
      pname = params{ll};
      % get index of this param
      idx = strcmp(objs(objLoop).params, pname);
      if any(idx)
        % param already exist
        if ~isempty(vals)
          objs(objLoop).values{idx} = vals{ll};
        end
      else
        % add the new param
        objs(objLoop).params = [objs(objLoop).params params(ll)];
        if ~isempty(vals)
          objs(objLoop).values = [objs(objLoop).values vals(ll)];
        else
          if ~isempty(objs(objLoop).values)
            objs(objLoop).values = [objs(objLoop).values cell(1)];
          end
        end
      end
    end
    
    if ~callerIsMethod
      plh = pls.pset('params', params);
      plh.pset('values', vals);
      objs(objLoop).addHistory(getInfo('None'), plh, obj_invars(objLoop), objs(objLoop).hist);
    end
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, objs);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
  
  % Params
  p = param({'params', 'A cell-array of parameter names.'}, paramValue.EMPTY_CELL);
  pl.append(p);
  
  % Value
  p = param({'values', 'A cell-array of values, one for each parameter to set.'}, paramValue.EMPTY_CELL);
  pl.append(p);
  
end

