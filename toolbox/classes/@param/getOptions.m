% GETOPTIONS returns the array of options for the param
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETOPTIONS returns the array of options for the param
%
% CALL:        val = getOptions(param);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getOptions(varargin)
  
  pin = varargin{1};
  
  if numel(pin) ~= 1 || nargin ~= 1
    error('### This method works only with one param object.');
  end

  if isa(pin.val, 'paramValue')
    varargout{1} = pin.val.getOptions;
  else
    varargout{1} = {pin.val};
  end
end
