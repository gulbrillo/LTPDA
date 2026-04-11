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

function varargout = copyWithDefault(old, deepcopy)
  
  if deepcopy
    % Loop over input param objects
    new = param.newarray(size(old));
    
    for kk = 1:numel(old)
      
      % get the value
      val = old(kk).val;
      
      % if it's a paramValue, just take the default
      if isa(val, 'paramValue')
        val = val.getVal;
      end
      
      if isa(val, 'ltpda_obj')
        new(kk).val  = copy(val, true);
      else
        new(kk).val = val;
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

