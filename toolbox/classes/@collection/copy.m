% COPY makes a (deep) copy of the input collection objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input collection objects.
%
% CALL:        b = copy(a)
%              b = copy(a, flag)
%
% INPUTS:      a    - input collection object
%              flag - 1: make a deep copy, 0: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(varargin)
  
  old     = varargin{1};
  addHist = false;
  if nargin == 1
    deepcopy = true;
    addHist  = true;
  else
    deepcopy = varargin{2};
  end
  
  if deepcopy
    % Loop over input collection objects
    new = collection.newarray(size(old));
    obj = copy@ltpda_uoh(new, old, 1, addHist);
    
    for kk=1:numel(old)
      for ll=1:numel(old(kk).objs)
        if isa(old(kk).objs{ll}, 'ltpda_obj')
          obj(kk).objs{ll} = copy(old(kk).objs{ll}, 1);
        else
          obj(kk).objs{ll} = old(kk).objs{ll};
        end
        obj(kk).names{ll} = old(kk).names{ll};
      end
    end
  else
    obj = old;
  end
  
  varargout{1} = obj;
end

