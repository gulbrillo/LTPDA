% GETZ Get the property 'z'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the property 'z'.
%
% CALL:        val = obj.getZ();
%              val = obj.getZ(idx);
%              val = obj.getZ(idx1, idx2);
%              val = obj.getZ(1:10);
%              val = obj.getZ(1,:);
%
% INPUTS:      obj - must be a single data3D object.
%              idx - index of the data samples
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getZ(data,idx1,idx2)
  
  % get z values
  out = data.zaxis.data;
  
  % Decide if the user wants all data
  switch nargin
    case 2      
      out = out(idx1);
    case 3
      out = out(idx1, idx2);
  end
  
  varargout{1} = out;

end

