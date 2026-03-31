% SETDESCRIPTION sets the 'description' property of a ltpda_uo object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETDESCRIPTION sets the 'description' property of a ltpda_uo object.
%
% CALL:        objs.setDescription(val);
%              objs.setDescription(val1, val2);
%              objs.setDescription(plist('description', val));
%              objs = objs.setDescription(val);
%
% INPUTS:      objs: Any shape of ltpda_uo objects
%              val:
%                 1. Single string e.g. 'val'
%                      Each object in objs get this value.
%                 2. Single string in a cell-array e.g. {'val'}
%                      Each objects in objs get this value.
%                 3. cell-array with the same number of strings as in objs
%                    e.g. {'val1', 'val2', 'val3'} and 3 objects in objs
%                      Each object in objs get its corresponding value from the
%                      cell-array
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uo', 'setDescription')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setDescription(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    in_names = {};
  else
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  end
  
  config.propName       = 'description';
  config.propDefVal     = '';
  config.inVarNames     = in_names;
  config.callerIsMethod = callerIsMethod;
  config.setterFcn      = @setterFcn;
  config.getInfoFcn     = @getInfo;
  
  % Call generic setter method
  [varargout{1:nargout}] = setPropertyValue(varargin{:}, config);
  
end

% Setter function to set the description
function value = setterFcn(obj, plHist, value)
  obj.description = value;
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
  pl = plist({'description', 'The description to set.'}, paramValue.EMPTY_STRING);
end
