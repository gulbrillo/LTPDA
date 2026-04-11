% COPY makes a (deep) copy of the input plist objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input plist objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input plist object
%              flag - true: make a deep copy, false: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copyWithDefault(old, deepcopy)
  
  if deepcopy
    % Loop over input plist objects
    new = plist.newarray(size(old));
    
    for kk = 1:numel(old)
      
      new(kk).name = old(kk).name;
      new(kk).description = old(kk).description;
      
      if ~isempty(old(kk).params)
        new(kk).params  = copyWithDefault(old(kk).params, true);
      end
    end
  else
    new = old;
  end
  
  varargout{1} = new;
end

