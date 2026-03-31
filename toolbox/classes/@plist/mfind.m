% MFIND multiple-arguments find routine for a parameter list.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MFIND multiple-arguments find routine for a parameter list.
%              Returns the value corresponding to the first parameter in
%              the list with the search-key list. The search-key list are
%              searched by the order they are entered.
%              If the user specifies two outputs, the second will contain the
%              matching key
%
% CALL:        a = mfind(pl, 'key1', 'key2', 'key3')
%              [a, key] = mfind(pl, 'key1', 'key2', 'key3')
%              a = mfind(pl, {'key1', 'key2', 'key3'})
%              [a, key] = mfind(pl, {'key1', 'key2', 'key3'})
%              a = mfind(pl, plist({'key1', 'key2', 'key3'}))
%              [a, key] = mfind(pl, plist({'key1', 'key2', 'key3'}))
% 
% EXAMPLES:
% 
% 1)  % get the parameter with key 'foo1', or if not found, get the parameter with key 'foo2'
%     pl = plist('foo2', 5);
%     a = pl.mfind('foo1','foo2') 
%                                 
% 2)  % get the parameter with key 'WIN', or if not found, get the parameter with key 'WIN2'
%     pl = plist('WIN', 'BH92', 'WIN2', 'Hamming');
%     [a, key] = pl.mfind(plist('key', 'WIN'), 'WIN2') 
% 
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'mfind')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mfind(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  pl  = varargin{1};
  rest = varargin(2:end);
  for jj = 1:numel(rest)    
    if isa(rest{jj}, 'plist')
      key = rest{jj}.mfind('key');
    else
      key = rest{jj};
    end
        
    if ~isa(key, 'cell')
      key = {key};
    end
    
    for kk = 1:numel(key)
      %%%%%%%%%%   Some plausibility checks   %%%%%%%%%%
      if numel(pl) ~= 1
        error('### This function could only work with one plist-object');
      end
      
      if ~ischar(key{kk})
        error('### The ''key'' must be a string but it is from the class %s.', class(key{kk}));
      end
      
      if ~isempty(pl.params)        
        dkeys = {pl.params(:).key};
      else
        dkeys = {''};
      end
      
      % Get value we want
      matches = matchKey_core(pl, key{kk});
      if any(matches)
        val = pl.params(matches).getVal;
        match_key = key{kk};
        break;
      else
        val = [];
        match_key = [];
      end
    end
    if ~isempty(val)
      break;
    end
  end
  if isa(val, 'ltpda_obj')
    varargout{1} = copy(val, 1);
  else
    varargout{1} = val;
  end
  
  if nargout == 2
    varargout{2} = match_key;
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
  
  % Key
  p = param({'key', 'A key to search for.'}, paramValue.EMPTY_STRING);
  pl.append(p);  
  
end

