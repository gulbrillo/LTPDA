% FIND overloads find routine for a parameter list.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FIND overloads find routine for a parameter list.
%              Returns the value corresponding to the first parameter in
%              the list with the search-key.
%              An optional argument can be passed so it is assigned to the
%              return in case the search-key was not found.
%
% CALL:        a = find(pl, 'key')
%              a = find(pl, pl)
%              a = find(pl, 'key', opt_val)
%              a = find(pl, pl, opt_val)
%
% EXAMPLES:
%
% 1)  a = pl.find('foo') % get the parameter with key 'foo'
% 2)  a = pl.find(plist('key', 'WIN')) % get the parameter with key 'WIN'
% 3)  a = pl.find('foo', 1) % get the parameter with key 'foo', and get 1
%                           if the key was not present in the input plist
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'find')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = find(varargin)
  
  %%% Check if this is a call for parameters
  if nargin == 3 && utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Get number of inputs
  nIn = nargin;
  
  if nIn > 3 && nIn < 2
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
  
  varargout{1} = find_core(pl, key, varargin{3:end});
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
  p = param({'key', 'A key to search for.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
end

