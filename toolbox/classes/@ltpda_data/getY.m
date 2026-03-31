% GETY Get the property 'y'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the property 'y'.
%
% CALL:        val = obj.getY();
%              val = obj.getY(idx);
%              val = obj.getY(1:10);
%
% INPUTS:      obj - must be a single ltpda_data (cdata, data2D, data3D) object.
%              idx - index of the data samples
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = getY(data,idx)
  
  if isempty(data.yaxis)
    out = [];
    return
  end
  
  % Get y values
  out = data.yaxis.data;
  
  % Decide if the user wants all data
  if nargin == 1
    % Make sure we output a column
    if size(out,1) == 1
      out = out.';
    end
  else
    if size(out,1) == 1
      % Make sure we output a column
      out = out(idx).';
    else
      out = out(idx);
    end
  end
end

