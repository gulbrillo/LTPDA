% GETVAL returns the default value for this param value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETVAL returns the default value for this param value
%
% CALL:        val = getVal(paramValue);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getVal(varargin)
  
  if (varargin{1}.valIndex >= 1)
    varargout{1} = varargin{1}.options{varargin{1}.valIndex};
  else
    varargout{1} = [];
  end
   
end
