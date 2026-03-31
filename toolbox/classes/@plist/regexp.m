% REGEXP performs a regular expression search on the input plists.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: REGEXP performs a regular expresssion search on the combined
%              set of keys of the input plists. The method returns a plist
%              containing all matching parameters.
%
% CALL:
%           out = regexp(pl, pattern);
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'regexp')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = regexp(varargin)
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % input plists
  searchPlist  = combine(varargin{1});
  in  = varargin{2};
  if isa(in, 'plist')
    pl = applyDefaults(getDefaultPlist, in);
    pattern = pl.find_core('pattern');
  else
    % get defaults
    pattern = in;
    % get default plist
    pl = getDefaultPlist;
  end
  if ~ischar(pattern)
    error('The specified pattern to match must be a string');
  end
  
  
  indicesMatched = [];
  ignoreCase = pl.find_core('ignore case');
  
  % Get matches
  if ~isempty(searchPlist.params)
    switch pl.find_core('search')
      case 'all'
        indicesMatched = matchIndices(indicesMatched, searchPlist.getKeys, pattern, ignoreCase);
        indicesMatched = matchIndices(indicesMatched, {searchPlist.params.desc}, pattern, ignoreCase);
      case 'keys'
        indicesMatched = matchIndices(indicesMatched, searchPlist.getKeys, pattern, ignoreCase);
      case 'descriptions'
        indicesMatched = matchIndices(indicesMatched, {searchPlist.params.desc}, pattern, ignoreCase);
      otherwise
        error('Unknown value for the ''search'' key');
    end
  end
  
  % Get subset of the parameters
  params = searchPlist.params(indicesMatched);
  if ~isempty(params)
    out = plist(copy(params,1));
  else
    out = plist();
  end
  
  varargout{1} = out;
end

function indices = matchIndices(indices, terms, pattern, ignoreCase)
  if iscellstr(terms)
    if ignoreCase
      matches = regexpi(terms, pattern);
    else
      matches = regexp(terms, pattern);
    end
    indices = unique([indices find(~cellfun('isempty', matches))]);
  else
    error('### This method doesn''t work for PLISTs with alternative key names. Code me up if wanted.');
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
  
  % Pattern
  p = param({'pattern', 'A pattern to search for. For further help, see MATLAB''s regexp function.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % Search
  p = param({'search', 'Specify what to search. You can choose to search the keys, the descriptions or all.'}, {1, {'all', 'keys', 'descriptions'}, paramValue.SINGLE});
  pl.append(p);
  
  % Ignore case
  p = param({'ignore case', 'Ignore case when searching.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
end