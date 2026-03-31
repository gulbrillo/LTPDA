% FILTFILT overrides the filtfilt function for analysis objects in a collection object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FILTFILT overrides the filtfilt function for analysis objects in a collection object.
%
% CALL:        out = filtfilt(in, f, pl);
%
% Note: this is just a wrapper of ao/filtfilt. Each couple of AOs in the collection is passed
% to ao/filtfilt with the input plist. 
% 
% INPUTS:      in      -  input collection objects
%              f       -  ltpda_filter object (miir, mfir, ...)
%              pl      -  parameter list
%
% OUTPUTS:     out     -  output collection objects 
%
% <a href="matlab:utils.helper.displayMethodInfo('collection', 'filtfilt')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = filtfilt(varargin)
  
  % Define the method
  methodName = mfilename;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  if nargout == 0
    error('### collection %s method can not be used as a modifier.', methodName);
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  for ii = 1:nargin
    in_names{ii} = inputname(ii);
  end
  
  % Collect all collection objects, filter objects and plists
  [cs, obj_invars, rest] = utils.helper.collect_objects(varargin(:), 'collection', in_names);
  [pl, pl_invars, rest]  = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  [fobj, f_invars]       = utils.helper.collect_objects(varargin(:), 'ltpda_filter', in_names);
  
  if isempty(pl)
    pl = plist();
  end
  if isempty(pl.find_core('filter')) && ~isempty(fobj)
    pl.pset('filter', fobj);
  end
  
  % call the filtfilt method on the AOs
  varargout{1} = wrapper(cs, pl, getInfo('None'), obj_invars, methodName);
  
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
    ii = ao.getInfo(mfilename);
    sets = ii.sets;
    pls = [];
    for kk=1:numel(sets)
      pls = [pls getDefaultPlist(sets{kk})];
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
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
  
  ii = ao.getInfo(mfilename, set);
  pl = ii.plists(1);

end
  
  