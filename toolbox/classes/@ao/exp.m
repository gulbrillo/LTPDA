% EXP overloads the exp operator for analysis objects. Exponential.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: EXP overloads the exp operator for analysis objects. Exponential.
%              EXP(ao) is the exponential of the elements of ao.data
%                      e to the ao.data.
%
% CALL:        ao_out = exp(ao_in);
%              ao_out = exp(ao_in, pl);
%              ao_out = exp(ao1, pl1, ao_vector, ao_matrix, pl2);
%
% POSSIBLE VALUES: ao_in  = [ao2 ao3]
%                  ao_in  = ao_vector
%                  ao_in  = ao_matrix
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'exp')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = exp(varargin)
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Settings
  operatorName = 'exp';
  dxFcn = @(x,dx)abs(exp(x)).*dx;
  
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

function plout = getDefaultPlist(varargin)
  plout = plist.getDefaultAxisPlist(varargin{:});
end

