% COPY makes a (deep) copy of the input ltpda_utp objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input ltpda_utp objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input ltpda_utp object
%              flag - 1: make a deep copy, 0: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
% This is a transparent function and adds no history.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(old, deepcopy)
  
  if deepcopy
    % Loop over input ltpda_utp objects
    new = ltpda_utp.newarray(size(old));
    
  else
    new = old;
  end
  
  varargout{1} = new;
end

