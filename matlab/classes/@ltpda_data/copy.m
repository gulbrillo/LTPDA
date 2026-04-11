% COPY copies all fields of the ltpda_data class to the new object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY copies all fields of the ltpda_data class to the new
%              object.
%
% CALL:        b = copy(new, old, flag)
%
% INPUTS:      new  - new object which should be created in the sub class.
%              old  - old object
%              flag - 1: make a deep copy, 0: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(new, old, deepcopy)
  
  if deepcopy
    
    for kk = 1:numel(new)
      %%% copy all fields of the ltpda_data class
      new(kk).yaxis = copy(old(kk).yaxis,1);
    end
    obj = new;
    
  else
    obj = old;
  end
  
  varargout{1} = obj;
end
