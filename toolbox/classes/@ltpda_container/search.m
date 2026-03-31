% SEARCH selects objects inside the collection/matrix object that match the given name.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SEARCH selects objects inside the collection/matrix object that
%              match the given name using a regular expression (help regexp).
%
% CALL:        o = search(c, expr)
%              o = search(c, pl)
%
% INPUTS:      c    - Single collection/matrix object
%              expr - String with the name or regular expression
%              pl   - PLIST with the necessary keys
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_container', 'search')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = search(varargin)
  
  % Define the method
  methodName = mfilename;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  if nargout == 0
    error('### ltpda_container %s method can not be used as a modifier.', methodName);
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin, in_names{ii} = inputname(ii); end; end
  
  % Collect all ltpda_container objects and plists
  [ms, obj_invars, rest] = utils.helper.collect_objects(varargin(:), 'ltpda_container', in_names);
  [pl, ~, rest]          = utils.helper.collect_objects(rest(:), 'plist');
  
  
  % copy inputs
  ms = copy(ms, nargout);
  
  % Apply defaults
  pl = applyDefaults(getDefaultPlist('Default'), pl);
  
  %----- Get expression
  % first look in direct inputs
  expr = '';
  if ~isempty(rest)
    expr = rest{1};
  end
  
  % then in plist
  if isempty(expr)
    expr = find_core(pl, 'regexp');
  end
  
  if isempty(expr)
    error('### Please specify an expression to match.');
  end
  
  % Ensure a string. This allows us to support any object which implements
  % a char method.
  if isobject(expr)
    expr = char(expr);    
    exact = true; % if we have an object then this is an exact search
    % Make sure that the search expression is in the history PLIST
    pl.pset('regexp', expr);
    pl.pset('exact', exact);
  else
    exact = pl.find_core('exact');
  end
  
  for kk=1:numel(ms)
    
    objs = ms(kk).objs;
    
    if iscell(objs)
      objNames = cellfun(@(x)get(x, 'name'), objs, 'UniformOutput', false);
    else
      objNames = {objs.name};
    end
    
    
    % Run regexp
    if exact
      res = strcmp(objNames, expr);
    else
      res = regexp(objNames, expr);
      % get the indices
      res = ~cellfun(@isempty, res);
    end    
    
    ms(kk).objs = objs(res);
    
    if isprop(ms(kk), 'names')
      ms(kk).names = ms(kk).names(res);
    end
    
    ms(kk).addHistory(getInfo('None'), pl, obj_invars(kk), [ms(kk).hist]);
    
  end % End loop over input containers
  
  varargout = utils.helper.setoutputs(nargout, ms);
  
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
    pls  = [];
  else
    ii = ltpda_uo.getInfo(mfilename);
    sets = ii.sets;
    pls = [];
    for kk=1:numel(sets)
      pls = [pls getDefaultPlist(sets{kk})];
    end
  end
  
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pls);
  ii.setModifier(false);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function pl = buildplist(set)
  
  ii = ltpda_uo.getInfo(mfilename, set);
  pl = ii.plists(1);
  
end
