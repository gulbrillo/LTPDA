% GETVAL returns the default value of a param.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETVAL returns the default value of a param
%
% CALL:        val = getVal(param);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getVal(varargin)
  
  pin = varargin{1};
  
  if numel(pin) ~= 1 || nargin ~= 1
    error('### This method works only with one param object. It might be that the PLIST have two parameter with the key [%s]', utils.helper.val2str(pin(1).key));
  end

  if isa(pin.val, 'paramValue') && ~isempty(pin.val) && (pin.val.valIndex >= 1)
    varargout{1} = pin.val.options{pin.val.valIndex};
    return;
  end
    
  varargout{1} = pin.val;
   
end
