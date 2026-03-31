% APPEND append a param-object, plist-object or a key/value pair to the parameter list.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: APPEND append a param-object, plist-object or a key/value pair to
%              the parameter list.
%
% CALL:        pl = append(pl, param-object);
%              pl = append(pl, plist-object);
%              pl = append(pl, 'key1', 'value1');
%
%              pl = append(pl, combination of the examples above)
%
% REMARK:      It is not possible to append an key/value pair if the key exist
%              in the parameter list. Tn this case an error is thrown.
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'append')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = append(varargin)
  
  import utils.const.*
  
  %%%%  short cuts for simple calls
  nIn  = nargin;
  nOut = nargout;
  
  % pl.append(p)
  if nOut == 0 && nIn == 2 && isa(varargin{2}, 'param') && numel(varargin{2})==1
    pl = varargin{1};
    p  = varargin{2};
    if ~isempty(pl.params) && any(pl.matchKeys_core(p.key))
      error('\n### The key [%s] exist in the parameter list.\n### Please use the function pset.', p.defaultKey);
    end
    pl.params = [pl.params p];
    pl.cacheKey(p.key);
    return
  end
  
  % pl.append('key', value)
  if nOut == 0 && nIn == 3 && ischar(varargin{2})
    pl = varargin{1};
    key = varargin{2};
    if ~isempty(pl.params) && any(pl.matchKeys_core(key))
      error('\n### The key [%s] exist in the parameter list.\n### Please use the function pset.', key);
    end
    pl.params = [pl.params param(key, varargin{3})];
    pl.cacheKey(key);
    return
  end
  
  %%% Check if this is a call for parameters
  if nIn == 3 && utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  
  [objs, invars, rest] = utils.helper.collect_objects(varargin(:), 'plist');
  [pps,  invars, rest] = utils.helper.collect_objects(rest(:), 'param');
  
  %%% Decide on a deep copy or a modify
  pls = copy(objs, nOut);
  
  %%% REMARK: If the rest is an single string and the number of plist is two
  %%%         then we assume that the rest and the second plist are a key/value
  %%%         pair.
  if numel(rest) == 1 && ischar(rest{1}) && numel(objs) == 2
    rest{2} = objs(2);
    pls(2) = [];
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%             First Case: Append plist-objects              %%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  pl = pls(1);
  
  %%% If we found more than one plist then append the parameters
  %%% of the second, third, ... plist to the first plist
  if numel (pls) > 1
    for kk = 2:numel(pls)
      for jj = 1:length(pls(kk).params)
        add_param(pl, pls(kk).params(jj));
      end
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%             Second Case: Append param-objects             %%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if ~isempty(pps)
    for kk = 1:numel(pps)
      add_param(pl, pps(kk));
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%             Third Case: Append key/value pairs            %%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if ~isempty(rest)
    if mod(numel(rest),2)
      error('### Please define a ''key'' AND a ''value''%s### to append this pair.', char(10));
    end
    
    %%% Loop over the input arguments
    while ~isempty(rest)
      if iscell(rest{1})
        key = rest{1}{1};
        desc = rest{1}{2};
      else
        desc = '';
        key = rest{1};
      end
      val = rest{2};
      
      %%% Remove the first two objects from the 'rest' variable
      rest(1) = [];
      rest(1) = [];
      
      %%% Create new param object ann call add_param()
      if isempty(desc)
        p = param(key,val);
      else
        if ~ischar(desc)
          error('### The description for a parameter must be a string but it is from the class [%s]', class(desc));
        else
          p = param({key, desc},val);
        end
      end
      add_param(pl, p);
      
    end
  end
  
  varargout{1} = pl;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: The input parameter will only be added if the key doesn't exist
%              in the plist. Throw an error if the key exist in the plist.
function add_param(pl, pp)
  
  if ~isempty(pl.params) && any(pl.matchKeys_core(pp.key))
    error('\n### The key [%s] exist in the parameter list.\n### Please use the function pset.', utils.prog.cell2str(pp.key));
  end
  pl.params = [pl.params pp];
  % cache new key
  pl.cacheKey(pp.key);
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
  ii.setArgsmin(1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plo = getDefaultPlist()
  plo = plist();
end

