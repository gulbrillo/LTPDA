% COPY makes a (deep) copy of the input msym objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input msym objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input msym object
%              flag - true: make a deep copy, false: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(old, deepcopy)
  
  if deepcopy
    % Loop over input specwin objects
    new = msym.newarray(size(old));
    
    for kk = 1:numel(old)
      new(kk).s = old(kk).s;
    end
  else
    new = old;
  end
  
  varargout{1} = new;
end

