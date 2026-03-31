% REAL overloads the real operator for analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: REAL overloads the real operator for analysis objects.
%
% CALL:        ao_out = real(ao_in);
%              ao_out = real(ao_in, pl);
%
% PARAMETERS:  see help for data2D/applymethod for additional parameters
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'real')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = real(varargin)
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Settings
  operatorName = 'real';
  dxFcn = @(x,dx)real(dx);
  
  if callerIsMethod
    in_names = {};
  else
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  end
  
  copyObjects = nargout>0;
  [bs, pl] = ao.applymethod(copyObjects, callerIsMethod, in_names, operatorName, dxFcn, @getInfo, @getDefaultPlist, varargin{:});
    
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

