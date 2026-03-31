% SETNUMERIC sets the 'numeric' property of a mfh object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: setnumeric sets the 'numeric' property of a mfh object.
%
% CALL:        obj = setNumeric(obj, val)
%              obj = obj.setNumeric(plist('inputObjects', val);
%
% INPUTS:      obj: mfh object(s)
%              val: Single object or a cell of objects
%
% <a href="matlab:utils.helper.displayMethodInfo('mfh', 'setNumeric')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setNumeric(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    in_names = {};
  else
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  end
  
  config.propName       = 'numeric';
  config.propDefVal     = {};
  config.inVarNames     = in_names;
  config.callerIsMethod = callerIsMethod;
  config.setterFcn      = @setterFcn;
  config.getInfoFcn     = @getInfo;
  
  % Call generic setter method
  [varargout{1:nargout}] = setPropertyValue(varargin{:}, config);
  
end

% Setter function to set the name
function value = setterFcn(varargin)
  
  obj   = varargin{1};
  pl    = varargin{2};
  value = varargin{3};
  
  obj.numeric = value;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist({'inputObjects', 'The input objects to set.'}, paramValue.EMPTY_CELL);
end
