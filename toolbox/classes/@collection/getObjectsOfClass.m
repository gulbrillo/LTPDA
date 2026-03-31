% GETOBJECTSOFCLASS returns all objects of the specified class in a collection-object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETOBJECTSOFCLASS returns all objects of the specified class
%              in a collection-object.
%              This doesn't captures the history.
%
% CALL:        b = getObjectsOfClass(coll, i)
%              b = getObjectsOfClass(coll, i, j)
%              b = coll.getObjectsOfClass(plist('class', 'ao'))
%
% <a href="matlab:utils.helper.displayMethodInfo('collection', 'getObjectsOfClass')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getObjectsOfClass(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  if nargout == 0
    error('### getObjectsOfClass cannot be used as a modifier. Please give an output variable.');
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all 'ltpda_uoh' objects and plists
  [colls, obj_invars, rest] = utils.helper.collect_objects(varargin(:), 'collection', in_names);
  [pl, pl_invars, rest] = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  cl = pl.find_core('class');
  
  if isempty(cl) && ~isempty(rest)
    cl = rest{1};
    pl.pset('class', cl);
  end
  
  if isempty(cl) || ~ischar(cl)
    error('### Please specify the class as a string in a plist or direct.');
  end
  
  objs = [];
  
  for oo = 1:numel(colls)
    for ii = 1:numel(colls(oo).objs)
      if isa(colls(oo).objs{ii}, cl)
        objs = [objs colls(oo).objs{ii}];
      end
    end
  end
  
  % Set output
  varargout{1} = objs;
end

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
  ii.setModifier(false);
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
  
  p = param({'class', 'Class name which should be collected.'}, paramValue.EMPTY_STRING);
  plo.append(p);
end

