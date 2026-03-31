% COPY makes a (deep) copy of the input history objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input history objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input history object
%              flag - 1: make a deep copy, 0: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
% This is a transparent function and adds no history.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(old, deepcopy)
  
  if deepcopy
    % Loop over input history objects
    new = history.newarray(size(old));
    
    for kk=1:numel(old)
      new(kk).methodInfo   = old(kk).methodInfo;
      new(kk).plistUsed    = old(kk).plistUsed;
      new(kk).methodInvars = old(kk).methodInvars;
      new(kk).inhists      = old(kk).inhists;
      new(kk).proctime     = old(kk).proctime;
      new(kk).UUID         = old(kk).UUID;
      new(kk).objectClass  = old(kk).objectClass;
    end
  else
    new = old;
  end
  
  varargout{1} = new;
end

