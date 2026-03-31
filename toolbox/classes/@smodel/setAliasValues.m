% SETALIASVALUES Set the property 'aliasValues'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETALIASVALUES Set the property 'aliasValues'
%
% CALL:        obj = obj.setAliasValues({1, 2});
%              obj = obj.setAliasValues([1 2]);
%              obj = obj.setAliasValues({smodel(1), smodel(2)});
%              obj = obj.setAliasValues(plist('aliasValues', {1 2}));
%
% INPUTS:      obj - one ltpda model.
%              pl  - to set the name with a plist specify only one plist with
%                    only one key-word 'aliasValues'.
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'setAliasValues')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setAliasValues(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  %%% Internal call: Only one object + don't look for a plist
  if utils.helper.callerIsMethod
    
    %%% decide whether we modify the first object, or create a new one.
    varargin{1} = copy(varargin{1}, nargout);
    
    for kk = 1:numel(varargin{1})
      varargin{1}(kk).aliasValues = varargin{2};
    end
    varargout{1} = varargin{1};
    return
  end
  
  %%% Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  [objs, obj_invars, rest] = utils.helper.collect_objects(varargin(:), '', in_names);
  [pls,  invars, rest] = utils.helper.collect_objects(rest(:), 'plist');
  
  %%% If pls contains only one plist with the single key 'aliasValues' then set the
  %%% property with a plist.
  if length(pls) == 1 && isa(pls, 'plist') && nparams(pls) == 1 && isparam_core(pls, 'aliasValues')
    rest{1} = find_core(pls, 'aliasValues');
  end
  
  if numel(rest) > 1 || isempty(rest)
    error('### Please specify the values inside a vector or a cell array!');
  end
  
  %%% Combine plists
  pls = applyDefaults(plist('aliasValues', rest{1}), pls);
  
  % Convert 'aliasValues' into a cell-array
  if isnumeric(rest{1})
    nv = num2cell(reshape(rest{1}, 1, []));
  elseif ischar(rest{1})
    nv = cellstr(rest{1});
  elseif isa(rest{1},'smodel')
    nv = cell(rest{1});
  elseif iscell(rest{1})
    nv = rest{1};
  else
    error('### The value for the property ''aliasValues'' must be a cell of numbers, strings or smodels. But it is from class [%s]', class(rest{1}));
  end

  % Set the 'values'
  for ii = 1:numel(objs)
    if numel(nv) == numel(objs(ii).aliasNames)
      % decide whether we modify the input smodel object, or create a new one.
      objs(ii) = copy(objs(ii), nargout);
      
      % set the value
      objs(ii).aliasValues = nv;
      objs(ii).addHistory(getInfo('None'), pls, obj_invars(ii), objs(ii).hist);
    else
      fprintf('Number of aliasNames of the %dth object is %d, while you provided %d aliasValues. Skipping it!', ...
        ii, numel(objs(ii).aliasNames), numel(nv));
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
  
  % Value
  p = param({'aliasValues', 'A cell-array of aliasValues, one for each aliasNames in the model.'}, paramValue.EMPTY_CELL);
  pl.append(p);
  
end

