% COPY makes a (deep) copy of the input param objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input param objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input param object
%              flag - true: make a deep copy, false: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(old, deepcopy)
  
  if deepcopy
    % Loop over input param objects
    new = param.newarray(size(old));
    
    for kk = 1:numel(old)
      if isa(old(kk).val, 'ltpda_obj')
        new(kk).val  = copy(old(kk).val, true);
      else
        new(kk).val = old(kk).val;
      end
      new(kk).key  = old(kk).key;
      new(kk).desc = old(kk).desc;
      new(kk).origin = old(kk).origin;
    end
  else
    new = old;
  end
  
  varargout{1} = new;
end

