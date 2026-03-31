% SETPLOTINFO sets the 'plotinfo' property of a ltpda_uoh object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETPLOTINFO sets the 'plotinfo' property of a ltpda_uoh object.
%
% CALL:        objs.setPlotinfo(val);
%              objs.setPlotinfo(val1, val2);
%              objs.setPlotinfo(plist('plotinfo', val));
%              objs = objs.setPlotinfo(val);
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
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uoh', 'setPlotinfo')">Parameter Sets</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setPlotinfo(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    in_names = {};
  else
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  end
  
  % For backwards compatibility, we convert input plists to plotinfo
  % objects
  pl = utils.helper.collect_objects(varargin, 'plist');
  if isempty(pl)
    pl = varargin;
  else
    if isempty(pl.find_core('plotinfo'))
      warning('Passing a plist to setPlotinfo is deprecated. Please use plotinfo objects.');
      pl = plotinfo(pl);
    else
      pl = plotinfo(pl.find_core('plotinfo'));
    end
    pl = [varargin(1) {pl}];
  end
  
  config.propName       = 'plotinfo';
  config.propDefVal     = [];
  config.inVarNames     = in_names;
  config.callerIsMethod = callerIsMethod;
  config.setterFcn      = @setterFcn;
  config.getInfoFcn     = @getInfo;
  
  % Call generic setter method
  [varargout{1:nargout}] = setPropertyValue(pl{:}, config);
  
end

% Setter function to set the plotinfo
function value = setterFcn(obj, plHist, value)
  if isa(value, 'ltpda_obj')
    value = copy(value,1);
  end
  obj.plotinfo = value;
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
  pl = plist({'plotinfo', 'A plist to set to the plot info.'}, {1, {plist}, paramValue.OPTIONAL});
end
