% GETOBJECTCLASS get the class of object that this history refers to.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETOBJECTCLASS get the class of object that this history
%              refers to.
%
% CALL:        cl = getObjectClass(h);
%
% INPUT:       h - history object
%
% OUTPUT:      cl  - the class that this history refers to
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getObjectClass(varargin)
  
  % Check the inputs
  if nargin ~= 1
    error('### This method accepts only one history object.');
  end
  
  h  = varargin{1};
  
  varargout{1} = h.objectClass;
end

