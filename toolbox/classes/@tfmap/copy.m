% COPY makes a (deep) copy of the input tfmap objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input tfmap objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input tfmap object
%              flag - 1: make a deep copy, 0: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
% This is a transparent function and adds no history.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(old, deepcopy)
  
  if deepcopy
    % Loop over input tfmap objects
    new = tfmap.newarray(size(old));
    obj = copy@data3D(new, old, 1);
    
    for kk=1:numel(old)
      obj(kk).t0      = copy(old(kk).t0, 1);
      obj(kk).toffset = old(kk).toffset;
      obj(kk).fs      = old(kk).fs;
      obj(kk).nsecs   = old(kk).nsecs;
    end
  else
    obj = old;
  end
  
  varargout{1} = obj;
end

