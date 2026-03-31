% GETINDEXFORKEY returns the index of a parameter with the given key.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETINDEXFORKEY returns the index of a parameter with the
%              given key or -1 if the key is not found.
%
% CALL:        idx = getIndexForKey(pl, 'key')
%              idx = getIndexForKey(pl, pl)
%
% EXAMPLES:
%
% 1)  idx = pl.getIndexForKey('foo') % get the parameter with key 'foo'
% 2)  idx = pl.getIndexForKey(plist('key', 'WIN')) % get the parameter with key 'WIN'
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'getIndexForKey')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getIndexForKey(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  if nargin ~= 2
    error('### Incorrect inputs')
  end
  
  pl  = varargin{1};
  if isa(varargin{2}, 'plist')
    key = varargin{2}.find('key');
  else
    key = varargin{2};
  end
  
  %%%%%%%%%%   Some plausibility checks   %%%%%%%%%%
  if numel(pl) ~= 1
    error('### This function could only work with one plist-object');
  end
  
  if ~ischar(key)
    error('### The ''key'' must be a string but it is from the class %s.', class(key));
  end
  
  if ~isempty(pl.params)
    dkeys = {pl.params(:).key};
  else
    dkeys = {''};
  end
  
  % Get index of the key we want
  varargout{1} = find(pl.matchKey_core(key));
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
  ii.setModifier(false);
  ii.setArgsmin(1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pl = getDefaultPlist()
  
  pl = plist();
  
  % Key
  p = param({'key', 'The key of the parameter to get the index of.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
end

