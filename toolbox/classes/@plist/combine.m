% COMBINE multiple parameter lists (plist objects) into a single plist.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COMBINE multiple parameter lists (plist objects) into a single
%              plist. Duplicate parameters are given priority in the order
%              in which they appear in the input.
%
% CALL:        pl = combine(p1, p2, p3);
%              pl = combine(p1, [p2 p3], p4)
%
% EXAMPLES:    >> pl1 = plist('A', 1);
%              >> pl2 = plist('A', 3);
%              >> plo = combine(pl1, pl2)
%
%              Then plo will contain a parameter 'A' with value 1.
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'combine')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = combine(varargin)
  
  %%% Check if this is a call for parameters
  if nargin == 3 && utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Try to just form an array of the inputs. If that fails, fall back to
  % collect_objects.
  try
    objs = [varargin{:}];
  catch
    objs = utils.helper.collect_objects(varargin(:), 'plist');
  end
  
  %%% decide whether we modify the first plist, or create a new one.
  pl      = copy(objs(1), nargout);
  
  %%% If we found more than one plist then append the parameters
  %%% of the second, third, ... plist to the first plist
  if numel (objs) > 1
    for ii = 2:numel(objs)
      % Loop over all params in the current plist
      for jj = 1:length(objs(ii).params)
        pl = add_param(pl, objs(ii).params(jj));
      end
    end
  end
    
  varargout{1} = pl;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: The input parameter will only be added if the key doesn't exist
%              in the plist.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pl = add_param(pl, p)
  
  if ~isempty(pl.params) && any(matchKeys_core(pl, cellstr(p.key)))
    return
  end
  
  pl.params = [pl.params copy(p,1)];
  pl.cacheKey(p.key);
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
  ii.setArgsmin(2);
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

