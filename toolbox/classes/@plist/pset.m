% PSET set or add a key/value pairor a param-object into the parameter list.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PSET set or add a key/value pairor a param-object
%              into the parameter list. Exist the key in the parameter list
%              then becomes the value the new value.
%
% CALL:        pl = pset(pl, param-object);
%              pl = pset(pl, key, val);
%              pl = pset(pl, key1, val1, key2, val2);
%
% REMARK:      For the input objects exist the rule that the key must always be
%              followed by the value.
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'pset')">Parameters Description</a>
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = pset(varargin)

  %%% Check if this is a call for parameters
  if nargin == 3 && utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  objs = [];
  pps  = [];
  rest = {};
  
  argin = varargin;
  
  while numel(argin)
        
    if isa(argin{1}, 'plist')
      if isempty(objs)
        objs = argin{1};
      else
        objs = [reshape(objs, 1, []), reshape(argin{1}, 1, [])];
      end
      argin(1) = [];
    elseif isa(argin{1}, 'param')
      pps = [reshape(pps, 1, []), reshape(argin{1}, 1, [])];
      argin(1) = [];
    else
      if numel(argin) < 2
        error('### Please define a ''value'' for the ''key'' [%s].', argin{1});
      end
      rest{end+1} = argin{1};
      rest{end+1} = argin{2};
      argin(1) = [];
      argin(1) = [];
    end
  end

  %%% Decide on a deep copy or a modify
  pls = copy(objs, nargout);
  
  %%%%%%%%%%   Some plausibility checks   %%%%%%%%%%
  if (isempty(pps) && isempty(rest)) || mod(numel(rest),2)
    error('### Please define a ''key'' AND a ''value''%s### to set this pair.', char(10));
  end

  for ii = 1:numel(pls)
    
    pl = pls(ii);

    %%%%%%%%%%   First case: Set param-objects   %%%%%%%%%%
    if ~isempty(pps)
      for jj = 1:numel(pps)
        add_param(pl, pps(jj));
      end
    end

    %%%%%%%%%%   Second case: Set key/value pair   %%%%%%%%%%
    rest_help = rest;
    while ~isempty(rest_help)
      key = rest_help{1};
      val = rest_help{2};

      %%% Remove the first two objects from the 'rest_help' variable
      rest_help(1) = [];
      rest_help(1) = [];

      pset_core(pl, key, val);
      
    end
    
  end

  % Set output
  varargout{1} = pls;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: check to see if this is one of the parameters we can set,
%              otherwise add it.
function add_param(pl, pp)
  found = 0;
  for j=1:length(pl.params)
    if strcmpi(pl.params(j).key, pp.key)
      pl.params(j).setVal(pp.getVal);
      found = 1;
      break
    end
  end
  % add this parameter if necessary
  if ~found
    % To be sure that the param object is a copy
    pp = copy(pp, 1);
    pl.params = [pl.params pp];
  end
  % cache this new key
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

