% REMOVEOBJECTATINDEX removes the object at the specified position from the collection.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: REMOVEOBJECTATINDEX removes the object at the specified
%              position from the collection.
%
% CALL:        coll = removeObjectAtIndex(coll, 1, 2)
%              coll = coll.removeObjectAtIndex(plist('index', [1 2]));
%
% <a href="matlab:utils.helper.displayMethodInfo('collection', 'removeObjectAtIndex')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = removeObjectAtIndex(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  %%% Internal call: Only one object + don't look for a plist
  if utils.helper.callerIsMethod()
    %%% decide whether we modify the first object, or create a new one.
    varargin{1} = copy(varargin{1}, nargout);
    for ii = 1:numel(varargin{1})
      varargin{1}(ii).objs(varargin{2}) = [];
    end
    varargout{1} = varargin{1};
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect objects
  [colls, colls_invars, rest] = utils.helper.collect_objects(varargin(:), 'collection', in_names);
  [pls,  dummy, rest]         = utils.helper.collect_objects(rest(:), 'plist');
  [idxs, dummy, rest]         = utils.helper.collect_objects(rest(:), 'double');
  
  %%% If pls contains only one plist with the single key 'object' and
  %%% 'index' then set the property with a plist.
  if length(pls) == 1 && isa(pls, 'plist') && nparams(pls) == 1 && pls.isparam_core('index')
    idxs = pls.find_core('index');
  end
  
  if isempty(idxs)
    error('### Please specify an index in a plist or direct.');
  end
  
  %%% Create plist for history
  plh = combine(pls, plist('index', idxs));
  
  % Decide on a deep copy or a modify
  colls = copy(colls, nargout);
  
  % Loop over objects
  for oo=1:numel(colls)
    colls(oo).objs(idxs) = [];
    colls(oo).names(idxs) = [];
    colls(oo).addHistory(getInfo('None'), plh, colls_invars(oo), colls(oo).hist);
  end
  
  % Set output
  if nargout == numel(colls)
    % List of outputs
    for ii = 1:numel(colls)
      varargout{ii} = colls(ii);
    end
  else
    % Single output
    varargout{1} = colls;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
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

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function plo = buildplist()
  plo = plist();
  
  p = param({'index', 'Position of the object in the collection.'}, paramValue.EMPTY_DOUBLE);
  plo.append(p);
  
end

