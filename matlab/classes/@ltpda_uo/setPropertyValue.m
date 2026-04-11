% SETPROPERTYVALUE sets the value of a property of one or more objects.
%
% CALL:
%        varargout = setPropertyValue(inputs, ...
%                                     input_names, ...
%                                     callerIsMethod, ...
%                                     propName, ...
%                                     setterFcn, ...
%                                     copy, ...
%                                     getInfo)
%
%
%
%
%
% The setterFcn should have the following signature:
%
%    setterFcn(object, plist, value)
%
% The plist is passed to allow the setter function to modify the plist if
% necessary.
%
%
function varargout = setPropertyValue(varargin)
  
  % get inputs and configuration structure
  inputs = varargin(1:end-1);
  config = varargin{end};
  config.doCopy = nargout;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(inputs{:})
    varargout{1} = config.getInfoFcn(inputs{3});
    return
  end
  
  % call super class method
  [objects, ~, ~, ~] = setPropertyValue_core(inputs{:}, config);
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, objects);
end
