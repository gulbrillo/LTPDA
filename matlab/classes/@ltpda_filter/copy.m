% COPY copies all fields of the ltpda_filter class to the new object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY copies all fields of the ltpda_filter class to the new
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

function varargout = copy(new, old, deepcopy, addHist)
  
  if deepcopy
    obj = copy@ltpda_tf(new, old, 1, addHist);
    
    for kk = 1:numel(obj)
      %%% copy all fields of the ltpda_filter class
      obj(kk).fs       = old(kk).fs;
      obj(kk).infile   = old(kk).infile;
      obj(kk).a        = old(kk).a;
      obj(kk).histout  = old(kk).histout;
    end
    
  else
    obj = old;
  end
  
  varargout{1} = obj;
end

