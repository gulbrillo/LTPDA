% ADDALTERNATIVEKEYS adds some alternative key names to an existing key.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ADDALTERNATIVEKEYS adds some alternative key names to an
%              existing key.
%
% CALL:        pl = addAlternativeKeys(pl, 'key in pl', 'alt1', 'alt2')
%              pl = addAlternativeKeys(pl, plist('altkeys', {'alt1', 'alt2'}))
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'addAlternativeKeys')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = addAlternativeKeys(varargin)
  
  import utils.const.*
  
  %%% Check if this is a call for parameters
  if nargin == 3 && utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  pl = varargin{1};
  % Check the inputs
  if numel(pl) ~= 1
    error('### This function could only work with one plist-object');
  end
  if ~isa(varargin{1}, 'plist')
    error('### The first input must be a PLIST');
  end
  if isa(varargin{2}, 'plist')
    % If the second input is a PLIST then is this the configuration PLIST
    keys = find_core(varargin{2}, 'altkeys');
    % Make sure that we have a cell string
    keys = cellstr(keys);
  else
    keys = varargin(2:end);
  end
  
  % Check if the keys are a cell of strings
  if ~iscellstr(keys)
    error('### The alternative keys must be strings');
  end
  % Check The length of 'keys'
  % 'keys' must have at least the length of two. An existing key and a
  % alternative name.
  if numel(keys) < 2
    error('### Please add an existing key and the alternative names for that key');
  end
  
  % Decide on a deep copy or a modify
  pl = copy(pl, nargout);
  
  existingKey = keys{1};
  altKeys     = upper(keys(2:end));
  
  % Check if the first key in 'keys' exist in the PLIST
  if ~isempty(pl.params)
    currentKeys = {pl.params(:).key};
  else
    currentKeys = {''};
  end
  matches = checkKey(currentKeys, existingKey);
  if ~any(matches)
    error('### Cannot add the keys %s to the existing key ''%s'' because ''%s'' doesn''t exist in the plist.', utils.helper.val2str(altKeys), existingKey, existingKey);
  end
  
  % Check if one of the alternative keys already exist in the PLIST
  for ii = 1:numel(altKeys)
    if any(checkKey(currentKeys, altKeys{ii}))
      error('### the alternative key name ''%s'' already exist in the PLIST', altKeys{ii});
    end
  end
  
  % Check if we have more than one match (should not happen)
  if sum(matches) > 1
    error('### The first key match to more than one existing key but this should not happen!!!');
  end
  
  % Add the alternative key names to the existing key
  newKeys = [reshape(cellstr(currentKeys{matches}), 1, []), reshape(altKeys, 1, [])];
  pl.params(matches).setKey(newKeys);
  
  % reset cached keys
  pl.resetCachedKeys();
  
  % Define output
  varargout{1} = pl;
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    checkKey
%
% DESCRIPTION: Checks if a key already exist in the PLIST
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function matches = checkKey(currentKeys, key)
  if iscellstr(currentKeys)
    % 'old' case without alternatives
    matches = strcmpi(key, currentKeys);
  else
    % 'new' case with alternatives
    fcn = @(x) strcmpi(x, key);
    res = cellfun(fcn, currentKeys, 'UniformOutput', false);
    matches = cellfun(@any, res);
  end
end

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
  p = param({'altkeys', 'A key to search for.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
end

