% COPY makes a (deep) copy of the input paramValue objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input paramValue objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input paramValue object
%              flag - 1: make a deep copy, 0: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
% This is a transparent function and adds no history.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(old, deepcopy)
  
  if deepcopy
    % Loop over input paramValue objects
    new = paramValue.newarray(size(old));
    
    for kk=1:numel(old)
      new(kk).valIndex  = old(kk).valIndex;
      new(kk).selection = old(kk).selection;
      new(kk).property  = old(kk).property;
      new(kk).options   = cell(size(old(kk).options));
      for ff=1:numel(old(kk).options)
        if isa(old(kk).options{ff}, 'ltpda_obj')
          new(kk).options{ff} = copy(old(kk).options{ff}, 1);
        else
          new(kk).options{ff} = old(kk).options{ff};
        end
      end
    end
  else
    new = old;
  end
  
  varargout{1} = new;
end

