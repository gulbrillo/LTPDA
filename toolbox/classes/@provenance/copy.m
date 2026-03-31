% COPY makes a (deep) copy of the input provenance objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input provenance objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input provenance object
%              flag - 1: make a deep copy, 0: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
% This is a transparent function and adds no history.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(old, deepcopy)
  
  if deepcopy
    % Loop over input provenance objects
    new = provenance.newarray(size(old));
    
    for kk=1:numel(old)
      new(kk).creator               = old(kk).creator;
      new(kk).ip                    = old(kk).ip;
      new(kk).hostname              = old(kk).hostname;
      new(kk).os                    = old(kk).os;
      new(kk).matlab_version        = old(kk).matlab_version;
      new(kk).sigproc_version       = old(kk).sigproc_version;
      new(kk).symbolic_math_version = old(kk).symbolic_math_version;
      new(kk).optimization_version  = old(kk).optimization_version;
      new(kk).database_version      = old(kk).database_version;
      new(kk).control_version       = old(kk).control_version;
      new(kk).ltpda_version         = old(kk).ltpda_version;
    end
  else
    new = old;
  end
  
  varargout{1} = new;
end

