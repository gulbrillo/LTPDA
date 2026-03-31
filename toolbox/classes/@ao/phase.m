% PHASE is the phase operator for analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PHASE is the phase operator for analysis objects.
%              Uses utils.math.phase() to compute the phase angle.
%
% CALL:        ao_out = phase(ao_in);
%              ao_out = phase(ao_in, pl);
%
% PARAMETERS:  see help for data2D/applymethod for additional parameters
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'phase')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = phase(varargin)
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Settings
  operatorName = 'utils.math.phase';
  dxFcn = @(x,dx)atan2(abs(dx),abs(x))*180/pi;
  
  if callerIsMethod
    in_names = {};
  else
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  end
  
  copyObjects = nargout>0;
  [bs, pl] = ao.applymethod(copyObjects, callerIsMethod, in_names, operatorName, dxFcn, @getInfo, @getDefaultPlist, varargin{:});
  
  if isa(bs, 'ao')
    % Set units
    setUnitsForAxis(bs, pl, 'deg');
  end
  
  % set outputs
  varargout = utils.helper.setoutputs(nargout, bs);
  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  ii = minfo.getInfoAxis(mfilename, @getDefaultPlist, mfilename('class'), 'ltpda', utils.const.categories.op, '', varargin);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------

function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function plout = buildplist(varargin)
  plout = plist.getDefaultAxisPlist(varargin{:});
end
