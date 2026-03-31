% SIGN overloads the sign operator for analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SIGN overloads the sign operator for analysis objects.
%
% CALL:        ao_out = sign(ao_in);
%              ao_out = sign(ao_in, pl);
%              ao_out = sign(ao1, pl1, ao_vector, ao_matrix, pl2);
%
% PARAMETERS:  see help for data2D/applymethod for additional parameters
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'sign')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = sign(varargin)
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Settings
  operatorName = 'sign';
  dxFcn = [];
  
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
    setUnitsForAxis(bs, pl, '');
    % Clear errors
    clearErrors(bs, pl);
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

