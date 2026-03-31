% SUBS substitutes symbolic parameters with the given values.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SUBS substitutes symbolic parameters with the given values.
%
% CALL:        mdl = mdl.subs(pl)
%              mdl = mdl.subs('all')       % Substitutes all parameters
%              mdl = mdl.subs('a', 'b')    % Substitutes the parameters 'a' and
%                                            'b' with their default values
%              mdl = mdl.subs({'a', 'b'})  % Substitutes the parameters 'a' and
%                                            'b' with their default values
%              mdl = mdl.subs('a', 33)     % Substitutes the parameters 'a'
%                                            with 33
%              mdl = mdl.subs({'a'}, {33}) % Substitutes the parameters 'a'
%                                            with 33
%
% Examples
% --------
%
% 1)   m = subs(m, plist('Params', 'all')) % substitute all default values
% 2)   m = subs(m, plist('Params', {'a', 'b'}, 'Values',{1, 1:10})) % substitute
%                                                            values
% 3)   m = subs(m, plist('Params', {'a', 'b'})) % substitute default values
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'subs')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = subs(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [mdls, mdl_invars, rest] = utils.helper.collect_objects(varargin(:), 'smodel', in_names);
  [pls,  pl_invars,  rest] = utils.helper.collect_objects(rest, 'plist', in_names);
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pls);
  
  % Check if the user uses a plist or not
  if isempty(pls) && ~isempty(rest)
    % The user doesn't use a input plist
    iparams     = {};
    ivals       = {};
    iexceptions = {};
    % Collect each character or cellstr in 'rest' as a parameter
    % Collect each integer of numeric cell 
    for ii=1:numel(rest)
      if ischar(rest{ii}) && strcmp(rest{ii}, 'all') && ii == 1
        iparams = 'all';
        break;
      elseif ischar(rest{ii})
        iparams = [iparams rest{ii}];
      elseif iscellstr(rest{ii})
        iparams = [iparams rest{ii}];
      elseif isnumeric(rest{ii})
        ivals = [ivals rest{ii}];
      elseif iscell(rest{ii})
        c = rest{ii};
        for kk=1:numel(c)
          if isnumeric(c{kk}), ivals = [ivals c{kk}]; end
        end
      end
    end
    pl.pset('params', iparams);
    pl.pset('values', ivals);
    
  else
    % The user uses a input plist
    iparams     = find_core(pl, 'params');
    ivals       = find_core(pl, 'values');
    iexceptions = find_core(pl, 'exceptions');
  end
  
  %
  
  % Loop over input models
  bs = copy(mdls, nargout);
  for j=1:numel(mdls)
    
    mdl = bs(j);
    
    if ischar(iparams)
      if strcmpi(iparams, 'all')
        iparams = mdl.params;
        ivals   = mdl.values;
      else
        iparams = {iparams};
      end
    end
    
    if isempty(ivals)
      ivals = {};
      % get values from the model
      for ll=1:numel(iparams)
        idx = find_core(strcmp(iparams{ll}, mdl.params));
        ivals = [ivals mdl.values(idx)];
      end
    end
    
    % remove the exceptions from the params list
    if ~isempty(iexceptions)
      idx = ismember(iparams, iexceptions);
      iparams = iparams(~idx);
      ivals   = ivals(~idx);
    end
    
    if isempty(ivals) && ~strcmpi(iparams, 'all')
      error('### Please specify one value per parameter to substitute.');
    end
    if ~ischar(iparams) && numel(iparams) ~= numel(ivals)
      error('### Please specify one value per parameter to substitute.');
    end
    
    if ~iscell(ivals)
      ivals = {ivals};
    end
    
    if numel(iparams) ~= numel(ivals)
      error('### The number of parameters and values doesn''t match for model %s', mdl.name);
    end
    
    % Get remaining parameters and values for the output model
    oparams = {};
    ovals   = {};
    for kk=1:numel(mdl.params)
      if ~utils.helper.ismember(mdl.params{kk}, iparams)
        oparams = [oparams mdl.params(kk)];
        if ~isempty(mdl.values)
          ovals   = [ovals mdl.values(kk)];
        end
      end
    end
    
    if ~isempty(iparams) && ~isnumeric(mdl.expr)
      mdl.expr = subs(mdl.expr, iparams, ivals);
      mdl.values = ovals;
      mdl.params = oparams;
      % add history
      mdl.addHistory(getInfo('None'), pl, mdl_invars(j), mdls(j).hist);
    end
    
  end
  
  % Set outputs
  varargout{1} = bs;
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
  
  pl = plist();
  
  % Params
  p = param({'Params', 'The parameters to substitute for.<br>Specify ''all'' to substitute all.'}, {1, {'all'}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Values
  p = param({'values', 'A cell-array of values to set that overide the defaults.'}, {1, {{}}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Exceptions
  p = param({'exceptions', 'A cell-array of parameters which will not be substitute.'}, paramValue.EMPTY_CELL);
  pl.append(p);
  
end

%
% PARAMETERS:  'Params' - A cell array of the parameter names to
%                         substitute. If you specify 'all' for this
%                         parameter, then the current values of mdl.params
%                         will be substituted.
%              'Values' - The values to substitute.
%
