% SETZ sets the 'z' property of the ao.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETZ sets the 'z' property of the ao.
%
% CALL:        objs.setZ(val);
%              objs.setZ(val1, val2);
%              objs.setZ(plist('z', val));
%              objs = objs.setZ(val);
%
% INPUTS:      objs: Can be a vector, matrix, list, or a mix of them.
%              val:
%                 0. An AO
%                      If the value inside the PLIST is an AO then uses
%                      this function the z-values of this AO for 'z'.
%                 1. Single vector e.g. [1 2 3]
%                      Each AO in objs get this value.
%                 2. Single vector in a cell-array e.g. {[1 2 3]}
%                      Each AO in objs get this value.
%                 3. cell-array with the same number of vectors as in objs
%                    e.g. {[6 5 4], 5, [1 2 3]} and 3 AOs in objs
%                      Each AO in objs get its corresponding value from the
%                      cell-array
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'setZ')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setZ(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    in_names = {};
  else
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  end
  
  config.propName       = 'z';
  config.propDefVal     = [];
  config.inVarNames     = in_names;
  config.callerIsMethod = callerIsMethod;
  config.setterFcn      = @setterFcn;
  config.getInfoFcn     = @getInfo;
  
  % Call generic setter method
  [varargout{1:nargout}] = setPropertyValue(varargin{:}, config);
  
end

% Setter function to set z
function value = setterFcn(obj, plHist, value)
  % If the value is a cell then hasn't the user specified a value for 'z'
  if iscell(value)
    error('No new values were specified for [%s].', obj.name);
  end
  % be careful that the returned value remains an AO!
  if isa(value, 'ao')
    obj.data.setZ(value.z);
    obj.data.setDz(value.dz);
  else
    % Set new z-values
    obj.data.setZ(value);
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
  pl = plist({'z', 'A vector to set to the z field.'}, paramValue.EMPTY_DOUBLE);
end

