% REMOVE remove a parameter from the parameter list.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: REMOVE remove a parameter from the parameter list.
%
% CALL:        pl = remove(pl, 2)      - removes 2nd in the list
%              pl = remove(pl, 'key')  - removes parameter called 'key'
%              pl = remove(pl, 'key1', 'key2')
%              pl = remove(pl, {'key1', 'key2'})
%              pl = remove(pl, [1 2])
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'remove')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = remove(varargin)
  
  %%% Check if this is a call for parameters
  if nargin == 3 && utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  [objs, ~, rest] = utils.helper.collect_objects(varargin(:), 'plist');
  
  % Decide on a deep copy or a modify
  objs = copy(objs, nargout);
  
  keys = rest;
  
  for ii = 1:numel(objs)
    pl = objs(ii);
    
    for jj = 1:numel(keys)
      
      if ischar(keys{jj})
        %%%%%   Remove specified key   %%%%%
        idx = [];
        np = length(pl.params);
        for kk = 1:np
          key = pl.params(kk).key;
          if ~any(strcmpi(key, keys{jj}))
            idx = [idx kk];
          end
        end
        pl.params = pl.params(idx);
        
      elseif iscell(keys{jj}) 
        
        keyset = keys{jj};
        for kk = 1:length(keyset)
          idx = [];
          key = keyset{kk};
          np = length(pl.params);
          for pp = 1:np
            if ~strcmpi(key, pl.params(pp).key)
              idx = [idx pp];
            end
          end
          pl.params = pl.params(idx);
        end
        
      elseif isnumeric(keys{jj})
        %%%%%   Remove specified position   %%%%%
        
        if max(keys{jj}) > numel(pl.params)
          error('### Index exceeds number of parameters in %dth plist', ii);
        end
        pl.params(keys{jj}) = [];
        
      elseif islogical(keys{jj})
        %%%%%   Remove specified logical position   %%%%%
        
        if numel(keys{jj}) ~= numel(pl.params)
          error('### The logical index doesn''t have the same size as the number of parameters.');
        end
        pl.params(keys{jj}) = [];
        
      else
        %%%%%   Unknown method   %%%%%
        error('### unknown indexing method')
      end
      
    end % Loop over the 'keys'
    
    if isempty(pl.params)
      pl.params = [];
    end
    
    % reset cached keys
    pl.resetCachedKeys();
    
    objs(ii) = pl;
  end % Loop over the objects.
  
  varargout{1} = objs;
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
  p = param({'key', 'The key of the parameter to remove.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
end

