% SETNAVS sets the 'navs' property of the ao/fsdata.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETNAVS sets the 'nave' property of the ao/fsdata.
%
% CALL:        objs.setNavs(val);
%              objs.setNavs(val1, val2);
%              objs.setNavs(plist('navs', val));
%              objs = objs.setNavs(val);
%
% INPUTS:      objs: Can be a vector, matrix, list, or a mix of them.
%              val:
%                 0. An AO
%                      If the value inside the PLIST is an AO then uses
%                      this function the navs-value of this AO for 'navs'.
%                 1. Single value e.g. [2]
%                      Each AO in objs get this value.
%                 2. Single value in a cell-array e.g. {12.1}
%                      Each AO in objs get this value.
%                 3. cell-array with the same number of values as in objs
%                    e.g. {7, 5, 12.2} and 3 AOs in objs
%                      Each AO in objs get its corresponding value from the
%                      cell-array
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'setNavs')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = setNavs(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    in_names = {};
  else
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  end
  
  config.propName       = 'navs';
  config.propDefVal     = [];
  config.inVarNames     = in_names;
  config.callerIsMethod = callerIsMethod;
  config.setterFcn      = @setterFcn;
  config.getInfoFcn     = @getInfo;
  
  % Call generic setter method
  [varargout{1:nargout}] = setPropertyValue(varargin{:}, config);
  
end

% Setter function to set 'navs'
function value = setterFcn(obj, plHist, value)
  % If the value is a cell then hasn't the user specified a value for 'navs'
  if iscell(value)
    error('No new values were specified for [%s].', obj.name);
  end
  % be careful that the returned value remains an AO!
  if isa(value, 'ao')
    obj.data.setNavs(value.data.navs);
  else
    obj.data.setNavs(value);
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
  pl = plist({'navs', 'The number of averages to set.'}, paramValue.DOUBLE_VALUE(NaN));
end
