% SIMPLIFYUNITS simplify the input units and/or output units of the object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SIMPLIFYUNITS simplify the input units and/or output units
%              of the object.
%
% CALL:        t = simplifyUnits(t)
%              obj = obj.simplifyUnits(pl);
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_tf', 'simplifyUnits')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = simplifyUnits(varargin)
  
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
  [as, tf_invars,rest] = utils.helper.collect_objects(varargin(:), '', in_names);
  [pls,  invars, rest] = utils.helper.collect_objects(rest(:), 'plist');
  
  %%% Combine plists
  pls = applyDefaults(getDefaultPlist, pls);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % The ports to simplify
  port = find_core(pls, 'port');
  
  % gathering exception list
  exceptions = find_core(pls, 'exceptions');
  if isempty(exceptions)
    exceptions = cell(0);
  elseif ~iscell(exceptions)
    exceptions = cellstr(exceptions);
  end
  
  % Loop over AOs
  for j=1:numel(bs)
    
    switch port
      case 'in'
    
        bs(j).setIunits(simplify(bs(j).iunits, exceptions));
        
      case 'out'
        
        bs(j).setOunits(simplify(bs(j).ounits, exceptions));
        
      case 'both'
        
        bs(j).setIunits(simplify(bs(j).iunits, exceptions));
        bs(j).setOunits(simplify(bs(j).ounits, exceptions));
        
      otherwise
        error('ltpda:ltpda_tf:simplifyUnits', 'unrecognized port option');
    end    
    
    if ~utils.helper.callerIsMethod()
      bs(j).addHistory(getInfo('None'), pls, tf_invars(j), bs(j).hist);
    end
  end
  
  % Set output
  if nargout == numel(bs)
    % List of outputs
    for ii = 1:numel(bs)
      varargout{ii} = bs(ii);
    end
  else
    % Single output
    varargout{1} = bs;
  end
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
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist();
  
  % Exceptions
  p = param({'exceptions', 'A string or cell of strings of units which are not simplyfied.'}, ...
    paramValue.EMPTY_STRING);
  pl.append(p);
  
  % Port
  p = param({'port', 'The port to simplify the units of.'}, ...
    {3, {'in', 'out', 'both'}, paramValue.SINGLE});
  pl.append(p);
  
end

