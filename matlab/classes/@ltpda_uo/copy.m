% COPY copies all fields of the ltpda_uo class to the new object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY copies all fields of the ltpda_uo class to the new
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
      %%% copy all fields of the ltpda_uo class
      new(kk).name        = old(kk).name;
      new(kk).description = old(kk).description;
      if ~isempty(old(kk).UUID)
        new(kk).UUID        = old(kk).UUID;
      end
    end
    
  else
    new = old;
  end
  
  varargout{1} = new;
end
