% SETOBJECTCLASS set the class of object that this history refers to.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETOBJECTCLASS set the class of object that this history
%              refers to.
%
% CALL:        h = setObjectClass(h, class);
%              h.setObjectClass(class);
%
% INPUT:       h     - history object
%              class - string with the class name.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setObjectClass(varargin)
  
  % Check the inputs
  if nargin ~= 2
    error('### This method accepts only one history object and one class name.');
  end
  
  h  = varargin{1};
  cl = varargin{2};
  
  % Decide on a deep copy or a modify
  h = copy(h, nargout);
  
  % Set the class name to the history object
  h.objectClass = cl;
  
  % Define the output
  varargout{1} = h;
  
end
