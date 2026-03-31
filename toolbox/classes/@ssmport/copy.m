% COPY makes a (deep) copy of the input ssmport objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input ssmport objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input ssmport object
%              flag - 1: make a deep copy, 0: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
% This is a transparent function and adds no history.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(old, deepcopy)
  
  if deepcopy
    % Loop over input ssmport objects
    new = ssmport.newarray(size(old));
    
    for kk=1:numel(old)
      new(kk).name        = old(kk).name;
      
      if isempty(old(kk).units)
      else
        new(kk).units       = copy(old(kk).units, 1);
      end
      
      new(kk).description = old(kk).description;
    end
  else
    new = old;
  end
  
  varargout{1} = new;
end

