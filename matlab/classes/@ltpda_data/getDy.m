% GETDY Get the property 'dy'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the property 'dy'.
%
% CALL:        val = obj.getDy();
%              val = obj.getDy(idx);
%              val = obj.getDy(1:10);
%
% INPUTS:      obj - must be a single ltpda_data (cdata, data2D, data3D) object.
%              idx - index of the data samples
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = getDy(data,idx)

  % Get dy values
  out = data.yaxis.ddata;

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

