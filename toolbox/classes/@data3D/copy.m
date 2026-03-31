% COPY copies all fields of the data3D class to the new object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY copies all fields of the data3D class to the new
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
    obj = copy@data2D(new, old, 1);
    
    for kk = 1:numel(obj)
      %%% copy all fields of the data3D class
      new(kk).zaxis = copy(old(kk).zaxis,1);
    end
    
  else
    obj = old;
  end
  
  varargout{1} = obj;
end
