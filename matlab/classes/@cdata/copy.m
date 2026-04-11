% COPY makes a (deep) copy of the input cdata objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input cdata objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input cdata object
%              flag - 1: make a deep copy, 0: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
% This is a transparent function and adds no history.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(old, deepcopy)
  
  if deepcopy
    % Loop over input cdata objects
    new = cdata.newarray(size(old));
    new = copy@ltpda_data(new, old, 1);
    
  else
    new = old;
  end
  
  varargout{1} = new;
end

