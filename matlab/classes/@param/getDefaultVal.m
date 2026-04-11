% GETDEFAULTVAL retrurns the default value for this parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETDEFAULTVAL retrurns the default value for this parameter
%
% CALL:        val = getDefaultVal(param);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getDefaultVal(varargin)
  
  pin = varargin{1};
  
  if numel(pin) ~= 1 || nargin ~= 1
    error('### This method works only with one param object.');
  end

  if isa(pin.val, 'paramValue')
    varargout{1} = pin.val.getVal;  
  else
    varargout{1} = pin.val;
  end
end
