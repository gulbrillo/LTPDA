% COPY copies all fields of the data2D class to the new object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY copies all fields of the data2D class to the new
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
    new = copy@ltpda_data(new, old, 1);
    
    for kk = 1:numel(new)
      %%% copy all fields of the data2D class
      new(kk).xaxis = copy(old(kk).xaxis,1);
    end
    
  else
    new = old;
  end
  
  varargout{1} = new;
end
