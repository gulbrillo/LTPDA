% SETTIMESPAN sets the 'timespan' property of a ltpda_uoh object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETTIMESPAN sets the 'timespan' property of a ltpda_uoh object.
%
% CALL:        objs.setTimespan(ts);
%              objs.setTimespan(plist('timespan', val));
%              objs = objs.setTimespan(val);
%
% INPUTS:      objs: Any shape of ltpda_uoh objects
%              val:
%                 1. Single PLIST e.g.
%                      Each object in objs get this value.
%                 2. Single PLIST in a cell-array
%                      Each objects in objs get this value.
%                 3. cell-array with the same number of PLISTSs as in objs
%                    e.g. {pl1, pl2, pl3} and 3 objects in objs
%                      Each object in objs get its corresponding value from the
%                      cell-array
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uoh', 'setTimespan')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setTimespan(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    in_names = {};
  else
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  end
  
  config.propName       = 'timespan';
  config.propDefVal     = [];
  config.inVarNames     = in_names;
  config.callerIsMethod = callerIsMethod;
  config.setterFcn      = @setterFcn;
  config.getInfoFcn     = @getInfo;
  
  % Call generic setter method
  [varargout{1:nargout}] = setPropertyValue(varargin{:}, config);
  
end

% Setter function to set the procinfo
function value = setterFcn(obj, plHist, value)
  
  
  if ~isempty(value) && (ischar(value) || isnumeric(value))
    value = time(value);
  end
  if isa(value, 'time')
    value = timespan(value, value);
  end
  
  obj.timespan = value;
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
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist({'timespan', 'A timespan object.'}, {1, {plist}, paramValue.OPTIONAL});
end
