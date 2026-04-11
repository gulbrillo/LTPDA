% COPY makes a (deep) copy of the input specwin objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input specwin objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input specwin object
%              flag - true: make a deep copy, false: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(old, deepcopy)
  
  if deepcopy
    % Loop over input specwin objects
    new = specwin.newarray(size(old));
    
    for kk = 1:numel(old)
      new(kk).type        = old(kk).type;
      new(kk).alpha       = old(kk).alpha;
      new(kk).psll        = old(kk).psll;
      new(kk).rov         = old(kk).rov;
      new(kk).nenbw       = old(kk).nenbw;
      new(kk).w3db        = old(kk).w3db;
      new(kk).flatness    = old(kk).flatness;
      new(kk).len         = old(kk).len;
      new(kk).levelorder  = old(kk).levelorder;
      new(kk).skip        = old(kk).skip;
      
    end
  else
    new = old;
  end
  
  varargout{1} = new;
end

