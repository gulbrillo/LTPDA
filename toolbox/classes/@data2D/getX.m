% GETX Get the property 'x'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the property 'x'.
%
% CALL:        val = obj.getX();
%              val = obj.getX(idx);
%              val = obj.getX(1:10);
%
% INPUTS:      obj - must be a single data2D object.
%              idx - index of the data samples
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = getX(data,idx)
  
  if isempty(data.xaxis)
    out = [];
    return
  end

  % Get x values
  out = data.xaxis.data;

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

