% GETY Get the property 'data'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the property 'data'.
%
% CALL:        val = obj.getData();
%              val = obj.getData(idx);
%              val = obj.getData(1:10);
%
% INPUTS:      obj - must be a single ltpda_vector object.
%              idx - index of the data samples
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = getData(vec, idx)

  % Get data values
  out = vec.data;

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

