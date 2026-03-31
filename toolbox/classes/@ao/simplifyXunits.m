% SIMPLIFYXUNITS simplify the 'xunits' of the ao.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SIMPLIFYXUNITS simplify the 'xunits' of the ao.
%
% CALL:        ao = simplifyXunits(ao)
%              obj = obj.simplifyXunits(pl);
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'simplifyXunits')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = simplifyXunits(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;

  if callerIsMethod
    as     = varargin{1};
    if nargin == 2
      pls  = varargin{2};
    else
      pls  = plist();
    end
    
  else
    %%% Check if this is a call for parameters
    if utils.helper.isinfocall(varargin{:})
      varargout{1} = getInfo(varargin{3});
      return
    end
    
    import utils.const.*
    utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
    
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Collect all AOs
    [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
        
    % Apply defaults to plist
    pls = applyDefaults(getDefaultPlist, varargin{:});
  
  end
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);

  % check if simplifying the prefixes or not: 'yes'/'no' or true/false or 'true'/'false'     
  prefixes = utils.prog.yes2true(find_core(pls, 'prefixes'));
  
  % gathering exception list
  exceptions = find_core(pls, 'exceptions');
  if isempty(exceptions)
    exceptions = cell(0);
  elseif ~iscell(exceptions)
    exceptions = cellstr(exceptions);
  end
  
  % Loop over AOs
  for jj = 1:numel(bs)
    
    % simplify the units
    bs(jj).data.xaxis.simplifyUnits(prefixes, exceptions);

    if ~callerIsMethod
      bs(jj).addHistory(getInfo('None'), pls, ao_invars(jj), bs(jj).hist);
    end
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist();
  
  % Prefixes
  p = param({'prefixes', 'also simplify the prefixes and scale the data'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % Exceptions
  p = param({'exceptions', 'A string or cell of strings of units which are not simplyfied.'}, ...
    'kg');
  pl.append(p);
  
end
