% COPY makes a (deep) copy of the input pz objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input pz objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input pz object
%              flag - 1: make a deep copy, 0: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
% This is a transparent function and adds no history.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(old, deepcopy)
  
  if deepcopy
    % Loop over input pz objects
    new = pz.newarray(size(old));
    
    for kk=1:numel(old)
      new(kk).f  = old(kk).f;
      new(kk).q  = old(kk).q;
      new(kk).ri = old(kk).ri;
    end
  else
    new = old;
  end
  
  varargout{1} = new;
end

