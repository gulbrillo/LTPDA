% COPY makes a (deep) copy of the input fsdata objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input fsdata objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input fsdata object
%              flag - 1: make a deep copy, 0: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
% This is a transparent function and adds no history.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(old, deepcopy)
  
  if deepcopy
    % Loop over input fsdata objects
    new = fsdata.newarray(size(old));
    obj = copy@data2D(new, old, 1);
    
    for kk=1:numel(old)
      obj(kk).t0     = copy(old(kk).t0, 1);
      obj(kk).navs   = old(kk).navs;
      obj(kk).fs     = old(kk).fs;
      obj(kk).enbw   = old(kk).enbw;
    end
  else
    obj = old;
  end
  
  varargout{1} = obj;
end

