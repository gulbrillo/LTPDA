% SETXAXISNAME sets the x-axis name of the ao.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETXAXISNAME sets the x-axis name of the ao.
%
% CALL:        objs.setXaxisName(val);
%              objs.setXaxisName(val1, val2);
%              objs.setXaxisName(plist('axis name', val));
%              objs = objs.setXaxisName(val);
%
% INPUTS:      objs: Can be a vector, matrix, list, or a mix of them.
%              val:  A Strind
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'setXaxisName')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setXaxisName(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    in_names = {};
  else
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  end
  
  config.propName       = 'axis name';
  config.propDefVal     = '';
  config.inVarNames     = in_names;
  config.callerIsMethod = callerIsMethod;
  config.setterFcn      = @setterFcn;
  config.getInfoFcn     = @getInfo;
  
  % Call generic setter method
  [varargout{1:nargout}] = setPropertyValue(varargin{:}, config);
  
end

% Setter function to set the 'x-axis name'
function value = setterFcn(obj, plHist, value)
  obj.data.setXaxisName(value);
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
  pl = plist({'axis name', 'New x-axis name.'}, paramValue.EMPTY_STRING);
end
