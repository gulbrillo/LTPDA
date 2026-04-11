% SETFS Set the property 'fs'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'fs'.
%
% CALL:              obj.setFs(12);
%              obj = obj.setFs(12); create copy of the object
%
% INPUTS:      obj - must be a single data2D object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setFs(varargin)
  
  obj = varargin{1};
  val = varargin{2};
  
  % decide whether we modify the pz-object, or create a new one.
  obj = copy(obj, nargout);
  
  % set 'fs'
  obj.fs = val;
  
  % Now we can set nsecs
  obj.fixNsecs();
  
  varargout{1} = obj;
end


