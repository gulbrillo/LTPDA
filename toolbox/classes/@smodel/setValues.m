% SETVALUES Set the property 'values'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETVALUES Set the property 'values'
%
% CALL:        obj = obj.setValues({1 2});
%              obj = obj.setValues([1 2]);
%              obj = obj.setValues(plist('values', {1 2}));
%
% INPUTS:      obj - one ltpda model.
%              pl  - to set the name with a plist specify only one plist with
%                    only one key-word 'values'.
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'setValues')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setValues(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    objs = varargin{1};
    
    if ~iscell(varargin{2})
      nv = num2cell(varargin{2});
    else
      nv = varargin{2};
    end
    
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
    
    %%% If pls contains only one plist with the single key 'values' then set the
    %%% property with a plist.
    if length(pls) == 1 && isa(pls, 'plist') && nparams(pls) == 1 && isparam_core(pls, 'values')
      rest{1} = find_core(pls, 'values');
    end
    
    if numel(rest) > 1 || isempty(rest)
      error('### Please specify the values inside a vector or a cell array!');
    end
    
    % If 'vals' is an AO or pest then get the 'values' from the y-values.
    if isa(rest{1}, 'ao')
      rest{1} = rest{1}.y;
    elseif isa(rest{1}, 'pest')
      rest{1} = rest{1}.y;
    end
    
    % Conver 'values' into a cell-array
    if ~iscell(rest{1})
      nv = num2cell(rest{1});
    else
      nv = rest{1};
    end
    
    %%% Combine plists
    pls = applyDefaults(plist('values', nv), pls);
    
  end % callerIsMethod
  
  %%% decide whether we modify the input smodel object, or create a new one.
  objs = copy(objs, nargout);
  
  %%% Set the 'values'
  for ii = 1:numel(objs)
    if numel(nv) == numel(objs(ii).params)
      objs(ii).values = nv;
      if ~callerIsMethod
        plh = pls.pset('values', nv);
        objs(ii).addHistory(getInfo('None'), plh, obj_invars(ii), objs(ii).hist);
      end
    else
      fprintf('Number of parameters of the %dth object is %d, while you provided %d values. Skipping it!\n', ii, numel(objs(ii).params), numel(nv));
    end
  end
  
  %%% Set output
  if nargout == numel(objs)
    % List of outputs
    for ii = 1:numel(objs)
      varargout{ii} = objs(ii);
    end
  else
    % Single output
    varargout{1} = objs;
  end
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
  pl = plist({'values', 'A cell-array of values, one for each parameter in the model.'}, paramValue.EMPTY_CELL);
end

