% SAVEALLOBJECTS index into the inner objects of one collection object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SAVEALLOBJECTS index into the inner objects of one
%              collection object.
%              This doesn't captures the history.
%
% CALL:        saveAllObjects(c, dirName)
%              c.saveAllObjects(dirName)
%
% <a href="matlab:utils.helper.displayMethodInfo('collection', 'saveAllObjects')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = saveAllObjects(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

    if nargin ~= 2
    error('invalid call to %s/%s. Please consult help',mfilename('class'), mfilename);
  end
  
  c = varargin{1};
  if ~isa(c,'collection')
    error('The first argument to %s/%s must be a collection',mfilename('class'), mfilename);
  end
  
  switch class(varargin{2})
    case 'plist'
      pl = applyDefaults(getDefaultPlist, varargin{2});
    case 'char'
      pl = getDefaultPlist;
      pl.pset('directory',varargin{2});
    otherwise
      error('The second argument to %s/%s should be a plist or a string',mfilename('class'), mfilename);
  end
  
  % get the directory and make if necessary
  dirName = pl.find('directory');
  if ~exist(dirName,'dir')
    mkdir(dirName); 
    utils.helper.msg(msg.PROC3, 'directory %s, creating', dirName);
  end
  
  names = c.names;
  
  for ii = 1:c.nobjs, save(c.getObjectAtIndex(ii),fullfile(dirName,[names{ii},'.mat'])); end
    
  
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
    pl   = getDefaultPlist();
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
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function plo = buildplist()
  
  plo = plist();
  
  p = param({'directory', 'The directory to export all of the objects.'}, '');
  plo.append(p);
  
  savepl = ao.getInfo('save').plists;
  plo = combine(savepl,plo);
  
end

