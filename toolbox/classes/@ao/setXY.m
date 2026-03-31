% SETXY sets the 'x' and 'y' properties of the ao.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETXY sets the 'x' and 'y' properties of the ao.
%
% CALL:        ao = setXY(ao, x, y)
%              obj = obj.setXY(plist('x', [1 2 3], 'y', [1 2 3]);
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'setXY')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setXY(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    as = varargin{1};
    x  = varargin{2};
    y  = varargin{3};
    
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
    [as, ao_invars,rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
    [pls,  invars, rest] = utils.helper.collect_objects(rest(:), 'plist');
    
    %%% Look for numeric values in rest
    x = [];
    y = [];
    if numel(rest) == 2 && isnumeric(rest{1}) && isnumeric(rest{2}) && numel(rest{1}) == numel(rest{2})
      x = rest{1};
      y = rest{2};
    end
    
    %%% If pls contains parameters X and Y, get the values from there
    if isempty(x) && ~isempty(pls)
      x = pls.find_core('x');
    end
    if isempty(y) && ~isempty(pls)
      y = pls.find_core('y');
    end
    
    %%% Combine plists
    pl = plist('x', x, 'y', y);
    
  end % callerIsMethod
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Loop over AOs
  for jj = 1:numel(bs)
    bs(jj).data.setXY(x, y);
    if ~callerIsMethod
      bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
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
  
  % X
  p = param({'x', 'A vector to set to the x field.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Y
  p = param({'y', 'A vector to set to the y field.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end

