% SETT0 sets the 't0' property of the ao.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETT0 sets the 't0' property of the ao.
%
% CALL:        objs.setT0(val);
%              objs.setT0(val1, val2);
%              objs.setT0(plist('t0', val));
%              objs = objs.setT0(val);
%
% INPUTS:      objs: Can be a vector, matrix, list, or a mix of them.
%              val:  A time-string or number
%                 1. Single value e.g. '14:00:00'
%                      Each AO in objs get this value.
%                 2. Single value in a cell-array e.g. {4}
%                      Each AO in objs get this value.
%                 3. cell-array with the same number of values as in objs
%                    e.g. {'14:00:00, 5, '15:00:00'} and 3 AOs in objs
%                      Each AO in objs get its corresponding value from the
%                      cell-array
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'setT0')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = setT0(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    in_names = {};
  else
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  end
  
  config.propName       = 't0';
  config.propDefVal     = [];
  config.inVarNames     = in_names;
  config.callerIsMethod = callerIsMethod;
  config.setterFcn      = @setterFcn;
  config.getInfoFcn     = @getInfo;
  
  % Call generic setter method
  [varargout{1:nargout}] = setPropertyValue(varargin{:}, config);
  
end

% Setter function to set the t0
function value = setterFcn(obj, plHist, value)
  obj.data.setT0(value);
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
  pl = plist({'t0', ['The time to set.<br>' ...
    'You can enter the t0 as a string or as a number. If you want to enter a number please enter this number and convert the type with a right click on the number to a double.']}, ...
    {1, {'14:00:00 10-10-2009'}, paramValue.OPTIONAL});
end
