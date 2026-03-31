% SETOBJECTATINDEX sets an input object to the collection.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETOBJECTATINDEX sets an input object to the collection.
%
% CALL:        coll = setObjectAtIndex(coll, ao(), 1)
%              coll = coll.setObjectAtIndex(plist('object', ao(), 'index', 1));
%
% <a href="matlab:utils.helper.displayMethodInfo('collection', 'setObjectAtIndex')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setObjectAtIndex(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
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
  [idxs, dummy, objs]         = utils.helper.collect_objects(rest(:), 'double');
  
  %%% If pls contains only one plist with the single key 'object' and
  %%% 'index' then set the property with a plist.
  if length(pls) == 1 && isa(pls, 'plist') && nparams(pls) == 2 && pls.isparam_core('object') && pls.isparam_core('index')
    objs = {};
    o = pls.find_core('object');
    if ~iscell(o)
      o = num2cell(o);
    end
    for ll = 1:numel(o)
      objs = [objs o(ll)];
    end
    idxs = pls.find_core('index');
  else
    objs = [objs num2cell(reshape(pls, 1, []))];
  end
  
  if numel(idxs) ~= numel(objs)
    error('### Please specify for each input object an index. Number of objects %d and number of indices %d', numel(objs), numel(idxs))
  end
  
  % check the objects
  fcn = @(x)isa(x, 'ltpda_uo');
  if ~all(cellfun(fcn, objs))
    error('collection objects can only contain other ltpda objects');
  end
  
  %%% Create plist for history
  plh = combine(pls, plist('object', objs, 'index', idxs));
  
  % Decide on a deep copy or a modify
  colls = copy(colls, nargout);
  
  % Loop over objects
  for oo=1:numel(colls)
    for ii=1:numel(idxs)
      colls(oo).objs{idxs(ii)} = objs{ii};
    end
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
  
  p = param({'object', 'An ltpda_uoh object which is to be packed in the collection object.'}, paramValue.EMPTY_DOUBLE);
  plo.append(p);
  
  p = param({'index', 'Position of the object in the collection.'}, paramValue.EMPTY_DOUBLE);
  plo.append(p);
  
end

