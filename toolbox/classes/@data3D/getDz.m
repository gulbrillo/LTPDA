% GETDZ Get the property 'dz'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the property 'dz'.
%
% CALL:        val = obj.getDz();
%              val = obj.getDz(idx);
%              val = obj.getDz(idx1, idx2);
%              val = obj.getDz(1:10);
%              val = obj.getDz(1,:);
%
% INPUTS:      obj - must be a single data3D object.
%              idx - index of the data samples
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getDz(data,idx1,idx2)

  % get dz values
  out = data.zaxis.ddata;

  % Decide if the user wants all data
  switch nargin
    case 2      
      out = out(idx1);
    case 3
      out = out(idx1, idx2);
  end
  
  varargout{1} = out;

end

