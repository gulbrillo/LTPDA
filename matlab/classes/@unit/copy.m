% COPY makes a (deep) copy of the input unit objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input unit objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input unit object
%              flag - 1: make a deep copy, 0: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
% This is a transparent function and adds no history.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(old, deepcopy)
  
  if deepcopy
    % Loop over input unit objects
    new = unit.newarray(size(old));
    
    for kk=1:numel(old)
      new(kk).strs = old(kk).strs;
      new(kk).exps = old(kk).exps;
      new(kk).vals = old(kk).vals;
    end
  else
    new = old;
  end
  
  varargout{1} = new;
end

