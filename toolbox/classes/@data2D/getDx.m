% GETDX Get the property 'dx'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the property 'dx'.
%
% CALL:        val = obj.getDx();
%              val = obj.getDx(idx);
%              val = obj.getDx(1:10);
%
% INPUTS:      obj - must be a single data2D object.
%              idx - index of the data samples
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = getDx(data,idx)

  % Get dx values
  out = data.xaxis.ddata;

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

