% COPY makes a (deep) copy of the input xydata objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input xydata objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input xydata object
%              flag - 1: make a deep copy, 0: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
% This is a transparent function and adds no history.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(old, deepcopy)
  
  if deepcopy
    % Loop over input xydata objects
    new = xydata.newarray(size(old));
    obj = copy@data2D(new, old, 1);
    
    for kk=1:numel(old)
    end
  else
    obj = old;
  end
  
  varargout{1} = obj;
end

