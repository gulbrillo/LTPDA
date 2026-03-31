% SUBSET returns a subset of a parameter list.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SUBSET returns a subset of a parameter list.
%
% CALL:        p = subset(pl, 'key')
%              p = subset(pl, search_pl)
%              p = subset(pl, 'key1', 'key2')
%              p = subset(pl, {'key1', 'key2'})
%
% REMARK:      It is possible to use a star (*) as a wild-card.
%
% A warning is given for any key not in the original plist.
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'subset')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = subset(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Check inputs
  if nargin < 2
    error('### Incorrect inputs')
  end
  
  if nargout ~= 1
    error('### Incorrect outputs. plist/subset or plist/search cannot be used as a modifier.');
  end
  
  % The first input is the plist to extract the subset of
  pl  = varargin{1};
  
  % Collect the keys to search for
  keys = {};
  for kk=2:nargin
    if iscell(varargin{kk})
      keys = [keys varargin{kk}];
    elseif isa(varargin{kk}, 'plist')
      pli = varargin{kk};
      ikeys = pli.find_core('keys');
      if ~isempty(ikeys)
        keys = [keys ikeys];
      end
    else
      keys = [keys varargin(kk)];
    end
  end
  
  % Convert input keys to upper case
  keys = upper(keys);
  
  % Check we got some keys
  if isempty(keys)
    error('### Please specify at least one key');
  end
  
  % We only handle one input plist
  if numel(pl) ~= 1
    error('### This function can only work with one plist-object');
  end
  
  % Get parameters we want
  pl_out = plist();
  
  for kk = 1:numel(keys)
    key = keys{kk};
    
    % Replace wild-card '*' with regular expression wild-card '.*'
    key = strrep(key, '*', '.*');
    
    matches =  matchKeyWithRegexp(pl, key);

    if sum(matches) < 1
      warning('PLIST:subset', 'The key ''%s'' was not found in the original plist', keys{kk});
    else
      pl_out.append(copy(pl.params(matches), 1));
    end
  end
  
  % Set output
  if nargout == 1
    varargout{1} = pl_out;
  else
    error('### Incorrect number of outputs');
  end
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
  
  % Keys
  p = param({'keys', 'The keys to search for.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
end

