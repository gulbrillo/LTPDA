% GETDY Get the property 'ddata'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the property 'ddata'.
%
% CALL:        val = obj.getDdata();
%              val = obj.getDdata(idx);
%              val = obj.getDdata(1:10);
%
% INPUTS:      obj - must be a single ltpda_vector object.
%              idx - index of the data samples
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = getDdata(vec, idx)

  % Get dy values
  out = vec.ddata;

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

