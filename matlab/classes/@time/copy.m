% COPY makes a (deep) copy of the input time objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input time objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input time object
%              flag - 1: make a deep copy, 0: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
% This is a transparent function and adds no history.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(old, deepcopy)
  
  if deepcopy
    % Loop over input time objects
    new = time.newarray(size(old));
    
    for kk=1:numel(old)
      new(kk).utc_epoch_milli = old(kk).utc_epoch_milli;
    end
  else
    new = old;
  end
  
  varargout{1} = new;
end

