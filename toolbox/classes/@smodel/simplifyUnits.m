% SIMPLIFYUNITS simplify the x and/or y units of the model.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SIMPLIFYUNITS simplify the x and/or y units of the model.
%
% CALL:        m = simplifyUnits(m)
%              obj = obj.simplifyUnits(pl);
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'simplifyUnits')">Parameters Description</a>
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
  [mdls, mdl_invars,rest] = utils.helper.collect_objects(varargin(:), 'smodel', in_names);
  [pls,  invars, rest] = utils.helper.collect_objects(rest(:), 'plist');
  
  %%% Combine plists
  pls = applyDefaults(getDefaultPlist, pls);
  
  % Decide on a deep copy or a modify
  bs = copy(mdls, nargout);
  
  % The ports to simplify
  axis = find_core(pls, 'axis');
  
  % gathering exception list
  exceptions = find_core(pls, 'exceptions');
  if isempty(exceptions)
    exceptions = cell(0);
  elseif ~iscell(exceptions)
    exceptions = cellstr(exceptions);
  end
  
  % Loop over AOs
  for j=1:numel(bs)
    
    switch upper(axis)
      case 'X'
    
        bs(j).setXunits(simplify(bs(j).xunits, exceptions));
        
      case 'Y'
        
        bs(j).setYunits(simplify(bs(j).yunits, exceptions));
        
      case 'XY'
        
        bs(j).setXunits(simplify(bs(j).xunits, exceptions));
        bs(j).setYunits(simplify(bs(j).yunits, exceptions));
        
      otherwise
        error('ltpda:smodel:simplifyUnits', 'unrecognized axis option');
    end    
    
    if ~utils.helper.callerIsMethod
      bs(j).addHistory(getInfo('None'), pls, mdl_invars(j), bs(j).hist);
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
  p = param({'axis', 'The axis to simplify the units of.'}, ...
    {3, {'X', 'Y', 'XY'}, paramValue.SINGLE});
  pl.append(p);
  
end

