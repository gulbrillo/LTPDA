% COPY copies all fields of the ltpda_vector class to the new object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY copies all fields of the ltpda_vector class to the new
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
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(old, deepcopy)
  
  if deepcopy
    new = ltpda_vector.newarray(size(old));
    new = copy@ltpda_nuo(new, old, 1);
    
    for kk = 1:numel(new)
      %%% copy all fields of the ltpda_vector class
      if isa(old(kk).units, 'unit')
        new(kk).units     = copy(old(kk).units,1);
      else
        new(kk).units = old(kk).units;
      end
      new(kk).data      = old(kk).data;
      new(kk).ddata     = old(kk).ddata;
      new(kk).name      = old(kk).name;
    end
    obj = new;
    
  else
    obj = old;
  end
  
  varargout{1} = obj;
end
