% ALL overloads the all operator for analysis objects. True if all elements 
% of the AO are nonzero number or logical true
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ALL overloads the all operator for analysis objects. 
%              True if all elements of the AO are nonzero number or logical true
%
% CALL:        ao_out = all(ao_in);
%              ao_out = all(ao_in, pl);
%              ao_out = all(ao1, pl1, ao_vector, ao_matrix, pl2);
%
% POSSIBLE VALUES: ao_in  = [ao2 ao3]
%                  ao_in  = ao_vector
%                  ao_in  = ao_matrix
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'all')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = all(varargin)
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Settings
  operatorName = 'all';
  dxFcn = '';
  
  if callerIsMethod
    in_names = {};
  else
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  end
  
  copyObjects = nargout>0;
  [out, pl] = ao.applymethod(copyObjects, callerIsMethod, in_names, operatorName, dxFcn, @getInfo, @getDefaultPlist, varargin{:});
  
  if isa(out, 'ao')
    out = fixAxisData(out, pl, callerIsMethod);
  end
  
  % set outputs
  varargout = utils.helper.setoutputs(nargout, out);
  
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

