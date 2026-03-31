% Y Get the data property 'y'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the data property 'y'.
%
% CALL:        val = y(a1,a2,a3,...)
%              val = y(as)
%              val = as.y()
%
% INPUTS:      aN   - input analysis objects
%              as   - input analysis objects array
%
% OUTPUTS:     val  - matrix with 'y', one column for each input object
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'y')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = y(varargin)

  % Check if this is a call for parameters
  if nargin == 3 && utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;

  if ~callerIsMethod
    % Collect all AOs
    [as, dummy, rest] = utils.helper.collect_objects(varargin(:), 'ao');

    % Collect numeric and char arguments to pass to getY
    args = {};
    for kk = 1:numel(rest)
      if isnumeric(rest{kk}) || ischar(rest{kk}) || islogical(rest{kk})
        args = [args {rest{kk}}];
      end
    end
  else
    % Assume the input is a single AO or a vector of AOs
    as = varargin{1};
    
    % Collect numeric and char arguments to pass to getY
    args = {};
    for kk = 2:nargin
      if isnumeric(varargin{kk}) || ischar(varargin{kk}) || islogical(varargin{kk})
        args = [args {varargin{kk}}];
      end
    end
  end

  % Create an array of the type of the first
  if isnumeric(as(1).data.getY)
    out = typecast([], class(as(1).data.getY));
  elseif islogical(as(1).data.getY)
    out = logical([]);
  else
    error('### Unsupported class [%s] for creating an empty array', class(as(1).data.getY))
  end
  
  % Get property
  for jj = 1:numel(as)
    out = [out as(jj).data.getY(args{:})];
  end

  % Set output
  varargout{1} = out;
  
end

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
  ii.setModifier(false);
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
  pl = plist.EMPTY_PLIST;
end
