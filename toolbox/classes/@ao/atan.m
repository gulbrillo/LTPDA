% ATAN overloads the atan method for analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ATAN overloads the atan operator for analysis objects.
%              Inverse tangent result in radians.
%              ATAN(ao) is the arctangent of the elements of ao.data.
%
% CALL:        ao_out = atan(ao_in);
%              ao_out = atan(ao_in, pl);
%              ao_out = atan(ao1, pl1, ao_vector, ao_matrix, pl2);
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'atan')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = atan(varargin)
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Settings
  operatorName = 'atan';
  dxFcn = @(x,dx)abs(1./(1 + x.^2)).*dx;
  
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
    setUnitsForAxis(bs, pl, 'rad');
  end
  
  % set outputs
  varargout = utils.helper.setoutputs(nargout, bs); 
  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  ii = minfo.getInfoAxis(mfilename, @getDefaultPlist, mfilename('class'), 'ltpda', utils.const.categories.trig, '', varargin);
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

