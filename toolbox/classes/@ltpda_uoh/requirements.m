% REQUIREMENTS Returns a list of LTPDA extension requirements for a given object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: REQUIREMENTS Returns a list of LTPDA extension requirements for a given object.
%
% CALL:        list = requirements(objs)
% 
% For multiple objects, the list will be the unique set of extension
% modules needed to build all the input objects.
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uoh', 'requirements')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = requirements(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

  %%% Collect all objects with the class of the first object.
  objs = utils.helper.collect_objects(varargin(:), '');
  pl = utils.helper.collect_objects(varargin(:), 'plist');

  % apply defaults
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % recursively build a list of modules for all input objects
  requirements = {};
  for ii = 1:numel(objs);   
    list = getRequirements(objs(ii).hist);    
    requirements = [requirements list];    
  end
  
  % make unique and non-empty
  requirements = unique(requirements);
  requirements = requirements(~cellfun('isempty', requirements));

  % add hashes for each requirement
  if pl.find_core('hashes')
    hashes = gitHash();
    for ll=1:numel(requirements)
      if isfield(hashes, requirements{ll})
        hash = hashes.(requirements{ll});
        lh = length(hash);
      else
        if ltpda_mode == utils.const.msg.DEBUG
          warning('Failed to load hash content for %s', requirements{ll});
        end
        lh = 0;
      end
      if lh > 0
        hash = hash(1:min(lh, 7));
      else
        hash = 'unknown';
      end
      requirements{ll} = sprintf('%s: %s', requirements{ll}, hash);
    end
  end
  
  if nargout == 0
    fprintf('Requirements:\n');
    for ll=1:numel(requirements)
      fprintf('  %s\n', requirements{ll});
    end
  else
    varargout{1} = requirements;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function list = getRequirements(h)
  
  if isempty(h) || isempty(h.methodInfo)
    list = {};
  else
    list = {h.methodInfo.mpackage};
    
    for kk=1:numel(h.inhists)
      list = [list getRequirements(h.inhists(kk))];
    end
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
% HISTORY:     10-12-2008 Diepholz
%                Creation.
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
  ii.setModifier(false);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
% HISTORY:     10-12-2008 Diepholz
%                Creation.
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
  
  % include hashes
  p = param({'hashes', 'Include version hashes in the output requirement strings'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
end

